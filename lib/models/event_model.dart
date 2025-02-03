import 'package:cloud_firestore/cloud_firestore.dart';

class EventOccurrence {
  final DateTime? startTime;
  final DateTime? endTime;

  EventOccurrence({
    this.startTime,
    this.endTime,
  });

  factory EventOccurrence.fromJson(Map<String, dynamic> json) {
    DateTime? _parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      } else if (value is DateTime) {
        return value;
      }
      return null;
    }

    return EventOccurrence(
      startTime: _parseTimestamp(json['start_time']),
      endTime: _parseTimestamp(json['end_time']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
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
      eventId: json['event_id'] is int
          ? json['event_id'] as int
          : int.tryParse(json['event_id']?.toString() ?? ''),
      description: json['description'] as String?,
      eventType: json['event_type'] != null ? EventType.fromJson(json['event_type']) : null,
      year: json['year'] is int
          ? json['year'] as int
          : int.tryParse(json['year']?.toString() ?? ''),
      slug: json['slug'] as String?,
      hostedByCamp: json['hosted_by_camp'] as String?,
      locatedAtArt: json['located_at_art'] as String?,
      otherLocation: json['other_location'] as String?,
      checkLocation: json['check_location'] is int
          ? json['check_location'] as int
          : int.tryParse(json['check_location']?.toString() ?? ''),
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