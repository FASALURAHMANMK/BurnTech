import 'package:burn_tech/models/camp_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CampProvider extends ChangeNotifier {
  List<CampModel> _camps = [];
  List<CampModel> get camps => _camps;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchCamps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('camps').get();
      _camps = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return CampModel(
          id: data['id'],
          name: data['name'],
          description: data['description'],
          location: data['location'],
          imageUrl: data['imageUrl'],
          members: data['members'] != null ? List<String>.from(data['members']) : [],
          maxMembers: data['maxMembers'],
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}