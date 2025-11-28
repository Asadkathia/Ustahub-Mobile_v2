import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
}

type Role = "provider" | "consumer"

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
    let role = (url.searchParams.get("role") ?? "provider") as Role
    let status = url.searchParams.get("status") ?? "all"
    let page = Math.max(1, Number(url.searchParams.get("page") ?? "1"))
    let pageSize = Math.min(50, Math.max(1, Number(url.searchParams.get("page_size") ?? "20")))

    if (req.method === "POST") {
      const body = await req.json().catch(() => ({}))
      if (body.role) role = body.role
      if (body.status) status = body.status
      if (body.page) page = Math.max(1, Number(body.page))
      if (body.page_size || body.pageSize) {
        const desired = Number(body.page_size ?? body.pageSize)
        pageSize = Math.min(50, Math.max(1, desired))
      }
    }
    const from = (page - 1) * pageSize
    const to = from + pageSize - 1

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

    let query = supabaseClient
      .from("bookings")
      .select(
        `
          id,
          booking_id,
          booking_number,
          status,
          booking_date,
          booking_time,
          address_id,
          address_full,
          address_city,
          address_state,
          address_postal,
          updated_at,
          consumer_id,
          consumer_name,
          consumer_avatar,
          provider_id,
          provider_name,
          provider_avatar,
          service_id,
          service_name,
          service_image
        `,
        { count: "exact" },
      )
      .order("booking_date", { ascending: true })
      .order("booking_time", { ascending: true })
      .range(from, to)

    if (role === "provider") {
      query = query.eq("provider_id", user.id)
    } else {
      query = query.eq("consumer_id", user.id)
    }

    if (status && status !== "all") {
      const mappedStatuses = mapStatus(status)
      if (mappedStatuses.length === 1) {
        query = query.eq("status", mappedStatuses[0])
      } else if (mappedStatuses.length > 1) {
        query = query.in("status", mappedStatuses)
      }
    }

    const { data, error, count } = await query
    if (error) {
      console.error("[booking-list] query error", error)
      return jsonResponse({ success: false, message: error.message }, 500)
    }

    const items = (data ?? []).map((row) => {
      const addressPreview =
        row.address_full ??
        [row.address_city, row.address_state, row.address_postal]
          .filter(Boolean)
          .join(", ")

      return {
        id: row.id,
        consumerId: row.consumer_id,
        providerId: row.provider_id,
        serviceId: row.service_id,
        addressId: row.address_id,
        bookingNumber: row.booking_number ?? row.booking_id,
        status: row.status,
        service: {
          id: row.service_id,
          name: row.service_name,
          image: row.service_image,
        },
        counterparty:
          role === "provider"
            ? {
              id: row.consumer_id,
              name: row.consumer_name,
              avatar: row.consumer_avatar,
            }
            : {
              id: row.provider_id,
              name: row.provider_name,
              avatar: row.provider_avatar,
            },
        scheduled: {
          date: row.booking_date,
          time: row.booking_time,
        },
        addressPreview,
        updatedAt: row.updated_at,
      }
    })

    return jsonResponse({
      success: true,
      data: items,
      pagination: {
        page,
        pageSize,
        total: count ?? items.length,
      },
    })
  } catch (err) {
    console.error("[booking-list] unexpected error", err)
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

function mapStatus(status: string): string[] {
  switch (status) {
    case "not_started":
      return ["pending", "accepted"]
    case "ongoing":
    case "in_progress":
      return ["in_progress"]
    case "completed":
      return ["completed"]
    case "cancelled":
      return ["cancelled"]
    case "pending":
      return ["pending"]
    case "accepted":
      return ["accepted"]
    case "history":
      return ["completed", "cancelled", "rejected"]
    default:
      return [status]
  }
}

