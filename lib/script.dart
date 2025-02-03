import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart'; // Needed for WidgetsFlutterBinding
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

/// ****************************
/// Models
/// ****************************

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

  factory CampModel.fromJson(Map<String, dynamic> json, {double? lat, double? lon, String? locStr}) {
    return CampModel(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      year: json['year'] is int ? json['year'] as int : int.tryParse(json['year']?.toString() ?? ''),
      url: json['url'] as String?,
      contactEmail: json['contact_email'] as String?,
      hometown: json['hometown'] as String?,
      description: json['description'] as String?,
      landmark: json['landmark'] as String?,
      locationString: locStr ?? json['location_string'] as String?,
      latitude: lat,
      longitude: lon,
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
      gpsLatitude: json['gps_latitude'] != null ? (json['gps_latitude']).toDouble() : null,
      gpsLongitude: json['gps_longitude'] != null ? (json['gps_longitude']).toDouble() : null,
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
      year: json['year'] is int ? json['year'] as int : int.tryParse(json['year']?.toString() ?? ''),
      url: json['url'] as String?,
      contactEmail: json['contact_email'] as String?,
      hometown: json['hometown'] as String?,
      description: json['description'] as String?,
      artist: json['artist'] as String?,
      category: json['category'] as String?,
      program: json['program'] as String?,
      donationLink: json['donation_link'] as String?,
      location: json['location'] != null ? ArtLocation.fromJson(json['location']) : null,
      locationString: json['location_string'] as String?,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((e) => ArtImage.fromJson(e))
              .toList()
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

class EventOccurrence {
  final DateTime? startTime;
  final DateTime? endTime;

  EventOccurrence({
    this.startTime,
    this.endTime,
  });

  factory EventOccurrence.fromJson(Map<String, dynamic> json) {
    return EventOccurrence(
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}

class EventType {
  final String? label;
  final String? abbr;

  EventType({
    this.label,
    this.abbr,
  });

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      label: json['label'] as String?,
      abbr: json['abbr'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'abbr': abbr,
    };
  }
}

class EventModel {
  final String? uid;
  final String? title;
  final int? eventId;
  final String? description;
  final EventType? eventType;
  final int? year;
  final String? slug;
  final String? hostedByCamp;
  final String? locatedAtArt;
  final String? otherLocation;
  final int? checkLocation;
  final String? url;
  final bool? allDay;
  final bool? listOnline;
  final bool? listContactOnline;
  final String? moderation;
  final List<EventOccurrence>? occurrenceSet;

  EventModel({
    this.uid,
    this.title,
    this.eventId,
    this.description,
    this.eventType,
    this.year,
    this.slug,
    this.hostedByCamp,
    this.locatedAtArt,
    this.otherLocation,
    this.checkLocation,
    this.url,
    this.allDay,
    this.listOnline,
    this.listContactOnline,
    this.moderation,
    this.occurrenceSet,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      uid: json['uid'] as String?,
      title: json['title'] as String?,
      eventId: json['event_id'] is int ? json['event_id'] as int : int.tryParse(json['event_id']?.toString() ?? ''),
      description: json['description'] as String?,
      eventType: json['event_type'] != null
          ? EventType.fromJson(json['event_type'])
          : null,
      year: json['year'] is int ? json['year'] as int : int.tryParse(json['year']?.toString() ?? ''),
      slug: json['slug'] as String?,
      hostedByCamp: json['hosted_by_camp'] as String?,
      locatedAtArt: json['located_at_art'] as String?,
      otherLocation: json['other_location'] as String?,
      checkLocation: json['check_location'] is int ? json['check_location'] as int : int.tryParse(json['check_location']?.toString() ?? ''),
      url: json['url'] as String?,
      allDay: json['all_day'] as bool?,
      listOnline: json['list_online'] == 1,
      listContactOnline: json['list_contact_online'] == 1,
      moderation: json['moderation'] as String?,
      occurrenceSet: json['occurrence_set'] != null
          ? (json['occurrence_set'] as List)
              .map((e) => EventOccurrence.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'event_id': eventId,
      'description': description,
      'event_type': eventType?.toMap(),
      'year': year,
      'slug': slug,
      'hosted_by_camp': hostedByCamp,
      'located_at_art': locatedAtArt,
      'other_location': otherLocation,
      'check_location': checkLocation,
      'url': url,
      'all_day': allDay,
      'list_online': listOnline,
      'list_contact_online': listContactOnline,
      'moderation': moderation,
      'occurrence_set': occurrenceSet?.map((e) => e.toMap()).toList(),
    };
  }
}

/// ****************************
/// Helper functions for camps location
/// ****************************

/// Computes the latitude and longitude from the provided [frontage] and [intersection] strings.
/// Returns a [Tuple2] where item1 is the latitude and item2 is the longitude.
Tuple2<double, double>? computeLatLon(String? frontage, String? intersection) {
  if (frontage == null || intersection == null) return null;

  // --- 1. Extract ring letter from frontage ---
  String? ringLetter;
  final ringMatch = RegExp(r'\b([A-Za-z])\b').firstMatch(frontage);
  if (ringMatch != null) {
    ringLetter = ringMatch.group(1)?.toUpperCase();
  }
  // Use the ring letter to determine distance in feet (or default to 2000 ft if not found)
  final distanceFeet = ringLetter != null ? ringToDistanceFeet(ringLetter) : 2000.0;
  final distanceMiles = distanceFeet / 5280.0;

  // --- 2. Extract time (e.g., "9:15") from intersection ---
  final timeMatch = RegExp(r'(\d{1,2}:\d{2})').firstMatch(intersection);
  if (timeMatch == null) return null;
  final timeString = timeMatch.group(1)!;
  final angleDegrees = timeToAngleDegrees(timeString);
  if (angleDegrees == null) return null;

  // --- 3. Compute offsets from a fixed center ---
  const double centerLat = 40.786;
  const double centerLon = -119.204;
  final theta = angleDegrees * (math.pi / 180.0);
  final offsetX = distanceMiles * math.sin(theta); // east-west offset (miles)
  final offsetY = distanceMiles * math.cos(theta); // north-south offset (miles)

  // --- 4. Convert mile offsets to degrees ---
  const double milesPerLatDegree = 69.0;
  final milesPerLonDegree = milesPerLatDegree * math.cos(centerLat * math.pi / 180.0);
  final deltaLat = offsetY / milesPerLatDegree;
  final deltaLon = offsetX / milesPerLonDegree;

  final campLat = centerLat + deltaLat;
  final campLon = centerLon + deltaLon;
  return Tuple2(campLat, campLon);
}

/// Converts a ring letter (e.g., "A") to an approximate distance (in feet) from the center.
double ringToDistanceFeet(String ring) {
  switch (ring.toUpperCase()) {
    case 'A':
      return 2500;
    case 'B':
      return 3000;
    case 'C':
      return 3500;
    case 'D':
      return 4000;
    case 'E':
      return 4500;
    case 'F':
      return 5000;
    case 'G':
      return 5500;
    default:
      return 2000;
  }
}

/// Converts a time string (e.g., "9:15") into an angle in degrees from 12:00.
/// Each hour represents 30° (360° / 12).
double? timeToAngleDegrees(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return null;
  final hour = double.tryParse(parts[0]) ?? 0;
  final minute = double.tryParse(parts[1]) ?? 0;
  final totalHours = hour + (minute / 60.0);
  return totalHours * 30.0;
}

/// ****************************
/// Main processing functions
/// ****************************

Future<List<String>> processCamps() async {
  const campUrl = 'https://bm-innovate.s3.amazonaws.com/archive/2023/camps.json';
  final response = await http.get(Uri.parse(campUrl));

  List<String> processedCampUIDs = [];

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List) {
      // Limit to the first 50 camps
      final campsToProcess = data.take(50);
      for (final campJson in campsToProcess) {
        // Get basic fields from JSON
        final uid = campJson['uid'] as String?;
        if (uid == null) continue; // skip if no uid
        final frontage = campJson['location']?['frontage'] as String?;
        final intersection = campJson['location']?['intersection'] as String?;

        // Compute coordinates if possible
        double? latitude;
        double? longitude;
        String? locationString;
        final computedCoords = computeLatLon(frontage, intersection);
        if (computedCoords != null) {
          latitude = computedCoords.item1;
          longitude = computedCoords.item2;
          // You can build a location string from the provided data
          locationString = 'Frontage: $frontage, Intersection: $intersection';
        } else {
          locationString = campJson['location_string'] as String?;
        }

        // Build a CampModel instance
        final camp = CampModel.fromJson(
          campJson,
          lat: latitude,
          lon: longitude,
          locStr: locationString,
        );

        print('Storing camp ${camp.uid} with lat: ${camp.latitude}, lon: ${camp.longitude}');
        await FirebaseFirestore.instance.collection('camps').doc(uid).set(camp.toMap());
        processedCampUIDs.add(uid);
      }
      print('Finished processing ${processedCampUIDs.length} camps.');
    } else {
      print('Unexpected JSON format for camps.');
    }
  } else {
    print('Failed to fetch camps data. Status code: ${response.statusCode}');
  }
  return processedCampUIDs;
}

Future<void> processArts() async {
  const artUrl = 'https://bm-innovate.s3.amazonaws.com/archive/2023/art.json';
  final response = await http.get(Uri.parse(artUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List) {
      // Limit to the first 50 art items
      final artsToProcess = data.take(50);
      for (final artJson in artsToProcess) {
        final art = ArtModel.fromJson(artJson);
        final uid = art.uid;
        if (uid == null) continue;
        print('Storing art ${art.uid}');
        await FirebaseFirestore.instance.collection('art').doc(uid).set(art.toMap());
      }
      print('Finished processing arts.');
    } else {
      print('Unexpected JSON format for art.');
    }
  } else {
    print('Failed to fetch art data. Status code: ${response.statusCode}');
  }
}

Future<void> processEvents(List<String> validCampUIDs) async {
  const eventUrl = 'https://bm-innovate.s3.amazonaws.com/archive/2023/events.json';
  final response = await http.get(Uri.parse(eventUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data is List) {
      // Filter events to only those hosted by one of the 50 camps we stored
      final filteredEvents = data.where((eventJson) {
        final hostedByCamp = eventJson['hosted_by_camp'] as String?;
        return hostedByCamp != null && validCampUIDs.contains(hostedByCamp);
      });

      for (final eventJson in filteredEvents) {
        final event = EventModel.fromJson(eventJson);
        final uid = event.uid;
        if (uid == null) continue;
        print('Storing event ${event.uid} for camp ${event.hostedByCamp}');
        await FirebaseFirestore.instance.collection('events').doc(uid).set(event.toMap());
      }
      print('Finished processing events.');
    } else {
      print('Unexpected JSON format for events.');
    }
  } else {
    print('Failed to fetch events data. Status code: ${response.statusCode}');
  }
}

/// ****************************
/// Main
/// ****************************

Future<void> main() async {
  // Ensure Flutter bindings are initialized.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Process camps first and get the list of camp UIDs (max 50)
  final campUIDs = await processCamps();

  // Process art (limit to 50)
  await processArts();

  // Process events, but only upload events for the camps we stored
  await processEvents(campUIDs);

  print('All data has been uploaded to Firestore.');
}