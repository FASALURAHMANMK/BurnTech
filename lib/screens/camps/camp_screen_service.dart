import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:burn_tech/models/art_model.dart';
import 'package:burn_tech/models/camp_model.dart';
import 'package:burn_tech/models/event_model.dart';

class DataProvider {
  /// Fetch list of Camps from Firestore.
  Future<List<CampModel>> fetchCamps() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('camps').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CampModel.fromJson(data);
    }).toList();
  }

  /// Fetch a single Camp by its document ID.
  Future<CampModel?> fetchCampById(String campId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('camps')
        .doc(campId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return CampModel.fromJson(data);
    }
    return null;
  }

  /// Fetch list of Art items from Firestore.
  Future<List<ArtModel>> fetchArt() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('art').get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ArtModel.fromJson(data);
    }).toList();
  }

  /// Fetch a single Art item by its document ID.
  Future<ArtModel?> fetchArtById(String artId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('art')
        .doc(artId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return ArtModel.fromJson(data);
    }
    return null;
  }

  /// Fetch list of Events from Firestore.
  ///
  /// If [campUIDs] is provided, this method will attempt to filter events
  /// so that only those with a 'hosted_by_camp' value included in [campUIDs]
  /// are returned. Note: Firestore's `whereIn` clause supports up to 10 elements.
  Future<List<EventModel>> fetchEvents({List<String>? campUIDs}) async {
    Query query = FirebaseFirestore.instance.collection('events');

    if (campUIDs != null && campUIDs.isNotEmpty && campUIDs.length <= 10) {
      query = query.where('hosted_by_camp', whereIn: campUIDs);
    }

    QuerySnapshot snapshot = await query.get();

    List<EventModel> events = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventModel.fromJson(data);
    }).toList();

    // If campUIDs was provided and its length exceeded the whereIn limit,
    // filter the results in memory.
    if (campUIDs != null && campUIDs.isNotEmpty && campUIDs.length > 10) {
      events = events
          .where((event) => campUIDs.contains(event.hostedByCamp))
          .toList();
    }

    return events;
  }
  Future<List<EventModel>> fetchEventsForCamp(String campUid) async {
    // You could also use your existing fetchEvents method:
    // return fetchEvents(campUIDs: [campUid]);
    final query = FirebaseFirestore.instance
        .collection('events')
        .where('hosted_by_camp', isEqualTo: campUid);
    final snapshot = await query.get();

    List<EventModel> events = snapshot.docs.map((doc) {
      final data = doc.data();
      return EventModel.fromJson(data);
    }).toList();
    return events;
  }

  // (Optional) Other existing methods: fetchCamps(), fetchArt(), etc.
  // ...
}