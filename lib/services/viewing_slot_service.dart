// File: lib/services/viewing_slot_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/viewing_slot.dart';
import '../utils/error_handler.dart';

class ViewingSlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _slotsCollection =>
      _firestore.collection('viewingSlots');

  /// Real-time stream of available viewing slots for a specific property
  Stream<List<ViewingSlot>> getSlotsForPropertyStream(String propertyId) {
    return _slotsCollection
        .where('propertyId', isEqualTo: propertyId)
        .snapshots()
        .map((snapshot) {
      final slots = snapshot.docs
          .map((doc) => ViewingSlot.fromFirestore(doc))
          .toList();
      // Sort slots chronologically by date and start time
      slots.sort((a, b) {
        final dateComp = a.date.compareTo(b.date);
        if (dateComp != 0) return dateComp;
        return a.startTime.compareTo(b.startTime);
      });
      return slots;
    });
  }

  /// Create a single viewing slot
  Future<String> createSlot(ViewingSlot slot) async {
    try {
      final docRef = _slotsCollection.doc();
      final newSlot = ViewingSlot(
        id: docRef.id,
        propertyId: slot.propertyId,
        date: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        isAvailable: true,
      );
      await docRef.set(newSlot.toMap());
      return docRef.id;
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Create default/sample viewing slots for a property (for agents or testing)
  Future<void> seedDefaultSlotsForProperty(String propertyId) async {
    try {
      final now = DateTime.now();
      final List<Map<String, String>> times = [
        {'start': '10:00 AM', 'end': '11:00 AM'},
        {'start': '11:30 AM', 'end': '12:30 PM'},
        {'start': '02:00 PM', 'end': '03:00 PM'},
        {'start': '04:00 PM', 'end': '05:00 PM'},
      ];

      final batch = _firestore.batch();

      // Seed slots for tomorrow and day after tomorrow
      for (int dayOffset in [1, 2, 3]) {
        final slotDate = DateTime(now.year, now.month, now.day + dayOffset);
        for (final timeMap in times) {
          final docRef = _slotsCollection.doc();
          final slot = ViewingSlot(
            id: docRef.id,
            propertyId: propertyId,
            date: slotDate,
            startTime: timeMap['start']!,
            endTime: timeMap['end']!,
            isAvailable: true,
          );
          batch.set(docRef, slot.toMap());
        }
      }

      await batch.commit();
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }
}
 