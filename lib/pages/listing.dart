import 'package:flutter/material.dart';

class ListingPage extends StatelessWidget {
  const ListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listing'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Listing Page Content'),
      ),
    );
  }
}