// Send Message Edge Function
// Handles message insertion and sends push notification to recipient

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

    const payload = await req.json()
    const bookingId = payload.booking_id as string
    const text = payload.text as string

    if (!bookingId || !text || text.trim().length === 0) {
      return jsonResponse({ success: false, message: "booking_id and text are required" }, 400)
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

    // Get booking to verify user is a participant and get conversation_id
    const { data: booking, error: bookingError } = await supabaseClient
      .from("bookings")
      .select("id, consumer_id, provider_id, booking_number, consumer_name, provider_name")
      .eq("id", bookingId)
      .single()

    if (bookingError || !booking) {
      return jsonResponse({ success: false, message: "Booking not found" }, 404)
    }

    // Verify user is a participant
    if (booking.consumer_id !== user.id && booking.provider_id !== user.id) {
      return jsonResponse({ success: false, message: "Unauthorized" }, 403)
    }

    // Get or create conversation_id
    let conversationId: string | null = null
    
    // Try to get existing conversation
    const { data: conversation, error: convoError } = await supabaseClient
      .from("booking_conversations")
      .select("id")
      .eq("booking_id", bookingId)
      .single()

    if (conversation) {
      conversationId = conversation.id
    } else {
      // Create conversation if it doesn't exist (use admin client for permissions)
      const { data: newConversation, error: createConvoError } = await supabaseAdmin
        .from("booking_conversations")
        .insert({
          booking_id: bookingId,
          consumer_id: booking.consumer_id,
          provider_id: booking.provider_id,
        })
        .select("id")
        .single()

      if (createConvoError || !newConversation) {
        console.error("[send-message] Failed to create conversation:", createConvoError)
        // Continue without conversation_id if table doesn't exist or creation fails
        conversationId = null
      } else {
        conversationId = newConversation.id
      }
    }

    // Insert message (conversation_id is optional if table doesn't exist)
    const messageData: any = {
      booking_id: bookingId,
      sender_id: user.id,
      text: text.trim(),
    }
    
    if (conversationId) {
      messageData.conversation_id = conversationId
    }

    const { data: message, error: insertError } = await supabaseClient
      .from("booking_messages")
      .insert(messageData)
      .select("*")
      .single()

    if (insertError || !message) {
      console.error("[send-message] insert error", insertError)
      return jsonResponse({ success: false, message: "Failed to send message" }, 500)
    }

    // Send notification to the other participant
    try {
      const recipientId = booking.consumer_id === user.id
        ? booking.provider_id
        : booking.consumer_id

      const senderName = booking.consumer_id === user.id
        ? (booking.consumer_name || "Customer")
        : (booking.provider_name || "Provider")

      // Call send-notification Edge Function
      const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? ""
      const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""

      if (!supabaseUrl || !serviceRoleKey) {
        throw new Error("Missing Supabase URL or service role key for notification")
      }

      const { error: notifError } = await supabaseAdmin.functions.invoke("send-notification", {
        body: {
          userId: recipientId,
          title: "New Message",
          body: `${senderName}: ${text.trim().substring(0, 100)}${text.length > 100 ? "..." : ""}`,
          data: {
            type: "message",
            booking_id: bookingId,
            message_id: message.id,
            sender_id: user.id,
            booking_number: booking.booking_number || bookingId,
          },
        },
      })

      if (notifError) {
        throw notifError
      }
    } catch (notifErr) {
      console.error("[send-message] notification error", notifErr)
      // Don't fail message send if notification fails
    }

    return jsonResponse({
      success: true,
      message: "Message sent successfully",
      data: {
        id: message.id,
        text: message.text,
        created_at: message.created_at,
      },
    })
  } catch (err) {
    console.error("[send-message] unexpected error", err)
    return jsonResponse(
      {
        success: false,
        message: err instanceof Error ? err.message : "Unexpected error",
      },
      500,
    )
  }
})

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}


