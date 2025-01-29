class CampModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String? imageUrl;

  CampModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.imageUrl,
  });
}
