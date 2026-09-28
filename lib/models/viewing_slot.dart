// File: lib/models/viewing_slot.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ViewingSlot {
  final String id;
  final String propertyId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  ViewingSlot({
    required this.id,
    required this.propertyId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  factory ViewingSlot.fromMap(Map<String, dynamic> map, String docId) {
    return ViewingSlot(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '10:00 AM',
      endTime: map['endTime'] ?? '11:00 AM',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  factory ViewingSlot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ViewingSlot.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  String get formattedDate {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  String get formattedTimeWindow {
    return '$startTime - $endTime';
  }
}
