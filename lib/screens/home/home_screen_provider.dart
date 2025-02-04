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
      // Call loadCamps() on initialization.
      loadCamps();
      loadArts();
      loadEvents();
    }

    int get currentIndex => _currentIndex;

    /// Expose the camps to widgets
    List<CampModel> get camps => _camps;
    List<ArtModel> get arts => _arts;
    List<EventModel> get events => _events;
    void onTabTapped(int index) {
      _currentIndex = index;
      notifyListeners();
    }

    Future<List<dynamic>> getMyTickets(UserModel user) async {
      // Simulate network delay
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
        // Assume fetchCamps() now returns a List<CampModel>
        final List<CampModel> fetchedCamps = await _dataProvider.fetchCamps();
        _camps = fetchedCamps;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }

    Future<void> loadEvents() async {
      try {
        // Assume fetchCamps() now returns a List<CampModel>
        final List<EventModel> fetchedEvents = await _dataProvider.fetchEvents();
        _events = fetchedEvents;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }

    Future<List<EventModel>> getUpcomingEvents() async {
      // Simulate a delay (if needed)
      await Future.delayed(const Duration(milliseconds: 500));
      final now = DateTime.now();

      // Filter events that have at least one occurrence in the future (when ignoring year).
      List<EventModel> upcoming = events.where((event) {
        return event.occurrenceSet?.any((occ) {
              if (occ.startTime == null) return false;
              // Compute the next occurrence ignoring the stored year.
              final nextOccurrence = getNextOccurrence(now, occ.startTime!);
              return nextOccurrence.isAfter(now);
            }) ??
            false;
      }).toList();

      // Sort events by the soonest upcoming occurrence (ignoring year).
      upcoming.sort((a, b) {
        // For each event, compute the earliest upcoming occurrence.
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

      // Return only the first 4 upcoming events.
      return upcoming.take(4).toList();
    }

    DateTime getNextOccurrence(DateTime now, DateTime scheduledTime) {
      // Create a candidate DateTime for today with the scheduled time.
      DateTime candidate = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
        scheduledTime.second,
      );

      // Calculate the difference in days between now's weekday and the scheduled weekday.
      // Note: In Dart, DateTime.weekday gives 1 for Monday through 7 for Sunday.
      int daysDifference = scheduledTime.weekday - now.weekday;
      if (daysDifference < 0) {
        // The scheduled day is earlier in the week, so move to the next week.
        daysDifference += 7;
      }
      candidate = candidate.add(Duration(days: daysDifference));

      // If the candidate is still before 'now' (i.e. the time has already passed today),
      // then schedule it for the next week.
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
        // Pick two random camps (if available)
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
        // Assume fetchCamps() now returns a List<CampModel>
        final List<ArtModel> fetchedArts = await _dataProvider.fetchArt();
        _arts = fetchedArts;
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }
