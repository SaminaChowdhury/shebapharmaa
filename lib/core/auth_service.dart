import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class AuthService {
  static String? _accessToken;
  static String? _refreshToken;
  static bool _initialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('access_token');
      _refreshToken = prefs.getString('refresh_token');
      _initialized = true;
      
      
    } catch (e) {
      // Error initializing AuthService - tokens will remain null
    }
  }

  // Getters
  static String? get accessToken {
    return _accessToken;
  }
  static String? get refreshToken => _refreshToken;
  static bool get isLoggedIn {
    return _accessToken != null;
  }

  // Set tokens
  static Future<void> setTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
    } catch (e) {
      // Error saving tokens to SharedPreferences
    }
  }

  // Clear tokens (logout)
  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
  
    } catch (e) {
      // Error clearing tokens from SharedPreferences
    }
  }



  // Register user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    try {
      // Use the exact field names your API expects
      final requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
        'first_name': firstName ?? '',
        'last_name': lastName ?? '',
        'phone': phone,
        'address': address,
      };
      
      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Registration successful',
          'data': jsonDecode(response.body),
        };
      } else {
        final errorData = jsonDecode(response.body);
        
        // Extract specific error messages from your API format
        String errorMessage = 'Registration failed';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            // Get the first error from any field
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final requestBody = {
        'username': username,
        'password': password,
      };
      
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store tokens
        if (data['access'] != null && data['refresh'] != null) {
          setTokens(data['access'], data['refresh']);
          
          return {
            'success': true,
            'message': 'Login successful',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        
        // Extract specific error messages from your API format
        String errorMessage = 'Login failed';
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        } else if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            } else {
              errorMessage = firstError.toString();
            }
          }
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshAccessToken() async {
    if (_refreshToken == null) {
      return {
        'success': false,
        'message': 'No refresh token available',
      };
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refreshTokenUrl),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['access'] != null) {
          _accessToken = data['access'];
          
          return {
            'success': true,
            'message': 'Token refreshed successfully',
            'data': data,
          };
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
          };
        }
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Token refresh failed',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Check if user is authenticated and get profile
  static Future<Map<String, dynamic>> checkAuthStatus() async {
    if (_accessToken == null) {
      return {
        'success': false,
        'message': 'Not authenticated',
        'isAuthenticated': false,
      };
    }

    try {
      final profileResult = await getProfile();
      if (profileResult['success']) {
        return {
          'success': true,
          'message': 'Authenticated',
          'isAuthenticated': true,
          'profile': profileResult['data'],
        };
      } else {
        // Token might be expired, try to refresh
        final refreshResult = await refreshAccessToken();
        if (refreshResult['success']) {
          // Try to get profile again
          final profileResult2 = await getProfile();
          if (profileResult2['success']) {
            return {
              'success': true,
              'message': 'Authenticated (token refreshed)',
              'isAuthenticated': true,
              'profile': profileResult2['data'],
            };
          }
        }
        
        // If refresh failed, clear tokens
        clearTokens();
        return {
          'success': false,
          'message': 'Authentication expired',
          'isAuthenticated': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error checking auth status: ${e.toString()}',
        'isAuthenticated': false,
      };
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    if (_accessToken == null) {
      return {
        'success': false,
        'message': 'No access token available',
      };
    }

    try {
      final requestBody = <String, dynamic>{};
      if (firstName != null) requestBody['first_name'] = firstName;
      if (lastName != null) requestBody['last_name'] = lastName;
      if (phone != null) requestBody['phone'] = phone;
      if (address != null) requestBody['address'] = address;

      final response = await http.patch(
        Uri.parse(ApiConfig.profileUrl),
        headers: ApiConfig.authHeaders(_accessToken!),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update profile',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Logout
  static Future<void> logout() async {
    await clearTokens();
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    if (_accessToken == null) {
      return {
        'success': false,
        'message': 'No access token available',
      };
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileUrl),
        headers: ApiConfig.authHeaders(_accessToken!),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Profile fetched successfully',
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch profile',
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
