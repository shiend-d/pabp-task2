class ApiConstants {
  static const String baseUrl = 'https://ezatonofotvdvhhenphc.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV6YXRvbm9mb3R2ZHZoaGVucGhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NzI4NzYsImV4cCI6MjA5MjU0ODg3Nn0.In7i2a226vdau2xT-SvGytP1pgsoqmJuNsq2hxAcTqw';

  // Auth endpoints
  static const String loginUrl = '$baseUrl/auth/v1/token?grant_type=password';

  // REST API endpoints
  static const String medicinesUrl = '$baseUrl/rest/v1/medicines';
  static const String transactionsUrl = '$baseUrl/rest/v1/transactions';
  static const String transactionItemsUrl =
      '$baseUrl/rest/v1/transaction_items';

  // Headers
  static Map<String, String> publicHeaders() {
    return {
      'Content-Type': 'application/json',
      'apikey': anonKey,
    };
  }

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'apikey': anonKey,
      'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String> authHeadersWithPrefer(String token) {
    return {
      'Content-Type': 'application/json',
      'apikey': anonKey,
      'Authorization': 'Bearer $token',
      'Prefer': 'return=representation',
    };
  }
}
