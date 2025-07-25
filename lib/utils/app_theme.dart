import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Earthy tones with vibrant accents
  static const Color primaryGreen = Color(0xFF228B22);  // Forest Green
  static const Color primaryBrown = Color(0xFF8B4513);  // Saddle Brown
  static const Color accentOrange = Color(0xFFFF6347);  // Tomato
  static const Color softBlue = Color(0xFF87CEEB);      // Sky Blue
  static const Color darkGreen = Color(0xFF2F4F4F);     // Dark Slate Gray
  static const Color lightGreen = Color(0xFF9ACD32);    // Yellow Green
  static const Color cream = Color(0xFFF5F5DC);         // Beige
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  
  // Emergency/Alert Colors
  static const Color emergencyRed = Color(0xFFDC143C);  // Crimson
  static const Color warningAmber = Color(0xFFFFC107);  // Amber
  static const Color successGreen = Color(0xFF4CAF50);  // Green
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: accentOrange,
        surface: white,
        error: emergencyRed,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      // bottomNavigationBarTheme: Removed due to deprecated parameters
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: white,
        elevation: 6,
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: emergencyRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkGreen,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: black,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: black,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: grey,
        ),
      ),
    );
  }
}

class AppConstants {
  // App Information
  static const String appName = 'Aker';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String supabaseUrl = 'https://cezshuxllgyxbyaogsob.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // To be replaced
  
  // Map Configuration
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // To be replaced
  static const double defaultLatitude = -1.2921; // Nairobi, Kenya
  static const double defaultLongitude = 36.8219;
  static const double mapZoom = 14.0;
  static const double searchRadius = 10.0; // km
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Notification Configuration
  static const String fcmTopic = 'animal_rescue_alerts';
  
  // Animal Categories
  static const List<String> animalCategories = [
    'Dog',
    'Cat',
    'Bird',
    'Wildlife',
    'Livestock',
    'Other',
  ];
  
  // Emergency Conditions
  static const List<String> emergencyConditions = [
    'Injured',
    'Sick',
    'Lost',
    'Abandoned',
    'Trapped',
    'Other',
  ];
  
  // App Strings
  static const String reportAnimalTitle = 'Report Animal in Need';
  static const String findHelpTitle = 'Find Help Nearby';
  static const String chatbotTitle = 'AI Assistant';
  static const String profileTitle = 'My Profile';
  static const String mapTitle = 'Rescue Map';
}