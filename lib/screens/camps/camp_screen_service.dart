  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:burn_tech/models/art_model.dart';
  import 'package:burn_tech/models/camp_model.dart';
  import 'package:burn_tech/models/event_model.dart';

  class DataProvider {
    Future<List<CampModel>> fetchCamps() async {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('camps').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CampModel.fromJson(data);
      }).toList();
    }

    Future<CampModel?> fetchCampById(String campId) async {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('camps').doc(campId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return CampModel.fromJson(data);
      }
      return null;
    }

    Future<List<ArtModel>> fetchArt() async {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('art').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ArtModel.fromJson(data);
      }).toList();
    }

    Future<ArtModel?> fetchArtById(String artId) async {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('art').doc(artId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ArtModel.fromJson(data);
      }
      return null;
    }

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

      if (campUIDs != null && campUIDs.isNotEmpty && campUIDs.length > 10) {
        events = events
            .where((event) => campUIDs.contains(event.hostedByCamp))
            .toList();
      }

      return events;
    }

    Future<List<EventModel>> fetchEventsForCamp(String campUid) async {
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
  }
