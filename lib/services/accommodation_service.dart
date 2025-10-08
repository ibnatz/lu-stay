import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/accommodation.dart';

class AccommodationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'accomodations';

  Stream<List<Accommodation>> getAllAccommodations() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Accommodation.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<Accommodation>> getFilteredAccommodations({
    String? genderPreferences,
    String? location,
    String? roomType,
    List<String>? amenities,
  }) {
    return getAllAccommodations().map((accommodations) {
      return accommodations.where((accommodation) {
        // Start with true and apply AND logic for each active filter
        bool matches = true;

        // Gender filter - only apply if filter is selected
        if (genderPreferences != null && genderPreferences.isNotEmpty) {
          matches = matches && accommodation.genderPreferences == genderPreferences;
        }

        // Location filter - only apply if filter is selected
        if (location != null && location.isNotEmpty) {
          matches = matches && accommodation.location == location;
        }

        // Room Type filter - only apply if filter is selected
        if (roomType != null && roomType.isNotEmpty) {
          matches = matches && accommodation.roomType == roomType;
        }

        // Amenities filter - ALL selected amenities must be present
        if (amenities != null && amenities.isNotEmpty) {
          for (String amenity in amenities) {
            if (!accommodation.amenities.contains(amenity)) {
              matches = false;
              break;
            }
          }
        }

        return matches;
      }).toList();
    });
  }

  Future<void> addAccommodation(Accommodation accommodation) async {
    await _firestore
        .collection(_collectionName)
        .doc(accommodation.id)
        .set(accommodation.toMap());
  }

  Future<void> updateAccommodation(Accommodation accommodation) async {
    await _firestore
        .collection(_collectionName)
        .doc(accommodation.id)
        .update(accommodation.toMap());
  }

  Future<void> deleteAccommodation(String accommodationId) async {
    await _firestore
        .collection(_collectionName)
        .doc(accommodationId)
        .delete();
  }
}