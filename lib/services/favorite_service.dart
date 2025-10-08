import 'package:flutter/foundation.dart';

class FavoriteService with ChangeNotifier {
  final List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  void toggleFavorite(String accommodationId) {
    if (_favoriteIds.contains(accommodationId)) {
      _favoriteIds.remove(accommodationId);
    } else {
      _favoriteIds.add(accommodationId);
    }
    notifyListeners();
  }

  bool isFavorite(String accommodationId) {
    return _favoriteIds.contains(accommodationId);
  }
}