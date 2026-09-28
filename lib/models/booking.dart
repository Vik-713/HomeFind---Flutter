// File: lib/models/booking.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Booking {
  final String id;
  final String propertyId;
  final String slotId;
  final String propertyTitle;
  final String buyerName;
  final String buyerEmail;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.propertyId,
    required this.slotId,
    required this.propertyTitle,
    required this.buyerName,
    required this.buyerEmail,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'confirmed',
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    return Booking(
      id: docId,
      propertyId: map['propertyId'] ?? '',
      slotId: map['slotId'] ?? '',
      propertyTitle: map['propertyTitle'] ?? 'Property Viewing',
      buyerName: map['buyerName'] ?? 'Buyer',
      buyerEmail: map['buyerEmail'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      status: map['status'] ?? 'confirmed',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Booking.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'slotId': slotId,
      'propertyTitle': propertyTitle,
      'buyerName': buyerName,
      'buyerEmail': buyerEmail,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedDate {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }
}
