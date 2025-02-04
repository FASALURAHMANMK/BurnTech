  class ArtLocation {
    final int? hour;
    final int? minute;
    final int? distance;
    final String? category;
    final double? gpsLatitude;
    final double? gpsLongitude;

    ArtLocation({
      this.hour,
      this.minute,
      this.distance,
      this.category,
      this.gpsLatitude,
      this.gpsLongitude,
    });

    factory ArtLocation.fromJson(Map<String, dynamic> json) {
      return ArtLocation(
        hour: json['hour'] as int?,
        minute: json['minute'] as int?,
        distance: json['distance'] as int?,
        category: json['category'] as String?,
        gpsLatitude: json['gps_latitude'] != null
            ? (json['gps_latitude']).toDouble()
            : null,
        gpsLongitude: json['gps_longitude'] != null
            ? (json['gps_longitude']).toDouble()
            : null,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'hour': hour,
        'minute': minute,
        'distance': distance,
        'category': category,
        'gps_latitude': gpsLatitude,
        'gps_longitude': gpsLongitude,
      };
    }
  }

  class ArtImage {
    final String? thumbnailUrl;
    final String? galleryRef;

    ArtImage({this.thumbnailUrl, this.galleryRef});

    factory ArtImage.fromJson(Map<String, dynamic> json) {
      return ArtImage(
        thumbnailUrl: json['thumbnail_url'] as String?,
        galleryRef: json['gallery_ref'] as String?,
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'thumbnail_url': thumbnailUrl,
        'gallery_ref': galleryRef,
      };
    }
  }

  class ArtModel {
    final String? uid;
    final String? name;
    final int? year;
    final String? url;
    final String? contactEmail;
    final String? hometown;
    final String? description;
    final String? artist;
    final String? category;
    final String? program;
    final String? donationLink;
    final ArtLocation? location;
    final String? locationString;
    final List<ArtImage>? images;
    final int? guidedTours;
    final int? selfGuidedTourMap;

    ArtModel({
      this.uid,
      this.name,
      this.year,
      this.url,
      this.contactEmail,
      this.hometown,
      this.description,
      this.artist,
      this.category,
      this.program,
      this.donationLink,
      this.location,
      this.locationString,
      this.images,
      this.guidedTours,
      this.selfGuidedTourMap,
    });

    factory ArtModel.fromJson(Map<String, dynamic> json) {
      return ArtModel(
        uid: json['uid'] as String?,
        name: json['name'] as String?,
        year: json['year'] is int
            ? json['year'] as int
            : int.tryParse(json['year']?.toString() ?? ''),
        url: json['url'] as String?,
        contactEmail: json['contact_email'] as String?,
        hometown: json['hometown'] as String?,
        description: json['description'] as String?,
        artist: json['artist'] as String?,
        category: json['category'] as String?,
        program: json['program'] as String?,
        donationLink: json['donation_link'] as String?,
        location: json['location'] != null
            ? ArtLocation.fromJson(json['location'])
            : null,
        locationString: json['location_string'] as String?,
        images: json['images'] != null
            ? (json['images'] as List).map((e) => ArtImage.fromJson(e)).toList()
            : null,
        guidedTours: json['guided_tours'] as int?,
        selfGuidedTourMap: json['self_guided_tour_map'] as int?,
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
        'artist': artist,
        'category': category,
        'program': program,
        'donation_link': donationLink,
        'location': location?.toMap(),
        'location_string': locationString,
        'images': images?.map((e) => e.toMap()).toList(),
        'guided_tours': guidedTours,
        'self_guided_tour_map': selfGuidedTourMap,
      };
    }
  }
