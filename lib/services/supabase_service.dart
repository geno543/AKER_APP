import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_report_model.dart';
import '../models/user_model.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Authentication methods
  static Future<AuthResponse> signUp(String email, String password, {String? name}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }
  
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  static Future<void> resendConfirmationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }
  
  // Create user profile
  static Future<void> createUserProfile(String userId, String name) async {
    try {
      await _client.from('user_profiles').insert({
        'id': userId,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }
  
  // Animal report methods
  static Future<List<AnimalReportModel>> getRecentReports({int limit = 10}) async {
    try {
      final response = await _client
          .from('animal_reports')
          .select('*')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((report) => AnimalReportModel.fromJson(report))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }
  
  static Future<List<AnimalReportModel>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Using direct query instead of PostGIS function (fallback approach)
      final response = await _client
          .from('animal_reports')
          .select('''
            id,
            reporter_id,
            title,
            description,
            animal_type,
            animal_breed,
            condition,
            latitude,
            longitude,
            address,
            image_urls,
            status,
            is_emergency,
            contact_phone,
            contact_name,
            assigned_volunteer_id,
            assigned_volunteer_name,
            rescue_organization,
            rescue_contact,
            rescue_notes,
            tags,
            helpers_count,
            helper_ids,
            created_at,
            updated_at
          ''')
          .order('created_at', ascending: false);
      
      // Convert response and filter by distance
      final List<Map<String, dynamic>> filteredReports = [];
      
      for (final item in response as List) {
        final data = Map<String, dynamic>.from(item);
        final reportLat = data['latitude'] as double;
        final reportLng = data['longitude'] as double;
        
        // Simple distance calculation (approximate)
        final latDiff = (latitude - reportLat).abs();
        final lngDiff = (longitude - reportLng).abs();
        final distance = (latDiff * latDiff + lngDiff * lngDiff);
        
        // Rough approximation: 1 degree ≈ 111 km
        final maxDistance = (radiusKm / 111) * (radiusKm / 111);
        
        if (distance <= maxDistance) {
           data['reporter_name'] = 'Anonymous'; // Will be populated from user_profiles separately if needed
           filteredReports.add(data);
         }
      }
      
      return filteredReports
          .map((report) => AnimalReportModel.fromJson(report))
          .toList();
    } catch (e) {
      print('Error fetching nearby reports: $e');
      return [];
    }
  }
  
  static Future<String?> createReport(AnimalReportModel report) async {
    try {
      final response = await _client
          .from('animal_reports')
          .insert(report.toJson())
          .select()
          .single();
      
      return response['id'];
    } catch (e) {
      print('Error creating report: $e');
      return null;
    }
  }
  
  static Future<bool> updateReport(String id, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('animal_reports')
          .update(updates)
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error updating report: $e');
      return false;
    }
  }
  
  // User profile methods
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
  
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('user_profiles')
          .upsert({
            'id': userId,
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          });
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
  
  // File upload methods
  static Future<String?> uploadImage(XFile imageFile, String fileName) async {
    try {
      // Generate unique filename to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_${fileName.split('.').first}.$extension';
      
      // Read image as bytes for web compatibility
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      await _client.storage
          .from('animal-images')
          .uploadBinary(uniqueFileName, imageBytes);
      
      return _client.storage
          .from('animal-images')
          .getPublicUrl(uniqueFileName);
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // Real-time subscriptions
  static RealtimeChannel subscribeToReports(Function(List<AnimalReportModel>) onUpdate) {
    return _client
        .channel('animal_reports')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'animal_reports',
          callback: (payload) async {
            final reports = await getRecentReports();
            onUpdate(reports);
          },
        )
        .subscribe();
  }
  
  // Statistics methods
  static Future<Map<String, int>> getStatistics() async {
    try {
      final totalReports = await _client
          .from('animal_reports')
          .select('id')
          .count(CountOption.exact);
      
      final rescuedAnimals = await _client
          .from('animal_reports')
          .select('id')
          .eq('status', 'rescued')
          .count(CountOption.exact);
      
      final activeReports = await _client
          .from('animal_reports')
          .select('id')
          .eq('status', 'active')
          .count(CountOption.exact);
      
      return {
        'total_reports': totalReports.count ?? 0,
        'rescued_animals': rescuedAnimals.count ?? 0,
        'active_reports': activeReports.count ?? 0,
      };
    } catch (e) {
      print('Error fetching statistics: $e');
      return {
        'total_reports': 0,
        'rescued_animals': 0,
        'active_reports': 0,
      };
    }
  }
}