// FCM Token Management Edge Function
// Handles storing and managing FCM tokens for push notifications

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface FCMTokenRequest {
  action: 'store' | 'remove'
  token: string
  device_type?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get authorization header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Authorization header required' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader }
        }
      }
    )

    // Verify user is authenticated
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { action, token, device_type }: FCMTokenRequest = await req.json()

    if (action === 'store') {
      if (!token) {
        return new Response(
          JSON.stringify({ error: 'FCM token is required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Upsert FCM token
      const { error: upsertError } = await supabaseClient
        .from('fcm_tokens')
        .upsert({
          user_id: user.id,
          token: token,
          device_type: device_type || 'unknown',
          updated_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,token'
        })

      if (upsertError) {
        console.error('Error storing FCM token:', upsertError)
        return new Response(
          JSON.stringify({ error: 'Failed to store FCM token' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ success: true, message: 'FCM token stored successfully' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'remove') {
      if (!token) {
        return new Response(
          JSON.stringify({ error: 'FCM token is required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Remove FCM token
      const { error: deleteError } = await supabaseClient
        .from('fcm_tokens')
        .delete()
        .eq('user_id', user.id)
        .eq('token', token)

      if (deleteError) {
        console.error('Error removing FCM token:', deleteError)
        return new Response(
          JSON.stringify({ error: 'Failed to remove FCM token' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({ success: true, message: 'FCM token removed successfully' }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ error: 'Invalid action' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})


