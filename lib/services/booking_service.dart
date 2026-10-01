// File: lib/services/booking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../models/viewing_slot.dart';
import '../utils/error_handler.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _slotsCollection =>
      _firestore.collection('viewingSlots');

  /// Book a viewing slot using a Firestore Transaction to guarantee atomicity
  /// and prevent double booking of the same viewing slot.
  /// Book a viewing slot using a Firestore Transaction to guarantee atomicity
  /// and prevent double booking of the same viewing slot.
  Future<Booking> bookViewing({
    required ViewingSlot slot,
    required String propertyTitle,
    String propertyImage = 'assets/images/property1.jpg',
    String agentId = '',
    required String buyerName,
    required String buyerEmail,
  }) async {
    try {
      final slotRef = _slotsCollection.doc(slot.id);
      final bookingRef = _bookingsCollection.doc();

      // Execute atomic transaction
      final Booking createdBooking = await _firestore.runTransaction((transaction) async {
        // 1. Read current slot state inside transaction
        final slotSnapshot = await transaction.get(slotRef);

        if (!slotSnapshot.exists) {
          throw Exception('The requested viewing slot no longer exists.');
        }

        final isAvailable = slotSnapshot.data()?['isAvailable'] ?? false;
        if (!isAvailable) {
          throw Exception('This viewing slot is no longer available. Please select another slot.');
        }

        // 2. Prepare booking object
        final booking = Booking(
          id: bookingRef.id,
          propertyId: slot.propertyId,
          agentId: agentId,
          slotId: slot.id,
          propertyTitle: propertyTitle,
          propertyImage: propertyImage,
          buyerName: buyerName.trim(),
          buyerEmail: buyerEmail.trim(),
          date: slot.date,
          startTime: slot.startTime,
          endTime: slot.endTime,
          status: 'confirmed',
          createdAt: DateTime.now(),
        );

        // 3. Write booking document inside transaction
        transaction.set(bookingRef, booking.toMap());

        // 4. Mark slot as unavailable inside transaction
        transaction.update(slotRef, {
          'isAvailable': false,
        });

        return booking;
      });

      return createdBooking;
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Get stream of bookings for a specific buyer email
  Stream<List<Booking>> getBuyerBookingsStream(String buyerEmail) {
    return _bookingsCollection
        .where('buyerEmail', isEqualTo: buyerEmail)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Get stream of scheduled visits/bookings specifically for an agent's properties
  Stream<List<Booking>> getAgentBookingsStream(String agentId, {List<String>? agentPropertyIds}) {
    return _bookingsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .where((booking) {
            // Match agentId directly if set
            if (booking.agentId.isNotEmpty) {
              return booking.agentId == agentId;
            }
            // Fallback for legacy bookings: match against propertyId list if provided
            if (agentPropertyIds != null && agentPropertyIds.contains(booking.propertyId)) {
              return true;
            }
            return false;
          })
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Get stream of all scheduled visits/bookings across all properties
  Stream<List<Booking>> getAllBookingsStream() {
    return _bookingsCollection.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }
}
 