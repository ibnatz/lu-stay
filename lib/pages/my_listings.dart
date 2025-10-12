import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_listing_service.dart';
import '../services/auth_service.dart';
import '../models/user_listing_model.dart';
import 'user_listing_form.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final UserListingService _userListingService = UserListingService();

  void _editListing(UserListingModel listing) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserListingForm(
          listing: listing,
          userId: user?['uid'] ?? '',
          userName: user?['fullName'] ?? 'User',
        ),
      ),
    );
  }

  void _deleteListing(String listingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _userListingService.deleteUserListing(listingId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final userId = user?['uid'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserListingForm(
                    userId: userId,
                    userName: user?['fullName'] ?? 'User',
                  ),
                ),
              );
            },
            tooltip: 'Create New Listing',
          ),
        ],
      ),
      body: StreamBuilder<List<UserListingModel>>(
        stream: _userListingService.getUserListingsByOwner(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the + button to create your first listing',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final listings = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _buildListingCard(listing);
            },
          );
        },
      ),
    );
  }

  Widget _buildListingCard(UserListingModel listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editListing(listing);
                    } else if (value == 'delete') {
                      _deleteListing(listing.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  listing.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '৳${listing.rent.toStringAsFixed(0)}/month',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(listing.roomType, Icons.bed),
                const SizedBox(width: 8),
                _buildChip(listing.genderPreferences, Icons.person),
              ],
            ),
            if (listing.amenities.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: listing.amenities.take(3).map((amenity) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      amenity,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFFF6B6B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF6B6B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFFF6B6B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}