// Deno runtime. No Node.js needed.
// This function:
// - Verifies Supabase JWT sent by the client (Authorization: Bearer <token>)
// - Applies simple per-user rate limit (best-effort, instance-local)
// - Enforces CORS (only your domains)
// - Calls Gemini server-side with your secret API key
// - Returns only the Gemini response
/// <reference lib="deno.ns" />
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;
const ALLOWED_ORIGINS = (Deno.env.get("ALLOWED_ORIGINS") ?? "").split(",").map(s => s.trim()).filter(Boolean);
const DEFAULT_MODEL = Deno.env.get("DEFAULT_MODEL") ?? "gemini-1.5-flash";
const REQUESTS_PER_MINUTE = parseInt(Deno.env.get("REQUESTS_PER_MINUTE") ?? "60", 10);
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
  const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

// Simple, instance-local buckets for rate limiting
const buckets = new Map<string, number>();

function cors(origin: string | null) {
  const allow = origin && ALLOWED_ORIGINS.includes(origin) ? origin : "";
  return {
    "Access-Control-Allow-Origin": allow,
    "Vary": "Origin",
    "Access-Control-Allow-Headers": "authorization, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

async function verifyJwtAndGetUserId(req: Request): Promise<string | null> {
  // Verify Supabase JWT via JWKS (no extra libs)
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const auth = req.headers.get("Authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return null;
  const token = auth.slice("Bearer ".length);

  // Supabase exposes JWKS at /auth/v1/...
  const projectUrl = Deno.env.get("SUPABASE_URL")!;
  const jwksUrl = `${projectUrl}/auth/v1/.well-known/jwks.json`;

  const { importJWK, jwtVerify } = await import("https://esm.sh/jose@5.2.4");
  const jwksResp = await fetch(jwksUrl);
  if (!jwksResp.ok) return null;
  const { keys } = await jwksResp.json();

  let verified = null;
  for (const jwk of keys) {
    try {
      const key = await importJWK(jwk, "RS256");
      const { payload } = await jwtVerify(token, key, { algorithms: ["RS256"] });
      // If verify succeeds with any key, accept
      verified = payload;
      break;
    } catch (_) {
      // try next key
    }
  }
const { data, error } = await supabase.auth.getUser();
  if (error || !data?.user) return null;
  return data.user.id;
  //return verified ? (verified.sub as string | null) : null;
}

Deno.serve(async (req) => {
  const headers = cors(req.headers.get("Origin"));

  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { headers });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method Not Allowed" }), { status: 405, headers });
  }

  try {
    // 1) Verify user JWT from Supabase
    const userId = await verifyJwtAndGetUserId(req);
    if (!userId) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401, headers });
    }

    // 2) Basic RPM limiter per user
    const minute = Math.floor(Date.now() / 60000);
    const key = `${userId}:${minute}`;
    const used = buckets.get(key) ?? 0;
    if (used >= REQUESTS_PER_MINUTE) {
      return new Response(JSON.stringify({ error: "Rate limit exceeded" }), { status: 429, headers });
    }
    buckets.set(key, used + 1);

    // 3) Parse body: { model?, contents: [...] }
    const body = await req.json();
    const model = (body?.model as string) || DEFAULT_MODEL;
    const contents = body?.contents;
    if (!Array.isArray(contents) || contents.length === 0) {
      return new Response(JSON.stringify({ error: "Missing 'contents' array" }), { status: 400, headers });
    }

    // 4) Call Gemini from the server
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${GEMINI_API_KEY}`;
    const r = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ contents }),
    });

    const data = await r.json();

    // 5) Return Gemini response (no secrets)
    return new Response(JSON.stringify(data), {
      status: r.status,
      headers: { ...headers, "Content-Type": "application/json" },
    });
  } catch (_err) {
    return new Response(JSON.stringify({ error: "Internal error" }), {
      status: 500,
      headers: { ...headers, "Content-Type": "application/json" },
    });
  }
});
