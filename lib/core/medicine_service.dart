import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MedicineService {
  static const String _baseUrl = ApiConfig.baseUrl;
  
  // Get all medicines
  static Future<Map<String, dynamic>> getMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicines/medicines/'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load medicines: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get medicine by ID
  static Future<Map<String, dynamic>> getMedicineById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicines/medicines/$id/'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load medicine: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Search medicines
  static Future<Map<String, dynamic>> searchMedicines(String query) async {
    try {
      if (query.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Search query cannot be empty',
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/medicines/medicines/?search=${Uri.encodeComponent(query.trim())}'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to search medicines: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Filter medicines by category
  static Future<Map<String, dynamic>> getMedicinesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicines/medicines/?category=$category'),
        headers: ApiConfig.defaultHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load medicines by category: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Helper method to categorize medicines based on generic name
  static String getCategoryFromGenericName(String genericName) {
    final name = genericName.toLowerCase();
    
    if (name.contains('paracetamol') || name.contains('ibuprofen') || 
        name.contains('aspirin') || name.contains('diclofenac') ||
        name.contains('calpol') || name.contains('napa')) {
      return 'Pain Relief';
    } else if (name.contains('amoxicillin') || name.contains('azithromycin') || 
               name.contains('ciprofloxacin') || name.contains('metronidazole') ||
               name.contains('amoxil') || name.contains('zimax') || 
               name.contains('seclo') || name.contains('filmet')) {
      return 'Antibiotics';
    } else if (name.contains('omeprazole') || name.contains('esomeprazole') || 
               name.contains('amlodipine') || name.contains('losectil') ||
               name.contains('maxpro') || name.contains('amdocal')) {
      return 'Cardiovascular';
    } else if (name.contains('vitamin') || name.contains('omega')) {
      return 'Vitamins';
    } else {
      return 'General';
    }
  }

  // Helper method to get default image for medicines without images
  static String getDefaultImage(String genericName) {
    final name = genericName.toLowerCase();
    
    // Map specific medicine names to their corresponding images
    if (name.contains('amoxicillin') || name.contains('amoxil')) {
      return 'assets/images/amoxil.png';
    } else if (name.contains('amlodipine') || name.contains('amdocal')) {
      return 'assets/images/amdocal.jpg';
    } else if (name.contains('paracetamol') || name.contains('calpol') || name.contains('napa')) {
      // Use calpol for paracetamol-based medicines
      if (name.contains('calpol')) {
        return 'assets/images/calpol.jpg';
      } else if (name.contains('napa')) {
        return 'assets/images/napa.jpg';
      } else {
        return 'assets/images/calpol.jpg'; 
      }
    } else if (name.contains('omeprazole') || name.contains('losectil')) {
      return 'assets/images/losectil.jpg';
    } else if (name.contains('esomeprazole') || name.contains('maxpro')) {
      return 'assets/images/maxpro.jpg';
    } else if (name.contains('azithromycin') || name.contains('zimax')) {
      return 'assets/images/zimax.jpg';
    } else if (name.contains('metronidazole') || name.contains('filmet')) {
      return 'assets/images/filmet.jpg';
    } else if (name.contains('ciprofloxacin') || name.contains('seclo')) {
      return 'assets/images/seclo.jpg';
    } else {
      // Fallback to logo for unknown medicines
      return 'assets/images/logo_small.png';
    }
  }

  // Helper method to validate and clean image URLs
  static String? validateImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // Check if it's a valid HTTP/HTTPS URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Basic URL validation
      try {
        final uri = Uri.parse(imageUrl);
        if (uri.hasScheme && uri.hasAuthority) {
          return imageUrl;
        }
      } catch (e) {
        // Invalid URL, return null
        return null;
      }
    }
    
    return null;
  }

  // Helper method to get medicine description
  static String getMedicineDescription(String genericName) {
    final name = genericName.toLowerCase();
    
    if (name.contains('paracetamol')) {
      return 'Effective pain relief and fever reduction medication';
    } else if (name.contains('amoxicillin') || name.contains('amoxil')) {
      return 'Broad-spectrum antibiotic for treating bacterial infections';
    } else if (name.contains('omeprazole') || name.contains('losectil')) {
      return 'Proton pump inhibitor for acid reflux and stomach ulcers';
    } else if (name.contains('amlodipine') || name.contains('amdocal')) {
      return 'Calcium channel blocker for high blood pressure and chest pain';
    } else if (name.contains('azithromycin') || name.contains('zimax')) {
      return 'Macrolide antibiotic for respiratory and skin infections';
    } else if (name.contains('ciprofloxacin') || name.contains('seclo')) {
      return 'Fluoroquinolone antibiotic for various bacterial infections';
    } else if (name.contains('metronidazole') || name.contains('filmet')) {
      return 'Antibiotic and antiprotozoal medication';
    } else if (name.contains('esomeprazole') || name.contains('maxpro')) {
      return 'Proton pump inhibitor for acid-related stomach conditions';
    } else if (name.contains('calpol')) {
      return 'Gentle pain relief and fever reduction for children and adults';
    } else if (name.contains('napa')) {
      return 'Fast-acting pain relief and fever reduction medication';
    } else {
      return 'Prescription medication for various health conditions';
    }
  }
}
