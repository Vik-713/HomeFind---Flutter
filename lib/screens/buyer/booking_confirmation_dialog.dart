// File: lib/screens/buyer/booking_confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../theme/app_theme.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationDialog({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon Animation / Circle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.secondaryEmerald,
                size: 54,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Viewing Booked Successfully!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              'Your property viewing appointment has been registered in Cloud Firestore.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Booking Details Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Property:', booking.propertyTitle),
                  const Divider(height: 16),
                  _buildDetailRow('Date:', booking.formattedDate),
                  const SizedBox(height: 6),
                  _buildDetailRow('Time Slot:', '${booking.startTime} - ${booking.endTime}'),
                  const Divider(height: 16),
                  _buildDetailRow('Buyer Name:', booking.buyerName),
                  const SizedBox(height: 6),
                  _buildDetailRow('Email:', booking.buyerEmail),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Back to Browse
                },
                child: const Text('Back to Browse Properties'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
