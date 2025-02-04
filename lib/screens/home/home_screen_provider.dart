  import 'dart:math';
  import 'package:burn_tech/models/art_model.dart';
  import 'package:burn_tech/models/camp_model.dart';
  import 'package:burn_tech/models/event_model.dart';
  import 'package:burn_tech/models/user_model.dart';
  import 'package:burn_tech/screens/camps/camp_screen_service.dart';
  import 'package:flutter/material.dart';

  class HomeProvider extends ChangeNotifier {
    final DataProvider _dataProvider = DataProvider();

    UserModel? currentUser;
    int _currentIndex = 0;
    List<CampModel> _camps = [];
    List<ArtModel> _arts = [];
    List<EventModel> _events = [];
    HomeProvider() {
      loadCamps();
      loadArts();
      loadEvents();
    }

    int get currentIndex => _currentIndex;

    List<CampModel> get camps => _camps;
    List<ArtModel> get arts => _arts;
    List<EventModel> get events => _events;
    void onTabTapped(int index) {
      _currentIndex = index;
      notifyListeners();
    }

    Future<List<dynamic>> getMyTickets(UserModel user) async {
      await Future.delayed(const Duration(milliseconds: 500));
      final userArts = arts
          .where((art) => user.artTokens?.contains(art.uid) ?? false)
          .toList();
      final userCamps = camps
          .where((camp) => user.campTokens?.contains(camp.uid) ?? false)
          .toList();
      return [...userArts, ...userCamps];
    }

    Future<void> loadCamps() async {
      try {
        final List<CampModel> fetchedCamps = await _dataProvider.fetchCamps();
        _camps = fetchedCamps;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }

    Future<void> loadEvents() async {
      try {
        final List<EventModel> fetchedEvents = await _dataProvider.fetchEvents();
        _events = fetchedEvents;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }

    Future<List<EventModel>> getUpcomingEvents() async {
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();

      List<EventModel> upcoming = events.where((event) {
        return event.occurrenceSet?.any((occ) {
              if (occ.startTime == null) return false;
              final nextOccurrence = getNextOccurrence(now, occ.startTime!);
              return nextOccurrence.isAfter(now);
            }) ??
            false;
      }).toList();
      upcoming.sort((a, b) {
        DateTime aNext = a.occurrenceSet!
            .where((occ) => occ.startTime != null)
            .map((occ) => getNextOccurrence(now, occ.startTime!))
            .reduce((prev, element) => element.isBefore(prev) ? element : prev);

        DateTime bNext = b.occurrenceSet!
            .where((occ) => occ.startTime != null)
            .map((occ) => getNextOccurrence(now, occ.startTime!))
            .reduce((prev, element) => element.isBefore(prev) ? element : prev);

        return aNext.compareTo(bNext);
      });

      return upcoming.take(4).toList();
    }

    DateTime getNextOccurrence(DateTime now, DateTime scheduledTime) {
      DateTime candidate = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
        scheduledTime.second,
      );

      int daysDifference = scheduledTime.weekday - now.weekday;
      if (daysDifference < 0) {
        daysDifference += 7;
      }
      candidate = candidate.add(Duration(days: daysDifference));

      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 7));
      }
      return candidate;
    }

    Future<List<dynamic>> getNearbyCampsAndArts() async {
      await Future.delayed(const Duration(milliseconds: 500));
      final random = Random();
      List<dynamic> result = [];
      if (camps.isNotEmpty) {
        result.add(camps[random.nextInt(camps.length)]);
        if (camps.length > 1) {
          result.add(camps[random.nextInt(camps.length)]);
        }
      }
      if (arts.isNotEmpty) {
        result.add(arts[random.nextInt(arts.length)]);
        if (arts.length > 1) {
          result.add(arts[random.nextInt(arts.length)]);
        }
      }
      return result;
    }

    Future<List<String>> getAnnouncements() async {
      await Future.delayed(const Duration(milliseconds: 500));
      List<String> announcements = [];
      if (camps.isNotEmpty) {
        announcements.add("New camp available: ${camps.first.name ?? 'Camp'}!");
      }
      if (arts.isNotEmpty) {
        announcements.add("Explore the art: ${arts.first.name ?? 'Art'}!");
      }
      if (events.isNotEmpty) {
        announcements
            .add("Don't miss the event: ${events.first.title ?? 'Event'}!");
      }
      return announcements;
    }

    Future<void> loadArts() async {
      try {
        final List<ArtModel> fetchedArts = await _dataProvider.fetchArt();
        _arts = fetchedArts;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }
