import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
}

type BookingAction =
  | "accept"
  | "reject"
  | "start"
  | "complete"
  | "cancel"
  | "on-my-way"

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return jsonResponse({ success: false, message: "Authorization header required" }, 401)
    }

    const payload = await req.json()
    const action = payload.action as BookingAction
    const bookingId = payload.booking_id as string
    const remark = payload.remark as string | undefined
    const reason = payload.reason as string | undefined

    if (!bookingId || !action) {
      return jsonResponse({ success: false, message: "booking_id and action are required" }, 400)
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    )

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return jsonResponse({ success: false, message: "Unauthorized" }, 401)
    }

    // Get booking with snapshot data for notifications
    const { data: booking, error } = await supabaseClient
      .from("bookings")
      .select("*")
      .eq("id", bookingId)
      .single()

    if (error || !booking) {
      return jsonResponse({ success: false, message: "Booking not found" }, 404)
    }

    const providerActions: BookingAction[] = ["accept", "reject", "start", "complete", "on-my-way"]
    const isProviderAction = providerActions.includes(action)
    if (isProviderAction && booking.provider_id !== user.id) {
      return jsonResponse({ success: false, message: "Unauthorized provider action" }, 403)
    }
    if (action === "cancel" && booking.consumer_id !== user.id) {
      return jsonResponse({ success: false, message: "Unauthorized consumer action" }, 403)
    }

    if (action === "on-my-way") {
      // Send notification to consumer that provider is on the way
      try {
        await sendNotificationToUser(
          booking.consumer_id,
          "Provider is on the way",
          `${booking.provider_name || "Provider"} is on the way to your location`,
          {
            booking_id: bookingId,
            type: "booking",
            action: "on-my-way",
          },
        )
      } catch (notifErr) {
        console.error("[booking-actions] notification error for on-my-way", notifErr)
        // Don't fail the request if notification fails
      }

      return jsonResponse({
        success: true,
        message: "Destination info ready",
        data: {
          address: {
            full: booking.address_full,
            latitude: booking.latitude,
            longitude: booking.longitude,
          },
        },
      })
    }

    const updateResult = buildUpdatePayload(action, booking, { remark, reason })
    if (updateResult.error) {
      return jsonResponse({ success: false, message: updateResult.error }, 400)
    }

    const { data: updated, error: updateError } = await supabaseClient
      .from("bookings")
      .update(updateResult.updateData)
      .eq("id", bookingId)
      .select("*")
      .single()

    if (updateError || !updated) {
      console.error("[booking-actions] update error", updateError)
      return jsonResponse({ success: false, message: "Failed to update booking" }, 500)
    }

    // Close chat when booking is rejected or completed
    try {
      if (updated.status === "rejected" || updated.status === "completed" || updated.status === "cancelled") {
        const now = new Date().toISOString()
        const { error: convoUpdateError } = await supabaseClient
          .from("booking_conversations")
          .update({
            status: "closed",
            closed_at: now,
          })
          .eq("booking_id", bookingId)

        if (convoUpdateError) {
          console.error("[booking-actions] conversation close error", convoUpdateError)
        }
      }
    } catch (chatErr) {
      console.error("[booking-actions] chat close error", chatErr)
      // Do not fail booking action because of chat close
    }

    // Send notifications based on action
    try {
      await sendBookingStatusNotification(
        action,
        updated,
        booking,
        user.id,
      )
    } catch (notifErr) {
      console.error("[booking-actions] notification error", notifErr)
      // Don't fail the request if notification fails
    }

    return jsonResponse({
      success: true,
      message: updateResult.message,
      data: {
        booking: {
          id: updated.id,
          status: updated.status,
          startedAt: updated.started_at,
          completedAt: updated.completed_at,
          remark: updated.remark,
        },
      },
    })
  } catch (err) {
    console.error("[booking-actions] unexpected error", err)
    return jsonResponse({
      success: false,
      message: err instanceof Error ? err.message : "Unexpected error",
    }, 500)
  }
})

