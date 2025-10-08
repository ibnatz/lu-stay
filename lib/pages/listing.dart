import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/accommodation_service.dart';
import '../models/accommodation.dart';
import '../services/favorite_service.dart';

class Listing extends StatefulWidget {
  const Listing({super.key});

  @override
  State<Listing> createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  final AccommodationService _accommodationService = AccommodationService();

  // Filter parameters
  String? filterLocation;
  String? filterRoomType;
  List<String>? filterAmenities;
  bool filtersApplied = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get filter arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        filterLocation = args['location'];
        filterRoomType = args['roomType'];
        filterAmenities = args['amenities'];
        filtersApplied = _areFiltersApplied(args);
      });
    }
  }

  bool _areFiltersApplied(Map<String, dynamic> filters) {
    return filters['location'] != null ||
        filters['roomType'] != null ||
        (filters['amenities'] != null && filters['amenities'].isNotEmpty);
  }

  void _clearFilters() {
    setState(() {
      filterLocation = null;
      filterRoomType = null;
      filterAmenities = null;
      filtersApplied = false;
    });
  }

  void _applyFilters(Map<String, dynamic> newFilters) {
    setState(() {
      filterLocation = newFilters['location'];
      filterRoomType = newFilters['roomType'];
      filterAmenities = newFilters['amenities'];
      filtersApplied = _areFiltersApplied(newFilters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Accommodations'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'Apply Filters',
          ),
          if (filtersApplied)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body: StreamBuilder<List<Accommodation>>(
        stream: filtersApplied
            ? _accommodationService.getFilteredAccommodations(
          location: filterLocation,
          roomType: filterRoomType,
          amenities: filterAmenities,
        )
            : _accommodationService.getAllAccommodations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    filtersApplied
                        ? 'No accommodations match your filters'
                        : 'No accommodations available yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  if (filtersApplied) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                      ),
                      child: const Text('Clear Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            );
          }

          final accommodations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accommodations.length,
            itemBuilder: (context, index) {
              final accommodation = accommodations[index];
              return _buildAccommodationCard(accommodation, context);
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentFilters: {
          'location': filterLocation,
          'roomType': filterRoomType,
          'amenities': filterAmenities,
        },
        onApplyFilters: _applyFilters,
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation, BuildContext context) {
    final favoriteService = Provider.of<FavoriteService>(context);
    bool isFavorite = favoriteService.isFavorite(accommodation.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to detail page
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: accommodation.imageUrl.isNotEmpty
                        ? Image.network(
                      accommodation.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                        : _buildPlaceholderImage(),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        accommodation.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              accommodation.location,
                              style: TextStyle(color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rent
                      Text(
                        '৳${accommodation.rent.toStringAsFixed(0)}/month',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Room type and Gender
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(accommodation.roomType, Icons.bed),
                          _buildChip(accommodation.genderPreferences, Icons.person),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Amenities
                      if (accommodation.amenities.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: accommodation.amenities.take(3).map((amenity) {
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
                  ),
                ),
              ],
            ),

            // Heart Icon in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFFF6B6B) : Colors.grey[600],
                  ),
                  onPressed: () => favoriteService.toggleFavorite(accommodation.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 40, color: Colors.grey[500]),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
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

class FilterDialog extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterDialog({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedLocation;
  String? _selectedRoomType;
  List<String> _selectedAmenities = [];

  final List<String> _locations = [
    'Zindabazar',
    'Uposohor',
    'Tilagor',
    'Shibganj',
  ];

  final List<String> _amenitiesList = [
    'WiFi',
    'Refrigerator',
    'Attached Washroom',
    'Attached Balcony',
    'Living Room',
    'Privacy',
    'Janitor availability',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current filters
    _selectedLocation = widget.currentFilters['location'];
    _selectedRoomType = widget.currentFilters['roomType'];
    _selectedAmenities = widget.currentFilters['amenities'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_list, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location
                    _buildSectionHeader('Location'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLocation,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text('Select Location'),
                        items: _locations
                            .map((location) => DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedLocation = value),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Room Type
                    _buildSectionHeader('Room Type'),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildRoomTypeChip('Single Room'),
                        _buildRoomTypeChip('Shared Room'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amenities
                    _buildSectionHeader('Amenities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _amenitiesList.map((amenity) {
                        return FilterChip(
                          label: Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 12,
                              color: _selectedAmenities.contains(amenity)
                                  ? Colors.white
                                  : const Color(0xFFFF6B6B),
                            ),
                          ),
                          selected: _selectedAmenities.contains(amenity),
                          selectedColor: const Color(0xFFFF6B6B),
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _selectedAmenities.contains(amenity)
                                  ? const Color(0xFFFF6B6B)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAmenities.add(amenity);
                              } else {
                                _selectedAmenities.remove(amenity);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Clear all filters
                        setState(() {
                          _selectedLocation = null;
                          _selectedRoomType = null;
                          _selectedAmenities = [];
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B6B),
                        side: const BorderSide(color: Color(0xFFFF6B6B)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters({
                          'location': _selectedLocation,
                          'roomType': _selectedRoomType,
                          'amenities': _selectedAmenities,
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRoomTypeChip(String roomType) {
    return ChoiceChip(
      label: Text(roomType),
      selected: _selectedRoomType == roomType,
      selectedColor: const Color(0xFFFF6B6B),
      labelStyle: TextStyle(
        color: _selectedRoomType == roomType ? Colors.white : const Color(0xFFFF6B6B),
        fontSize: 12,
      ),
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _selectedRoomType == roomType
              ? const Color(0xFFFF6B6B)
              : Colors.grey[300]!,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedRoomType = selected ? roomType : null;
        });
      },
    );
  }
}