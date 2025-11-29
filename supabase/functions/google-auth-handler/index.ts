// Google Auth Handler Edge Function
// Handles profile creation/update after Google OAuth sign-in

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface GoogleAuthRequest {
  user_id: string
  email: string
  name: string
  role: 'consumer' | 'provider'
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    const { user_id, email, name, role }: GoogleAuthRequest = await req.json()

    if (!user_id || !email || !role) {
      return new Response(
        JSON.stringify({ error: 'user_id, email, and role are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check if profile already exists
    const { data: existingProfile, error: profileError } = await supabaseClient
      .from('user_profiles')
      .select('id, role')
      .eq('id', user_id)
      .single()

    let isNewUser = false
    let existingRole: string | null = null

    if (profileError && profileError.code === 'PGRST116') {
      // Profile doesn't exist - create it
      isNewUser = true
      
      const { error: createError } = await supabaseClient
        .from('user_profiles')
        .insert({
          id: user_id,
          email: email.toLowerCase(),
          name: name,
          role: role,
          is_verified: false
        })

      if (createError) {
        console.error('Error creating profile:', createError)
        return new Response(
          JSON.stringify({ error: 'Failed to create profile: ' + createError.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Create provider record if role is provider
      if (role === 'provider') {
        const { error: providerError } = await supabaseClient
          .from('providers')
          .insert({
            id: user_id,
            is_verified: false
          })
        
        if (providerError) {
          console.error('Error creating provider:', providerError)
          // Continue anyway - provider record might already exist
        }
      }
    } else if (existingProfile) {
      // Profile exists - update role if needed
      existingRole = existingProfile.role
      
      // If role is different, update it (user might be switching roles)
      if (existingProfile.role !== role) {
        const { error: updateError } = await supabaseClient
          .from('user_profiles')
          .update({ role: role })
          .eq('id', user_id)

        if (updateError) {
          console.error('Error updating profile role:', updateError)
          // Continue anyway - role update is not critical
        }
      }

      // Ensure provider record exists if role is provider
      if (role === 'provider') {
        const { data: existingProvider } = await supabaseClient
          .from('providers')
          .select('id')
          .eq('id', user_id)
          .single()

        if (!existingProvider) {
          const { error: providerError } = await supabaseClient
            .from('providers')
            .insert({
              id: user_id,
              is_verified: false
            })
          
          if (providerError) {
            console.error('Error creating provider record:', providerError)
          }
        }
      }
    } else {
      // Unexpected error
      console.error('Unexpected error checking profile:', profileError)
      return new Response(
        JSON.stringify({ error: 'Failed to check profile: ' + profileError?.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        isNewUser: isNewUser,
        existingRole: existingRole,
        user_id: user_id,
        email: email.toLowerCase(),
        role: role,
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