function buildUpdatePayload(
  action: BookingAction,
  booking: any,
  { remark, reason }: { remark?: string; reason?: string },
) {
  const now = new Date().toISOString()

  switch (action) {
    case "accept":
      if (booking.status !== "pending") {
        return { error: "Only pending bookings can be accepted" }
      }
      return {
        message: "Booking accepted",
        updateData: {
          status: "accepted",
          remark: remark ?? booking.remark,
          updated_at: now,
        },
      }

    case "reject":
      if (booking.status !== "pending") {
        return { error: "Only pending bookings can be rejected" }
      }
      return {
        message: "Booking rejected",
        updateData: {
          status: "rejected",
          remark: reason ?? remark ?? booking.remark,
          updated_at: now,
        },
      }

    case "start":
      if (booking.status !== "accepted") {
        return { error: "Only accepted bookings can be started" }
      }
      return {
        message: "Work started",
        updateData: {
          status: "in_progress",
          started_at: now,
          updated_at: now,
        },
      }

    case "complete":
      if (booking.status !== "in_progress") {
        return { error: "Only in-progress bookings can be completed" }
      }
      return {
        message: "Booking completed",
        updateData: {
          status: "completed",
          completed_at: now,
          remark: remark ?? booking.remark,
          updated_at: now,
        },
      }

    case "cancel":
      if (!["pending", "accepted"].includes(booking.status)) {
        return { error: "Only pending or accepted bookings can be cancelled" }
      }
      return {
        message: "Booking cancelled",
        updateData: {
          status: "cancelled",
          remark: reason ?? remark ?? booking.remark,
          updated_at: now,
        },
      }

    default:
      return { error: "Unsupported action" }
  }
}

// Helper function to send notification to a user
async function sendNotificationToUser(
  userId: string,
  title: string,
  body: string,
  data: Record<string, string> = {},
) {
  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? ""
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""

    if (!supabaseUrl || !serviceRoleKey) {
      console.error("[sendNotificationToUser] Missing Supabase URL or service role key")
      return
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey)
    const { error } = await supabaseAdmin.functions.invoke("send-notification", {
      body: {
        userId,
        title,
        body,
        data,
        type: data.type || "booking",
      },
    })

    if (error) {
      console.error("[sendNotificationToUser] Error invoking send-notification", error)
    }
  } catch (err) {
    console.error("[sendNotificationToUser] Exception:", err)
    throw err
  }
}

// Send booking status notification to the appropriate user
async function sendBookingStatusNotification(
  action: BookingAction,
  updatedBooking: any,
  originalBooking: any,
  actorUserId: string,
) {
  const bookingNumber = updatedBooking.booking_number || updatedBooking.booking_id || "Booking"

  switch (action) {
    case "accept":
      // Notify consumer that booking was accepted
      await sendNotificationToUser(
        updatedBooking.consumer_id,
        "Booking Accepted",
        `${updatedBooking.provider_name || "Provider"} has accepted your booking request`,
        {
          booking_id: updatedBooking.id,
          type: "booking",
          action: "accepted",
          booking_number: bookingNumber,
        },
      )
      break

    case "reject":
      // Notify consumer that booking was rejected
      await sendNotificationToUser(
        updatedBooking.consumer_id,
        "Booking Rejected",
        `${updatedBooking.provider_name || "Provider"} has rejected your booking request`,
        {
          booking_id: updatedBooking.id,
          type: "booking",
          action: "rejected",
          booking_number: bookingNumber,
        },
      )
      break

    case "start":
      // Notify consumer that work has started
      await sendNotificationToUser(
        updatedBooking.consumer_id,
        "Work Started",
        `${updatedBooking.provider_name || "Provider"} has started working on your booking`,
        {
          booking_id: updatedBooking.id,
          type: "booking",
          action: "work_started",
          booking_number: bookingNumber,
        },
      )
      break

    case "complete":
      // Notify consumer that work is completed
      await sendNotificationToUser(
        updatedBooking.consumer_id,
        "Work Completed",
        `${updatedBooking.provider_name || "Provider"} has completed your booking`,
        {
          booking_id: updatedBooking.id,
          type: "booking",
          action: "work_completed",
          booking_number: bookingNumber,
        },
      )
      break

    case "cancel":
      // Notify provider that booking was cancelled
      await sendNotificationToUser(
        updatedBooking.provider_id,
        "Booking Cancelled",
        `${updatedBooking.consumer_name || "Customer"} has cancelled the booking`,
        {
          booking_id: updatedBooking.id,
          type: "booking",
          action: "cancelled",
          booking_number: bookingNumber,
        },
      )
      break
  }
}

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}



