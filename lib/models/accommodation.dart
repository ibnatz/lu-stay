class Accommodation {
  final String id;
  final String title;
  final String genderPreferences;
  final String location;
  final String roomType;
  final double rent;
  final List<String> amenities;
  final String imageUrl;
  final String ownerId;
  final DateTime postedDate;

  Accommodation({
    required this.id,
    required this.title,
    required this.genderPreferences,
    required this.location,
    required this.roomType,
    required this.rent,
    required this.amenities,
    required this.imageUrl,
    required this.ownerId,
    required this.postedDate,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'gender': genderPreferences,
      'location': location,
      'roomType': roomType,
      'rentAmount': rent,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'postedDate': postedDate.toIso8601String(),
    };
  }


  factory Accommodation.fromMap(Map<String, dynamic> map) {
    return Accommodation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      genderPreferences: map['genderPreferences'] ?? '',
      location: map['location'] ?? '',
      roomType: map['roomType'] ?? '',
      rent: (map['rent'] ?? 0).toDouble(),
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrl: map['imageUrl'] ?? '',
      ownerId: map['ownerId'] ?? '',
      postedDate: DateTime.parse(map['postedDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}