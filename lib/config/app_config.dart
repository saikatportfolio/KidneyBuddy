class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://ukhmymbgfzbpulwsfmrd.supabase.co'; // Replace with your Production Supabase URL
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVraG15bWJnZnpicHVsd3NmbXJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3OTMxNTIsImV4cCI6MjA2NzM2OTE1Mn0.WcimbbltoqdRewLh7Wnh3DP7f-BMgRuQ8115oZoGpjo'; // Replace with your Production Supabase Anon Key

  // Google OAuth Redirect URL (for web)
  static const String googleAuthRedirectUrl = 'https://ukhmymbgfzbpulwsfmrd.supabase.co/auth/v1/callback'; // Replace with your Production Google OAuth Redirect URL

  // Google Sign-In Web Client ID (for mobile)
  static const String googleSignInWebClientId = '998282656789-og31pr3bvcdi7b49p1emo5bsuc9s5t5m.apps.googleusercontent.com'; // Replace with your Production Google Web Client ID
}
