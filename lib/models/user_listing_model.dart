class UserListingModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final double rent;
  final String roomType;
  final String genderPreferences;
  final List<String> amenities;
  final String imageUrl;
  final String ownerId;
  final String ownerName;
  final String createdAt;

  UserListingModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.rent,
    required this.roomType,
    required this.genderPreferences,
    required this.amenities,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'rent': rent,
      'roomType': roomType,
      'genderPreferences': genderPreferences,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'createdAt': createdAt,
    };
  }

  factory UserListingModel.fromMap(Map<String, dynamic> map) {
    return UserListingModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      rent: (map['rent'] ?? 0).toDouble(),
      roomType: map['roomType'] ?? '',
      genderPreferences: map['genderPreferences'] ?? '',
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  UserListingModel copyWith({
    String? title,
    String? description,
    String? location,
    double? rent,
    String? roomType,
    String? genderPreferences,
    List<String>? amenities,
    String? imageUrl,
  }) {
    return UserListingModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      rent: rent ?? this.rent,
      roomType: roomType ?? this.roomType,
      genderPreferences: genderPreferences ?? this.genderPreferences,
      amenities: amenities ?? this.amenities,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId,
      ownerName: ownerName,
      createdAt: createdAt,
    );
  }
}