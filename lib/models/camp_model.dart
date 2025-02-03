class CampModel {
  final String? uid;
  final String? name;
  final int? year;
  final String? url;
  final String? contactEmail;
  final String? hometown;
  final String? description;
  final String? landmark;
  final String? locationString;
  final double? latitude;
  final double? longitude;

  CampModel({
    this.uid,
    this.name,
    this.year,
    this.url,
    this.contactEmail,
    this.hometown,
    this.description,
    this.landmark,
    this.locationString,
    this.latitude,
    this.longitude,
  });

  factory CampModel.fromJson(Map<String, dynamic> json) {
    double? lat;
    double? lng;

    // Retrieve and convert latitude
    if (json.containsKey('latitude') && json['latitude'] != null) {
      final latValue = json['latitude'];
      if (latValue is num) {
        lat = latValue.toDouble();
      } else if (latValue is String) {
        lat = double.tryParse(latValue);
      }
    }

    // Retrieve and convert longitude
    if (json.containsKey('longitude') && json['longitude'] != null) {
      final lngValue = json['longitude'];
      if (lngValue is num) {
        lng = lngValue.toDouble();
      } else if (lngValue is String) {
        lng = double.tryParse(lngValue);
      }
    }

    // Optionally, you can print out the values for debugging.
    // print('Parsed latitude: $lat, longitude: $lng');

    return CampModel(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse(json['year']?.toString() ?? ''),
      url: json['url'] as String?,
      contactEmail: json['contact_email'] as String?,
      hometown: json['hometown'] as String?,
      description: json['description'] as String?,
      landmark: json['landmark'] as String?,
      locationString: json['location_string'] as String?,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'year': year,
      'url': url,
      'contact_email': contactEmail,
      'hometown': hometown,
      'description': description,
      'landmark': landmark,
      'location_string': locationString,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}