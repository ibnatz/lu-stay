import 'package:flutter/material.dart';
import '../services/user_listing_service.dart';
import '../models/user_listing_model.dart';

class UserListingForm extends StatefulWidget {
  final UserListingModel? listing;
  final String userId;
  final String userName;

  const UserListingForm({
    super.key,
    this.listing,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserListingForm> createState() => _UserListingFormState();
}

class _UserListingFormState extends State<UserListingForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedRoomType = 'Single Room';
  String _selectedGender = 'Any';
  final List<String> _selectedAmenities = [];
  bool _isLoading = false;

  final List<String> _locations = [
    'Zindabazar', 'Uposohor', 'Tilagor', 'Shibganj', 'Electric Supply Road'
  ];

  final List<String> _amenitiesList = [
    'WiFi', 'Refrigerator', 'Attached Washroom', 'Attached Balcony',
    'Living Room', 'Privacy', 'Janitor availability'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final listing = widget.listing!;
    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _locationController.text = listing.location;
    _rentController.text = listing.rent.toStringAsFixed(0);
    _imageUrlController.text = listing.imageUrl;
    _selectedRoomType = listing.roomType;
    _selectedGender = listing.genderPreferences;
    _selectedAmenities.addAll(listing.amenities);
  }

  Future<void> _saveListing() async {
    if (_titleController.text.isEmpty || _locationController.text.isEmpty || _rentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final listing = UserListingModel(
        id: widget.listing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
        location: _locationController.text,
        rent: double.parse(_rentController.text),
        roomType: _selectedRoomType,
        genderPreferences: _selectedGender,
        amenities: _selectedAmenities,
        imageUrl: _imageUrlController.text,
        ownerId: widget.userId,
        ownerName: widget.userName,
        createdAt: widget.listing?.createdAt ?? DateTime.now().toIso8601String(),
      );

      final userListingService = UserListingService();

      if (widget.listing == null) {
        await userListingService.createUserListing(listing);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
      } else {
        await userListingService.updateUserListing(listing);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing == null ? 'Create Listing' : 'Edit Listing'),
        backgroundColor: const Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title*'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _locationController.text.isEmpty ? null : _locationController.text,
                decoration: const InputDecoration(labelText: 'Location*'),
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _locationController.text = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rent (৳)*'),
              ),
              const SizedBox(height: 16),

              const Text('Room Type*', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio(
                    value: 'Single Room',
                    groupValue: _selectedRoomType,
                    onChanged: (value) => setState(() => _selectedRoomType = value!),
                  ),
                  const Text('Single Room'),
                  Radio(
                    value: 'Shared Room',
                    groupValue: _selectedRoomType,
                    onChanged: (value) => setState(() => _selectedRoomType = value!),
                  ),
                  const Text('Shared Room'),
                ],
              ),

              const SizedBox(height: 16),
              const Text('Gender Preference', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _selectedGender,
                items: ['Any', 'Male Only', 'Female Only'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),

              const SizedBox(height: 16),
              const Text('Amenities', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenitiesList.map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: _selectedAmenities.contains(amenity),
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

              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL (optional)'),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B6B),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(widget.listing == null ? 'Create Listing' : 'Update Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}