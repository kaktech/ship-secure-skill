// Browser code. FAKE service-role style key shipped to the client (item 3).
const SUPABASE_URL = "https://example.supabase.co";
const SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoic2VydmljZV9yb2xlIn0.FAKEFAKEFAKEFAKEFAKE";

function renderComment(c) {
  document.getElementById("comments").innerHTML += "<p>" + c.body + "</p>"; // XSS sink (item 15)
}
