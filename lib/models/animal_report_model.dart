enum AnimalCondition {
  injured,
  sick,
  lost,
  abandoned,
  trapped,
  aggressive,
  dead,
  other,
}

enum ReportStatus {
  reported,
  inProgress,
  rescued,
  closed,
}

enum AnimalType {
  dog,
  cat,
  bird,
  wildlife,
  livestock,
  other,
}

class AnimalReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String title;
  final String description;
  final AnimalType animalType;
  final String? animalBreed;
  final AnimalCondition condition;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> imageUrls;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedVolunteerId;
  final String? assignedVolunteerName;
  final bool isEmergency;
  final String? contactPhone;
  final String? contactName;
  final String? rescueOrganization;
  final String? rescueContact;
  final String? rescueNotes;
  final List<String> tags;
  final int helpersCount;
  final List<String> helperIds;
  
  AnimalReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.title,
    required this.description,
    required this.animalType,
    this.animalBreed,
    required this.condition,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrls = const [],
    this.status = ReportStatus.reported,
    required this.createdAt,
    required this.updatedAt,
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    this.isEmergency = false,
    this.contactPhone,
    this.contactName,
    this.rescueOrganization,
    this.rescueContact,
    this.rescueNotes,
    this.tags = const [],
    this.helpersCount = 0,
    this.helperIds = const [],
  });
  
  factory AnimalReportModel.fromJson(Map<String, dynamic> json) {
    return AnimalReportModel(
      id: json['id'] ?? '',
      reporterId: json['reporter_id'] ?? '',
      reporterName: json['reporter_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      animalType: AnimalType.values.firstWhere(
        (e) => e.toString().split('.').last == json['animal_type'],
        orElse: () => AnimalType.other,
      ),
      animalBreed: json['animal_breed'],
      condition: AnimalCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['condition'],
        orElse: () => AnimalCondition.other,
      ),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ReportStatus.reported,
      ),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      assignedVolunteerId: json['assigned_volunteer_id'],
      assignedVolunteerName: json['assigned_volunteer_name'],
      isEmergency: json['is_emergency'] ?? false,
      contactPhone: json['contact_phone'],
      contactName: json['contact_name'],
      rescueOrganization: json['rescue_organization'],
      rescueContact: json['rescue_contact'],
      rescueNotes: json['rescue_notes'],
      tags: List<String>.from(json['tags'] ?? []),
      helpersCount: json['helpers_count'] ?? 0,
      helperIds: List<String>.from(json['helper_ids'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id.isEmpty ? null : id,
      'reporter_id': reporterId.isEmpty ? null : reporterId,
      'reporter_name': reporterName,
      'title': title,
      'description': description,
      'animal_type': animalType.toString().split('.').last,
      'animal_breed': animalBreed,
      'condition': condition.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'image_urls': imageUrls,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'assigned_volunteer_id': (assignedVolunteerId?.isEmpty ?? true) ? null : assignedVolunteerId,
      'assigned_volunteer_name': assignedVolunteerName,
      'is_emergency': isEmergency,
      'contact_phone': contactPhone,
      'contact_name': contactName,
      'rescue_organization': rescueOrganization,
      'rescue_contact': rescueContact,
      'rescue_notes': rescueNotes,
      'tags': tags,
      'helpers_count': helpersCount,
      'helper_ids': helperIds,
    };
  }
  
  AnimalReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? title,
    String? description,
    AnimalType? animalType,
    String? animalBreed,
    AnimalCondition? condition,
    double? latitude,
    double? longitude,
    String? address,
    List<String>? imageUrls,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedVolunteerId,
    String? assignedVolunteerName,
    bool? isEmergency,
    String? contactPhone,
    String? contactName,
    String? rescueOrganization,
    String? rescueContact,
    String? rescueNotes,
    List<String>? tags,
    int? helpersCount,
    List<String>? helperIds,
  }) {
    return AnimalReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      title: title ?? this.title,
      description: description ?? this.description,
      animalType: animalType ?? this.animalType,
      animalBreed: animalBreed ?? this.animalBreed,
      condition: condition ?? this.condition,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
      assignedVolunteerName: assignedVolunteerName ?? this.assignedVolunteerName,
      isEmergency: isEmergency ?? this.isEmergency,
      contactPhone: contactPhone ?? this.contactPhone,
      contactName: contactName ?? this.contactName,
      rescueOrganization: rescueOrganization ?? this.rescueOrganization,
      rescueContact: rescueContact ?? this.rescueContact,
      rescueNotes: rescueNotes ?? this.rescueNotes,
      tags: tags ?? this.tags,
      helpersCount: helpersCount ?? this.helpersCount,
      helperIds: helperIds ?? this.helperIds,
    );
  }
  
  String get animalTypeDisplayName {
    switch (animalType) {
      case AnimalType.dog:
        return 'Dog';
      case AnimalType.cat:
        return 'Cat';
      case AnimalType.bird:
        return 'Bird';
      case AnimalType.wildlife:
        return 'Wildlife';
      case AnimalType.livestock:
        return 'Livestock';
      case AnimalType.other:
        return 'Other';
    }
  }
  
  String get conditionDisplayName {
    switch (condition) {
      case AnimalCondition.injured:
        return 'Injured';
      case AnimalCondition.sick:
        return 'Sick';
      case AnimalCondition.lost:
        return 'Lost';
      case AnimalCondition.abandoned:
        return 'Abandoned';
      case AnimalCondition.trapped:
        return 'Trapped';
      case AnimalCondition.aggressive:
        return 'Aggressive';
      case AnimalCondition.dead:
        return 'Dead';
      case AnimalCondition.other:
        return 'Other';
    }
  }
  
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.reported:
        return 'Reported';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.rescued:
        return 'Rescued';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}