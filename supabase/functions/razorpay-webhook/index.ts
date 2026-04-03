import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import * as crypto from "https://deno.land/std@0.177.0/node/crypto.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // 1. Get Secrets
  const webhookSecret = Deno.env.get('RAZORPAY_WEBHOOK_SECRET')
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

  // 2. Validate Signature
  const signature = req.headers.get('x-razorpay-signature')
  const body = await req.text()
  const expectedSignature = crypto.createHmac('sha256', webhookSecret!)
    .update(body)
    .digest('hex');

  if (expectedSignature !== signature) {
    return new Response("Invalid signature", { status: 400 })
  }

  // 3. Process Payment
  const event = JSON.parse(body)
  if (event.event === 'payment.captured') {
    // Note: We access the user_id from the 'notes' we sent from Flutter
    const userId = event.payload.payment.entity.notes.user_id; 
    const amountPaid = event.payload.payment.entity.amount; // In paise
    const tokensToAdd = amountPaid / 100; // 1 Rupee = 1 Token logic

    const supabase = createClient(supabaseUrl!, supabaseKey!)
    
    // Call the Secure RPC we created earlier
    const { error } = await supabase.rpc('add_tokens', { 
      row_id: userId, 
      count: tokensToAdd 
    })
    
    if (error) console.error(error)
  }

  return new Response(JSON.stringify({ received: true }), { 
    headers: { "Content-Type": "application/json" } 
  })
})