class Accommodation {
  final String id;
  final String title;
  final String genderPreference;
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
    required this.genderPreference,
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
      'genderPreference': genderPreference,
      'location': location,
      'roomType': roomType,
      'rent': rent,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'postedDate': postedDate.toIso8601String(),
    };
  }

  factory Accommodation.fromMap(Map<String, dynamic> map, String documentId) {
    print('Creating Accommodation from map: $map');

    // Handle different data types for rent
    dynamic rentValue = map['rent'];
    double rent = 0.0;
    if (rentValue != null) {
      if (rentValue is int) {
        rent = rentValue.toDouble();
      } else if (rentValue is double) {
        rent = rentValue;
      } else if (rentValue is String) {
        rent = double.tryParse(rentValue) ?? 0.0;
      }
    }

    // Handle postedDate conversion
    DateTime postedDate;
    try {
      postedDate = DateTime.parse(map['postedDate'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      print('Error parsing postedDate: $e, using current date');
      postedDate = DateTime.now();
    }

    // Handle amenities list
    List<String> amenitiesList = [];
    if (map['amenities'] != null) {
      if (map['amenities'] is List) {
        amenitiesList = List<String>.from(map['amenities'] ?? []);
      }
    }

    return Accommodation(
      id: documentId,
      title: map['title']?.toString() ?? 'No Title',
      genderPreference: map['genderPreference']?.toString() ?? 'Any',
      location: map['location']?.toString() ?? 'Unknown Location',
      roomType: map['roomType']?.toString() ?? 'Single Room',
      rent: rent,
      amenities: amenitiesList,
      imageUrl: map['imageUrl']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      postedDate: postedDate,
    );
  }

  @override
  String toString() {
    return 'Accommodation{id: $id, title: $title, location: $location, rent: $rent}';
  }
}