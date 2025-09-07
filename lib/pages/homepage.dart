import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'wish.dart';
import 'listing.dart';
import 'profile.dart';

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

  // Filter states
  String selectedGender = '';
  String selectedAccommodationType = '';
  String selectedRoomType = '';
  String selectedLocation = '';
  RangeValues rentRange = const RangeValues(0, 10000);
  List<String> selectedAmenities = [];

  final List<String> amenitiesList = [
    'WiFi', 'Refrigerator', 'Attached Washroom', 'Attached Balcony',
    'Living Room', 'Privacy', 'Janitor availability'
  ];

  // Define your pages here - UPDATE THESE TO USE ACTUAL PAGES
  final List<Widget> _pages = [
    const HomeContent(), // Your main filters content
    const WishPage(), // Wish page
    const ListingPage(), // Updated to use actual ListingPage
    const ProfilePage(), // Updated to use actual ProfilePage
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
  String selectedGender = '';
  String selectedRoomType = '';
  String selectedLocation = '';
  RangeValues rentRange = const RangeValues(0, 10000);
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters applied successfully!'),
        backgroundColor: Color(0xFFFF6B6B),
      ),
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
                      GestureDetector(
                        onTap: () async {
                          // Add sign out functionality here
                          final AuthService authService = AuthService();
                          await authService.signOut();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(Icons.logout, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.arrow_back_ios, color: Colors.white),
                      const SizedBox(width: 10),
                      const Text(
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
                _buildSectionTitle('Gender Preference'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterChip('Male', selectedGender == 'Male', () {
                        setState(() => selectedGender = selectedGender == 'Male' ? '' : 'Male');
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterChip('Female', selectedGender == 'Female', () {
                        setState(() => selectedGender = selectedGender == 'Female' ? '' : 'Female');
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
                      items: ['Tilagor', 'Shibganj', 'Chowhatta', 'Amborkhana', 'Zindabazar', 'Uposhohor', 'Modina Market', 'Kazitula', 'Akhalia']
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
                _buildSectionTitle('Rent Range'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('৳${rentRange.start.round()}'),
                          Text('৳${rentRange.end.round()}'),
                        ],
                      ),
                      RangeSlider(
                        values: rentRange,
                        max: 20000,
                        divisions: 40,
                        activeColor: const Color(0xFFFF6B6B),
                        labels: RangeLabels(
                          '৳${rentRange.start.round()}',
                          '৳${rentRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setState(() => rentRange = values);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
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