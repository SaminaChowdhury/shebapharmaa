class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://shebaai.pythonanywhere.com/api';
  
  // Authentication endpoints
  static const String register = '/accounts/auth/register/';
  static const String login = '/accounts/auth/login/';
  static const String refreshToken = '/accounts/auth/refresh/';
  static const String profile = '/accounts/auth/profile/';
  
  // Order endpoints
  static const String createOrder = '/orders/create/';
  static const String getOrders = '/orders/orders/';
  static const String getOrderDetails = '/orders/orders/';
  
  // Full URLs
  static String get registerUrl => '$baseUrl$register';
  static String get loginUrl => '$baseUrl$login';
  static String get refreshTokenUrl => '$baseUrl$refreshToken';
  static String get profileUrl => '$baseUrl$profile';
  static String get createOrderUrl => '$baseUrl$createOrder';
  static String get getOrdersUrl => '$baseUrl$getOrders';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
