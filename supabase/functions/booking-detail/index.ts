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

  try {
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return jsonResponse({ success: false, message: "Authorization header required" }, 401)
    }

    const url = new URL(req.url)
    let bookingId = url.searchParams.get("id")

    if (!bookingId && req.method === "POST") {
      const body = await req.json().catch(() => ({}))
      bookingId = body.id ?? body.booking_id ?? body.bookingId
    }

    if (!bookingId) {
      return jsonResponse({ success: false, message: "Booking ID is required" }, 400)
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

    const { data: booking, error } = await supabaseClient
      .from("bookings")
      .select("*")
      .eq("id", bookingId)
      .single()

    if (error || !booking) {
      return jsonResponse({ success: false, message: "Booking not found" }, 404)
    }

    console.log("[booking-detail] booking row", JSON.stringify({
      id: booking.id,
      booking_number: booking.booking_number ?? booking.booking_id,
      consumer_name: booking.consumer_name,
      address_full: booking.address_full,
      booking_date: booking.booking_date,
      booking_time: booking.booking_time,
      status: booking.status,
      latitude: booking.latitude,
      longitude: booking.longitude,
    }))

    // Ensure user is part of booking
    if (booking.consumer_id !== user.id && booking.provider_id !== user.id) {
      return jsonResponse({ success: false, message: "Unauthorized" }, 403)
    }

    // Notes summary
    const { count: noteCount, error: noteError } = await supabaseClient
      .from("booking_notes")
      .select("id", { count: "exact", head: true })
      .eq("booking_id", bookingId)

    if (noteError) {
      console.error("[booking-detail] note summary error", noteError)
    }

    const response = mapBookingDetail(booking, noteCount ?? 0)

    return jsonResponse({ success: true, data: response })
  } catch (err) {
    console.error("[booking-detail] unexpected error", err)
    return jsonResponse({
      success: false,
      message: err instanceof Error ? err.message : "Unexpected error",
    }, 500)
  }
})

function mapBookingDetail(row: any, noteCount: number) {
  return {
    booking: {
      id: row.id,
      bookingNumber: row.booking_number ?? row.booking_id,
      status: row.status,
      note: row.note,
      remark: row.remark,
      visitingCharge: row.visiting_charge,
      bookingDate: row.booking_date,
      bookingTime: row.booking_time,
      startedAt: row.started_at,
      completedAt: row.completed_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    },
    consumer: {
      id: row.consumer_id,
      name: row.consumer_name,
      avatar: row.consumer_avatar,
      phone: row.consumer_phone,
    },
    provider: {
      id: row.provider_id,
      name: row.provider_name,
      avatar: row.provider_avatar,
      phone: row.provider_phone,
    },
    service: {
      id: row.service_id,
      name: row.service_name,
      image: row.service_image,
      plan: row.plan_id
        ? {
          id: row.plan_id,
          name: row.plan_name,
          price: row.plan_price,
        }
        : null,
      charges: {
        visitingCharge: row.visiting_charge,
        serviceFee: row.service_fee,
        itemTotal: row.item_total,
        itemDiscount: row.item_discount,
        total: row.total,
      },
    },
    address: {
      id: row.address_id,
      full: row.address_full,
      city: row.address_city,
      state: row.address_state,
      postalCode: row.address_postal,
      latitude: row.latitude,
      longitude: row.longitude,
    },
    notesSummary: {
      count: noteCount,
    },
    permissions: {
      canStart: row.status === "accepted",
      canComplete: row.status === "in_progress",
      canCancel: row.status === "pending" || row.status === "accepted",
    },
  }
}

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}

