// Wallet Management Edge Function
// Handles wallet operations: add funds, get balance, get transactions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface WalletRequest {
  action: 'add_funds' | 'get_balance' | 'get_transactions'
  amount?: number
  description?: string
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

    // Verify user is a provider
    const { data: profile } = await supabaseClient
      .from('user_profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profile?.role !== 'provider') {
      return new Response(
        JSON.stringify({ error: 'Only providers can access wallet' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { action, amount, description }: WalletRequest = await req.json()

    if (action === 'add_funds') {
      if (!amount || amount <= 0) {
        return new Response(
          JSON.stringify({ error: 'Valid amount is required' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Get current balance
      const { data: currentBalance } = await supabaseClient
        .from('wallet_balance')
        .select('balance')
        .eq('provider_id', user.id)
        .single()

      const oldBalance = currentBalance?.balance || 0
      const newBalance = oldBalance + amount

      // Update balance
      const { error: balanceError } = await supabaseClient
        .from('wallet_balance')
        .upsert({
          provider_id: user.id,
          balance: newBalance,
          updated_at: new Date().toISOString()
        }, {
          onConflict: 'provider_id'
        })

      if (balanceError) {
        console.error('Error updating balance:', balanceError)
        return new Response(
          JSON.stringify({ error: 'Failed to add funds' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      // Create transaction record
      const { error: transactionError } = await supabaseClient
        .from('wallet_transactions')
        .insert({
          provider_id: user.id,
          transaction_type: 'credit',
          amount: amount,
          balance_after: newBalance,
          description: description || 'Funds added to wallet',
          reference_id: `TXN-${Date.now()}`
        })

      if (transactionError) {
        console.error('Error creating transaction:', transactionError)
        // Rollback balance update would be ideal, but for now just log
      }

      return new Response(
        JSON.stringify({
          success: true,
          message: 'Funds added successfully',
          balance: newBalance
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'get_balance') {
      const { data: balance, error: balanceError } = await supabaseClient
        .from('wallet_balance')
        .select('balance')
        .eq('provider_id', user.id)
        .single()

      if (balanceError && balanceError.code !== 'PGRST116') { // PGRST116 = no rows returned
        console.error('Error fetching balance:', balanceError)
        return new Response(
          JSON.stringify({ error: 'Failed to fetch balance' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({
          success: true,
          balance: balance?.balance || 0
        }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (action === 'get_transactions') {
      const { data: transactions, error: transactionsError } = await supabaseClient
        .from('wallet_transactions')
        .select('*')
        .eq('provider_id', user.id)
        .order('created_at', { ascending: false })
        .limit(50)

      if (transactionsError) {
        console.error('Error fetching transactions:', transactionsError)
        return new Response(
          JSON.stringify({ error: 'Failed to fetch transactions' }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }

      return new Response(
        JSON.stringify({
          success: true,
          transactions: transactions || []
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


