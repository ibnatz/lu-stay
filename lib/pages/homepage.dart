import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'wish.dart';
import 'listing.dart';
import 'profile.dart';
import 'my_listings.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Navigation state
  int _currentIndex = 0;


  final List<Widget> _pages = [
    const HomeContent(),
    const WishPage(),
    const Listing(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    await _authService.signOut();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(Icons.home, 'Home', 0),
            _buildBottomNavItem(Icons.favorite_outline, 'Wish', 1),
            _buildBottomNavItem(Icons.chat_bubble_outline, 'Listing', 2),
            _buildBottomNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFF6B6B) : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Home Content Widget (Filters)
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String selectedRoomType = '';
  String selectedLocation = '';
  List<String> selectedAmenities = [];

  final List<String> amenitiesList = [
    'WiFi', 'Refrigerator', 'Attached Washroom', 'Attached Balcony',
    'Living Room', 'Privacy', 'Janitor availability'
  ];

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B6B) : Colors.white,
          border: Border.all(
            color: const Color(0xFFFF6B6B),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _applyFilters() {
    // Navigate to Listing page with filters
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Listing(),
        settings: RouteSettings(
          arguments: {
            'location': selectedLocation.isEmpty ? null : selectedLocation,
            'roomType': selectedRoomType.isEmpty ? null : (selectedRoomType == 'Single' ? 'Single Room' : 'Shared Room'),
            'amenities': selectedAmenities.isEmpty ? null : selectedAmenities,
          },
        ),
      ),
    );
  }

  void _navigateToMyListings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyListingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFF6B6B),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),

                      // This now goes to My Listings  ~ Ibnat
                      GestureDetector(
                        onTap: _navigateToMyListings,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(Icons.list, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Section
                _buildSectionTitle('Location'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF6B6B), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLocation.isEmpty ? null : selectedLocation,
                      hint: const Text('Select Location'),
                      isExpanded: true,
                      items: ['Tilagor', 'Shibganj', 'Electric Supply Road', 'Zindabazar', 'Uposhohor', 'Modina Market', 'Akhalia']
                          .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => selectedLocation = value ?? '');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Room Type Section
                _buildSectionTitle('Room Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip('Single Room', selectedRoomType == 'Single', () {
                        setState(() => selectedRoomType = selectedRoomType == 'Single' ? '' : 'Single');
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterChip('Shared Room', selectedRoomType == 'Shared', () {
                        setState(() => selectedRoomType = selectedRoomType == 'Shared' ? '' : 'Shared');
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Amenities Section
                _buildSectionTitle('Amenities'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: amenitiesList.map((amenity) {
                    final isSelected = selectedAmenities.contains(amenity);
                    return _buildFilterChip(amenity, isSelected, () {
                      setState(() {
                        if (isSelected) {
                          selectedAmenities.remove(amenity);
                        } else {
                          selectedAmenities.add(amenity);
                        }
                      });
                    });
                  }).toList(),
                ),
                const SizedBox(height: 40),

                // Apply Filters Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}