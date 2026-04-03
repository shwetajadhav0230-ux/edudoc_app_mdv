import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // 1. Setup Supabase Client
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  
  // Create a client with Admin rights
  const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

  // 2. Get the user from the Request Header (Security Check)
  const authHeader = req.headers.get('Authorization')!;
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(authHeader.replace('Bearer ', ''));

  if (error || !user) {
    return new Response("Unauthorized", { status: 401 });
  }

  // 3. Delete the User
  const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(user.id);

  if (deleteError) {
    return new Response(JSON.stringify({ error: deleteError.message }), { status: 400 });
  }

  return new Response(JSON.stringify({ message: "Account deleted" }), {
    headers: { "Content-Type": "application/json" },
  });
});