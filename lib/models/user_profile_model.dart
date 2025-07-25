class UserProfileModel {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? profileImageUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isVolunteer;
  final List<String> skills;
  final int reportsCount;
  final int helpedAnimalsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final String? bio;
  final List<String> emergencyContacts;
  
  UserProfileModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.profileImageUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.isVolunteer = false,
    this.skills = const [],
    this.reportsCount = 0,
    this.helpedAnimalsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.bio,
    this.emergencyContacts = const [],
  });
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isVolunteer: json['is_volunteer'] ?? false,
      skills: List<String>.from(json['skills'] ?? []),
      reportsCount: json['reports_count'] ?? 0,
      helpedAnimalsCount: json['helped_animals_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      isVerified: json['is_verified'] ?? false,
      bio: json['bio'],
      emergencyContacts: List<String>.from(json['emergency_contacts'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_volunteer': isVolunteer,
      'skills': skills,
      'reports_count': reportsCount,
      'helped_animals_count': helpedAnimalsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_verified': isVerified,
      'bio': bio,
      'emergency_contacts': emergencyContacts,
    };
  }
  
  UserProfileModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    String? address,
    double? latitude,
    double? longitude,
    bool? isVolunteer,
    List<String>? skills,
    int? reportsCount,
    int? helpedAnimalsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? bio,
    List<String>? emergencyContacts,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVolunteer: isVolunteer ?? this.isVolunteer,
      skills: skills ?? this.skills,
      reportsCount: reportsCount ?? this.reportsCount,
      helpedAnimalsCount: helpedAnimalsCount ?? this.helpedAnimalsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
    );
  }
  
  String get displayName => name ?? email.split('@')[0];
  
  String get volunteerStatus => isVolunteer ? 'Volunteer' : 'Reporter';
  
  bool get hasLocation => latitude != null && longitude != null;
}