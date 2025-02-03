import 'package:burn_tech/models/art_model.dart';
import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Call this to fetch and cache user data
  Future<void> fetchUser(String uid) async {
  if (uid.isEmpty) {
    _error = "User ID is empty";
    notifyListeners();
    return;
  }

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception("User does not exist");
    }

    final data = doc.data()!;
    _user = UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      profileImage: data['profileImage'],
      favCamps: List<String>.from(data['favCamps'] ?? []),
      campTokens: List<String>.from(data['campTokens'] ?? []),
      favArts: List<String>.from(data['favArts'] ?? []),
      artTokens: List<String>.from(data['artTokens'] ?? []),
    );
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// Toggle favorite camp in Firestore
  Future<void> toggleFavorite(CampModel camp) async {
    if (_user == null) return;

    final currentFavCamps = _user!.favCamps ?? [];
    final campIdString = camp.uid.toString();
    bool isCurrentlyFav = currentFavCamps.contains(campIdString);

    // Locally update
    List<String> updatedFavCamps = List.from(currentFavCamps);
    if (isCurrentlyFav) {
      updatedFavCamps.remove(campIdString);
    } else {
      updatedFavCamps.add(campIdString);
    }

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'favCamps': updatedFavCamps});

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        profileImage: _user!.profileImage,
        favCamps: updatedFavCamps,
        campTokens: _user!.campTokens,
        favArts: _user!.favArts,
        artTokens: _user!.artTokens,
      );
      notifyListeners();
    } catch (e) {
      // In case of error, you might revert the change or show an error
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<void> updateTokens(CampModel camp) async {
    if (_user == null) return;

    final currentTokens = _user!.campTokens ?? [];
    final campIdString = camp.uid.toString();
    bool isHaveToken = currentTokens.contains(campIdString);

    // Locally update
    List<String> updatedTokens = List.from(currentTokens);
    if (isHaveToken) {
  updatedTokens.remove(campIdString);
} else {
  updatedTokens.add(campIdString);
}

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'campTokens': updatedTokens});

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        profileImage: _user!.profileImage,
        favCamps: _user!.favCamps,
        campTokens: updatedTokens,
        favArts: _user!.favArts,
        artTokens: _user!.artTokens,
      );
      notifyListeners();
    } catch (e) {
      // In case of error, you might revert the change or show an error
      _error = e.toString();
      notifyListeners();
    }
  }
   Future<void> toggleArtFavorite(ArtModel art) async {
    if (_user == null) return;

    final currentFavArts = _user!.favArts ?? [];
    final artIdString = art.uid.toString();
    bool isCurrentlyFav = currentFavArts.contains(artIdString);

    // Locally update
    List<String> updatedFavArts = List.from(currentFavArts);
    if (isCurrentlyFav) {
      updatedFavArts.remove(artIdString);
    } else {
      updatedFavArts.add(artIdString);
    }

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'favArts': updatedFavArts});

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        profileImage: _user!.profileImage,
        favCamps: _user!.favCamps,
        campTokens: _user!.campTokens,
        favArts: updatedFavArts,
        artTokens: _user!.artTokens,
      );
      notifyListeners();
    } catch (e) {
      // In case of error, you might revert the change or show an error
      _error = e.toString();
      notifyListeners();
    }
  }
  Future<void> updateArtTokens(ArtModel art) async {
    if (_user == null) return;

    final currentArtTokens = _user!.artTokens ?? [];
    final artIdString = art.uid.toString();
    bool isHaveToken = currentArtTokens.contains(artIdString);

    // Locally update
    List<String> updatedArtTokens = List.from(currentArtTokens);
    if (isHaveToken) {
      updatedArtTokens.remove(artIdString);
    } else {
      updatedArtTokens.add(artIdString);
    }

    // Update Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'artTokens': updatedArtTokens});

      // Update local user model
      _user = UserModel(
        uid: _user!.uid,
        name: _user!.name,
        email: _user!.email,
        profileImage: _user!.profileImage,
        favCamps: _user!.favCamps,
        campTokens: _user!.campTokens,
        favArts: _user!.favArts,
        artTokens: updatedArtTokens,
      );
      notifyListeners();
    } catch (e) {
      // In case of error, you might revert the change or show an error
      _error = e.toString();
      notifyListeners();
    }
  }
}