import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/accommodation.dart';

class AccommodationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all accommodations from the 'accomodations' collection from Firestore ~ Ibnat
  Stream<List<Accommodation>> getAllAccommodations() {
    try {
      print('Querying Firestore collection: accomodations');
      return _firestore
          .collection('accomodations')
          .snapshots()
          .handleError((error) {
        print('Firestore error in getAllAccommodations: $error');
        throw error;
      })
          .map((snapshot) {
        print('Firestore query successful: ${snapshot.docs.length} documents found');
        if (snapshot.docs.isEmpty) {
          print('No documents found in accomodations collection');
        }
        return snapshot.docs
            .map((doc) {
          print('Document ID: ${doc.id}, Data: ${doc.data()}');
          return Accommodation.fromMap(doc.data(), doc.id);
        })
            .toList();
      });
    } catch (e) {
      print('Exception in getAllAccommodations: $e');
      rethrow;
    }
  }

  Stream<List<Accommodation>> getFilteredAccommodations({
    String? location,
    String? roomType,
    List<String>? amenities,
  }) {
    return _firestore
        .collection('accomodations')
        .snapshots()
        .map((snapshot) {
      var accommodations = snapshot.docs
          .map((doc) => Accommodation.fromMap(doc.data(), doc.id))
          .toList();

      print('Applying filters to ${accommodations.length} accommodations');
      print('Location filter: $location');
      print('Room type filter: $roomType');
      print('Amenities filter: $amenities');

      // Apply filters
      if (location != null && location.isNotEmpty) {
        accommodations = accommodations
            .where((acc) => acc.location.toLowerCase().contains(location.toLowerCase()))
            .toList();
      }

      if (roomType != null && roomType.isNotEmpty) {
        accommodations = accommodations
            .where((acc) => acc.roomType == roomType)
            .toList();
      }

      if (amenities != null && amenities.isNotEmpty) {
        accommodations = accommodations
            .where((acc) => amenities.every((amenity) => acc.amenities.contains(amenity)))
            .toList();
      }

      print('After filtering: ${accommodations.length} accommodations');
      return accommodations;
    });
  }
}