import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'listing.dart';
import '../services/accommodation_service.dart';
import '../models/accommodation.dart';
import '../services/favorite_service.dart';

class WishPage extends StatefulWidget {
  const WishPage({super.key});

  @override
  State<WishPage> createState() => _WishPageState();
}

class _WishPageState extends State<WishPage> {
  final AccommodationService _accommodationService = AccommodationService();
  List<Accommodation> _favoriteAccommodations = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final favoriteService = Provider.of<FavoriteService>(context, listen: false);

    _accommodationService.getAllAccommodations().listen((accommodations) {
      setState(() {
        _favoriteAccommodations = accommodations
            .where((acc) => favoriteService.isFavorite(acc.id))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteService = Provider.of<FavoriteService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFF6B6B)),
      ),
      backgroundColor: Colors.white,
      body: _favoriteAccommodations.isEmpty
          ? _buildEmptyState()
          : _buildWishList(favoriteService),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Save accommodations you like\nby tapping the heart icon',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildWishList(FavoriteService favoriteService) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteAccommodations.length,
      itemBuilder: (context, index) {
        final accommodation = _favoriteAccommodations[index];
        return _buildAccommodationCard(accommodation, favoriteService);
      },
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation, FavoriteService favoriteService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: accommodation.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      accommodation.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.home_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  )
                      : Icon(
                    Icons.home_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accommodation.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accommodation.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳${accommodation.rent.toStringAsFixed(0)}/month',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => favoriteService.toggleFavorite(accommodation.id),
                  icon: const Icon(
                    Icons.favorite,
                    color: Color(0xFFFF6B6B),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'View Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}