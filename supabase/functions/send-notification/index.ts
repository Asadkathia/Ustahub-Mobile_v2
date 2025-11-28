// Send Push Notification Edge Function
// Uses Firebase Cloud Messaging (FCM) REST API to send push notifications

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
}

interface NotificationPayload {
  userId: string // Target user ID to send notification to
  title: string
  body: string
  data?: Record<string, string> // Additional data payload
  type?: "booking" | "message" | "general" // Notification type
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // Get service role key for admin access
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    )

    const payload: NotificationPayload = await req.json()

    if (!payload.userId || !payload.title || !payload.body) {
      return jsonResponse(
        { success: false, message: "userId, title, and body are required" },
        400,
      )
    }

    // Get all FCM tokens for the target user
    const { data: tokens, error: tokensError } = await supabaseAdmin
      .from("fcm_tokens")
      .select("token")
      .eq("user_id", payload.userId)

    if (tokensError || !tokens || tokens.length === 0) {
      console.log(
        `[send-notification] No FCM tokens found for user ${payload.userId}`,
      )
      return jsonResponse({
        success: false,
        message: "No FCM tokens found for user",
      }, 404)
    }

    // Get Firebase credentials from environment
    // Try V1 API first (service account), fallback to Legacy API (server key)
    const firebaseProjectId = Deno.env.get("FIREBASE_PROJECT_ID")
    const firebasePrivateKey = Deno.env.get("FIREBASE_PRIVATE_KEY")
    const firebaseClientEmail = Deno.env.get("FIREBASE_CLIENT_EMAIL")
    const firebaseServerKey = Deno.env.get("FIREBASE_SERVER_KEY") // Legacy fallback

    const useV1Api = firebaseProjectId && firebasePrivateKey && firebaseClientEmail
    const useLegacyApi = !!firebaseServerKey

    if (!useV1Api && !useLegacyApi) {
      console.error("[send-notification] Firebase credentials not configured")
      return jsonResponse(
        {
          success: false,
          message: "Firebase credentials not configured. Set either V1 API credentials (FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, FIREBASE_CLIENT_EMAIL) or Legacy API (FIREBASE_SERVER_KEY).",
        },
        500,
      )
    }

    // Prepare notification payload
    const notificationData = {
      title: payload.title,
      body: payload.body,
      data: {
        type: payload.type || "general",
        ...payload.data,
      },
    }

    // Send notification to all user's devices
    const results = []
    for (const tokenRow of tokens) {
      const token = tokenRow.token

      try {
        let fcmResponse: Response

        if (useV1Api) {
          // Use V1 API with service account
          const accessToken = await getFirebaseAccessToken(
            firebasePrivateKey!,
            firebaseClientEmail!,
          )

          const fcmUrl = `https://fcm.googleapis.com/v1/projects/${firebaseProjectId}/messages:send`

          const fcmPayload = {
            message: {
              token: token,
              notification: {
                title: payload.title,
                body: payload.body,
              },
              data: Object.entries(notificationData.data).reduce(
                (acc, [key, value]) => {
                  acc[key] = String(value)
                  return acc
                },
                {} as Record<string, string>,
              ),
              android: {
                priority: "high",
              },
              apns: {
                headers: {
                  "apns-priority": "10",
                },
                payload: {
                  aps: {
                    sound: "default",
                  },
                },
              },
            },
          }

          fcmResponse = await fetch(fcmUrl, {
            method: "POST",
            headers: {
              "Authorization": `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(fcmPayload),
          })
        } else {
          // Use Legacy API with server key
          const fcmUrl = "https://fcm.googleapis.com/fcm/send"

          const fcmPayload = {
            to: token,
            notification: {
              title: payload.title,
              body: payload.body,
              sound: "default",
            },
            data: Object.entries(notificationData.data).reduce(
              (acc, [key, value]) => {
                acc[key] = String(value)
                return acc
              },
              {} as Record<string, string>,
            ),
            priority: "high",
          }

          fcmResponse = await fetch(fcmUrl, {
            method: "POST",
            headers: {
              "Authorization": `key=${firebaseServerKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(fcmPayload),
          })
        }

        if (fcmResponse.ok) {
          const responseData = await fcmResponse.json()
          if (useV1Api) {
            // V1 API returns { name: "projects/.../messages/..." } on success
            if (responseData.name) {
              results.push({ token: token.substring(0, 10) + "...", success: true })
            } else {
              console.error(`[send-notification] V1 API error:`, responseData)
              results.push({ token: token.substring(0, 10) + "...", success: false, error: JSON.stringify(responseData) })
            }
          } else {
            // Legacy API returns { success: 1, message_id: "..." } on success
            if (responseData.success === 1 || responseData.message_id) {
              results.push({ token: token.substring(0, 10) + "...", success: true })
            } else {
              console.error(`[send-notification] Legacy API error:`, responseData)
              results.push({ token: token.substring(0, 10) + "...", success: false, error: JSON.stringify(responseData) })
            }
          }
        } else {
          const errorText = await fcmResponse.text()
          console.error(`[send-notification] FCM HTTP error:`, errorText)
          results.push({ token: token.substring(0, 10) + "...", success: false, error: errorText })
        }
      } catch (tokenError) {
        console.error(`[send-notification] Error sending notification:`, tokenError)
        results.push({
          token: token.substring(0, 10) + "...",
          success: false,
          error: tokenError instanceof Error ? tokenError.message : String(tokenError),
        })
      }
    }

    const successCount = results.filter((r) => r.success).length
    const failCount = results.length - successCount

    console.log(
      `[send-notification] Sent to ${successCount}/${results.length} device(s) for user ${payload.userId}`,
    )

    return jsonResponse({
      success: successCount > 0,
      message: `Sent to ${successCount} device(s), failed: ${failCount}`,
      data: {
        total: results.length,
        successful: successCount,
        failed: failCount,
        results,
      },
    })
  } catch (err) {
    console.error("[send-notification] unexpected error", err)
    return jsonResponse(
      {
        success: false,
        message: err instanceof Error ? err.message : "Unexpected error",
      },
      500,
    )
  }
})

// Get Firebase access token using service account (for V1 API)
async function getFirebaseAccessToken(
  privateKey: string,
  clientEmail: string,
): Promise<string> {
  // Import JWT library for Deno
  const { create, verify } = await import("https://deno.land/x/djwt@v2.8/mod.ts")

  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: clientEmail,
    sub: clientEmail,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600, // 1 hour
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  }

  const header = {
    alg: "RS256",
    typ: "JWT",
  }

  // Parse private key (remove headers/footers and newlines)
  const cleanKey = privateKey
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\n/g, "")
    .replace(/\s/g, "")

  // Convert base64 to ArrayBuffer
  const keyData = Uint8Array.from(atob(cleanKey), (c) => c.charCodeAt(0))

  // Import the key
  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  )

  // Create JWT
  const token = await create(header, payload, key)

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: token,
    }),
  })

  if (!tokenResponse.ok) {
    const errorText = await tokenResponse.text()
    throw new Error(`Failed to get access token: ${errorText}`)
  }

  const tokenData = await tokenResponse.json()
  return tokenData.access_token
}

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}

