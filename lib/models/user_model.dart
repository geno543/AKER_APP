class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isVolunteer;
  final List<String> volunteerPreferences;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int rescueCount;
  final double rating;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.profileImageUrl,
    this.isVolunteer = false,
    this.volunteerPreferences = const [],
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.rescueCount = 0,
    this.rating = 0.0,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'],
      profileImageUrl: json['profile_image_url'],
      isVolunteer: json['is_volunteer'] ?? false,
      volunteerPreferences: List<String>.from(json['volunteer_preferences'] ?? []),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      rescueCount: json['rescue_count'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image_url': profileImageUrl,
      'is_volunteer': isVolunteer,
      'volunteer_preferences': volunteerPreferences,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rescue_count': rescueCount,
      'rating': rating,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isVolunteer,
    List<String>? volunteerPreferences,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rescueCount,
    double? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      volunteerPreferences: volunteerPreferences ?? this.volunteerPreferences,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rescueCount: rescueCount ?? this.rescueCount,
      rating: rating ?? this.rating,
    );
  }
}