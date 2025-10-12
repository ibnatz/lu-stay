import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_listing_model.dart';

class UserListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserListingModel>> getUserListingsByOwner(String ownerId) {
    return _firestore
        .collection('user_listings')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .handleError((error) {
      print('Firestore error in getUserListingsByOwner: $error');
      throw error;
    })
        .map((snapshot) {
      print('User listings query successful: ${snapshot.docs.length} documents');
      return snapshot.docs
          .map((doc) => UserListingModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Create new user listing
  Future<void> createUserListing(UserListingModel listing) async {
    await _firestore
        .collection('user_listings')
        .doc(listing.id)
        .set(listing.toMap());
  }

  // Update user listing
  Future<void> updateUserListing(UserListingModel listing) async {
    await _firestore
        .collection('user_listings')
        .doc(listing.id)
        .update(listing.toMap());
  }

  // Delete user listing
  Future<void> deleteUserListing(String listingId) async {
    await _firestore
        .collection('user_listings')
        .doc(listingId)
        .delete();
  }
}