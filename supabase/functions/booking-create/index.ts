import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  if (req.method !== "POST") {
    return jsonResponse({ success: false, message: "Method not allowed" }, 405)
  }

  try {
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return jsonResponse({ success: false, message: "Authorization header required" }, 401)
    }

    const payload = await req.json()
    const requiredFields = [
      "provider_id",
      "service_id",
      "address_id",
      "booking_date",
      "booking_time",
    ]
    const missing = requiredFields.filter((field) => !payload[field])
    if (missing.length > 0) {
      return jsonResponse({
        success: false,
        message: `Missing fields: ${missing.join(", ")}`,
      }, 400)
    }

    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } },
    )

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    )

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return jsonResponse({ success: false, message: "Unauthorized" }, 401)
    }

    const bookingId = payload.booking_id ?? `BOOK-${Date.now()}`
    const visitingCharge = Number(payload.visiting_charge ?? 0)

    const insertPayload: Record<string, unknown> = {
      booking_id: bookingId,
      consumer_id: user.id,
      provider_id: payload.provider_id,
      service_id: payload.service_id,
      plan_id: payload.plan_id ?? null,
      address_id: payload.address_id,
      booking_date: payload.booking_date,
      booking_time: payload.booking_time,
      note: payload.note ?? null,
      status: "pending",
      remark: payload.remark ?? null,
      visiting_charge: visitingCharge,
    }

    if (payload.plan_id) {
      const { data: totals, error: totalError } = await supabaseClient.rpc(
        "calculate_booking_total",
        {
          p_service_id: payload.service_id,
          p_plan_id: payload.plan_id,
          p_visiting_charge: visitingCharge,
        },
      )

      if (totalError) {
        console.error("[booking-create] total calculation error", totalError)
      } else if (totals && totals.length > 0) {
        insertPayload["item_total"] = totals[0].item_total
        insertPayload["service_fee"] = totals[0].service_fee
        insertPayload["total"] = totals[0].total
      }
    }

    const { data: booking, error: insertError } = await supabaseClient
      .from("bookings")
      .insert(insertPayload)
      .select("*")
      .single()

    if (insertError || !booking) {
      console.error("[booking-create] insert error", insertError)
      return jsonResponse({ success: false, message: "Failed to create booking" }, 500)
    }

    // Create/open 1:1 booking conversation for this booking
    try {
      const { data: conversation, error: convoError } = await supabaseClient
        .from("booking_conversations")
        .upsert(
          {
            booking_id: booking.id,
            status: "open",
          },
          { onConflict: "booking_id" },
        )
        .select("*")
        .single()

      if (convoError || !conversation) {
        console.error("[booking-create] conversation upsert error", convoError)
      } else {
        const participants = [
          {
            conversation_id: conversation.id,
            user_id: booking.consumer_id,
            role: "consumer",
          },
          {
            conversation_id: conversation.id,
            user_id: booking.provider_id,
            role: "provider",
          },
        ]

        const { error: participantsError } = await supabaseClient
          .from("booking_conversation_participants")
          .upsert(participants, { onConflict: "conversation_id,user_id" })

        if (participantsError) {
          console.error(
            "[booking-create] participants upsert error",
            participantsError,
          )
        }
      }
    } catch (chatErr) {
      console.error("[booking-create] chat bootstrap error", chatErr)
      // Do not fail booking creation because of chat bootstrap
    }

    // Send notification to provider about new booking request
    try {
      const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? ""
      const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""

      if (!supabaseUrl || !serviceRoleKey) {
        throw new Error("Missing Supabase URL or service role key for notification")
      }

      const { error: notifError } = await supabaseAdmin.functions.invoke("send-notification", {
        body: {
          userId: booking.provider_id,
          title: "New Booking Request",
          body: `You have a new booking request${booking.consumer_name ? ` from ${booking.consumer_name}` : ""}`,
          data: {
            type: "booking",
            booking_id: booking.id,
            action: "new_booking",
            booking_number: booking.booking_number || booking.booking_id,
          },
        },
      })

      if (notifError) {
        throw notifError
      }
    } catch (notifErr) {
      console.error("[booking-create] notification error", notifErr)
      // Don't fail booking creation if notification fails
    }

    return jsonResponse({
      success: true,
      message: "Booking created successfully",
      data: {
        id: booking.id,
        bookingNumber: booking.booking_number ?? booking.booking_id,
        status: booking.status,
      },
    }, 201)
  } catch (err) {
    console.error("[booking-create] unexpected error", err)
    return jsonResponse({
      success: false,
      message: err instanceof Error ? err.message : "Unexpected error",
    }, 500)
  }
})

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}



