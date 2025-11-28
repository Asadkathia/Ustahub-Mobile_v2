// OTP Authentication Edge Function
// Handles sending and verifying OTP for email-based authentication

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface OTPRequest {
  action: 'send' | 'verify'
  email?: string
  otp?: string
  role?: 'consumer' | 'provider'
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

    const { action, email, otp, role }: OTPRequest = await req.json()

    if (action === 'send') {
      // Generate 6-digit OTP
      const generatedOTP = Math.floor(100000 + Math.random() * 900000).toString()
      const expiresAt = new Date()
      expiresAt.setMinutes(expiresAt.getMinutes() + 10) // 10 minutes expiry

      // Store OTP in database
      const { error: dbError } = await supabaseClient
        .from('otp_verifications')
        .insert({
          email: email?.toLowerCase(),
          otp: generatedOTP,
          expires_at: expiresAt.toISOString(),
          verified: false
        })

      if (dbError) {
        console.error('Error storing OTP:', dbError)
        return new Response(
          JSON.stringify({ error: 'Failed to generate OTP' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      console.log(`OTP for ${email}: ${generatedOTP}`)

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'OTP sent successfully',
          // Remove this in production - only for testing
          otp: generatedOTP 
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'verify') {
      if (!email || !otp) {
        return new Response(
          JSON.stringify({ error: 'Email and OTP are required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Verify OTP
      const { data: otpData, error: otpError } = await supabaseClient
        .from('otp_verifications')
        .select('*')
        .eq('email', email.toLowerCase())
        .eq('otp', otp)
        .eq('verified', false)
        .gt('expires_at', new Date().toISOString())
        .order('created_at', { ascending: false })
        .limit(1)
        .single()

      if (otpError || !otpData) {
        return new Response(
          JSON.stringify({ error: 'Invalid or expired OTP' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Mark OTP as verified
      await supabaseClient
        .from('otp_verifications')
        .update({ verified: true })
        .eq('id', otpData.id)

      // Check if user exists by querying user_profiles table
      // We'll use the email to find existing users via their profile
      const { data: existingProfiles } = await supabaseClient
        .from('user_profiles')
        .select('id, email')
        .limit(1000) // Get all profiles (or use a reasonable limit)

      // Find user by email in profiles
      let userId: string | null = null
      let isNewUser = false

      // Check if user exists in auth.users by trying to list users
      try {
        const { data: usersData, error: listError } = await supabaseClient.auth.admin.listUsers()
        
        if (!listError && usersData?.users) {
          // Find user by email
          const existingUser = usersData.users.find(
            (user: any) => user.email?.toLowerCase() === email.toLowerCase()
          )
          
          if (existingUser) {
            userId = existingUser.id
            isNewUser = false
          }
        }
      } catch (listErr) {
        console.log('Could not list users, will try create approach:', listErr)
      }

      // If user not found, create new user
      if (!userId) {
        try {
          const { data: newUser, error: createError } = await supabaseClient.auth.admin.createUser({
            email: email.toLowerCase(),
            email_confirm: true, // Auto-confirm email
          })

          if (createError) {
            // User might already exist - try to find by checking user_profiles with email
            // Or use a different approach
            console.error('Error creating user:', createError)
            
            // If error is "User already registered", try to find the user
            if (createError.message?.includes('already') || createError.message?.includes('exists')) {
              // Try to get user from user_profiles by matching email pattern
              // Since we can't query auth.users directly, we'll need to handle this differently
              // For now, return error and ask user to try login
              return new Response(
                JSON.stringify({ 
                  error: 'User already exists. Please try logging in instead.',
                  isRegister: true // Indicates existing user
                }),
                { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
              )
            }
            
            return new Response(
              JSON.stringify({ error: 'Failed to create user account: ' + createError.message }),
              { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
          }

          if (!newUser?.user) {
            return new Response(
              JSON.stringify({ error: 'Failed to create user account' }),
              { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            )
          }

          userId = newUser.user.id
          isNewUser = true

          // Create user profile
          const { error: profileError } = await supabaseClient
            .from('user_profiles')
            .insert({
              id: userId,
              name: email.split('@')[0], // Default name from email
              role: role || 'consumer',
              is_verified: false
            })

          if (profileError) {
            console.error('Error creating profile:', profileError)
            // Continue anyway - profile might already exist
          }

          // Create provider record if role is provider
          if (role === 'provider') {
            const { error: providerError } = await supabaseClient
              .from('providers')
              .insert({
                id: userId,
                is_verified: false
              })
            
            if (providerError) {
              console.error('Error creating provider:', providerError)
            }
          }
        } catch (createErr) {
          console.error('Exception creating user:', createErr)
          return new Response(
            JSON.stringify({ error: 'Failed to create user: ' + createErr.message }),
            { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          )
        }
      } else {
        // Existing user - check if profile exists, create if not
        const { data: existingProfile } = await supabaseClient
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .single()

        if (!existingProfile) {
          // Profile doesn't exist, create it
          await supabaseClient
            .from('user_profiles')
            .insert({
              id: userId,
              name: email.split('@')[0],
              role: role || 'consumer',
              is_verified: false
            })
        }
      }

      // Create a temporary password for the user to enable immediate sign-in
      // Generate a random password
      const tempPassword = Math.random().toString(36).slice(-12) + Math.random().toString(36).slice(-12) + 'A1!'
      
      // Update user with temporary password
      const { error: passwordError } = await supabaseClient.auth.admin.updateUserById(
        userId,
        { password: tempPassword }
      )
      
      if (passwordError) {
        console.error('Error setting temporary password:', passwordError)
        // Continue anyway - client can use passwordless flow
      }

      // Return user info with temporary password for immediate sign-in
      // The client will use this to sign in and create a session
      return new Response(
        JSON.stringify({
          success: true,
          isRegister: !isNewUser, // isRegister=true means existing user (login), false means new user (signup)
          user_id: userId,
          email: email.toLowerCase(),
          role: role || 'consumer',
          temp_password: tempPassword, // Temporary password for immediate sign-in
        }),
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

