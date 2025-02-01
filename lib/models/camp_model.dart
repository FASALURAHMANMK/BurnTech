import 'package:cloud_firestore/cloud_firestore.dart';

class CampModel {
  final int id;
  final String name;
  final String description;
  final GeoPoint location;
  final String? imageUrl;
  final List<String>? members;
  final int maxMembers;

  CampModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.members,
    required this.maxMembers,
  });
}
