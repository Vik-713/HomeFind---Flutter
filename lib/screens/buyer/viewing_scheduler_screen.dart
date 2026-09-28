// File: lib/screens/buyer/viewing_scheduler_screen.dart

import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/property.dart';
import '../../models/viewing_slot.dart';
import '../../services/booking_service.dart';
import '../../services/viewing_slot_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'booking_confirmation_dialog.dart';

class ViewingSchedulerScreen extends StatefulWidget {
  final Property property;

  const ViewingSchedulerScreen({super.key, required this.property});

  @override
  State<ViewingSchedulerScreen> createState() => _ViewingSchedulerScreenState();
}

class _ViewingSchedulerScreenState extends State<ViewingSchedulerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final ViewingSlotService _slotService = ViewingSlotService();
  final BookingService _bookingService = BookingService();

  ViewingSlot? _selectedSlot;
  bool _isBooking = false;
  String? _bookingError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _bookingError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSlot == null) {
      setState(() {
        _bookingError = 'Please select a viewing time slot.';
      });
      return;
    }

    if (!_selectedSlot!.isAvailable) {
      setState(() {
        _bookingError = 'This slot is no longer available. Please select another slot.';
      });
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Execute Firestore Transaction for safe booking
      final Booking booking = await _bookingService.bookViewing(
        slot: _selectedSlot!,
        propertyTitle: widget.property.title,
        propertyImage: widget.property.primaryImage,
        agentId: widget.property.agentId,
        buyerName: _nameController.text,
        buyerEmail: _emailController.text,
      );

      if (mounted) {
        // Show success confirmation dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => BookingConfirmationDialog(booking: booking),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookingError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final property = widget.property;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Viewing Slot'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 750),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Property Info Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.apartment,
                                size: 36, color: AppTheme.primaryBlue),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${property.location} • ${property.formattedPrice}',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Inputs: Buyer Name & Email
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Buyer Contact Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Your Full Name *',
                                hintText: 'John Doe',
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                              validator: (v) =>
                                  Validators.validateRequired(v, 'Buyer Name'),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Your Email Address *',
                                hintText: 'buyer@example.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: Validators.validateEmail,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Slots Selection Header
                      Text(
                        '2. Select Available Viewing Slot',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Error Banner
                      if (_bookingError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFDC2626), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _bookingError!,
                                  style: const TextStyle(
                                    color: Color(0xFF991B1B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Viewing Slots Stream from Firestore
                      StreamBuilder<List<ViewingSlot>>(
                        stream: _slotService
                            .getSlotsForPropertyStream(property.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoadingWidget(
                              message: 'Loading real-time slot availability...',
                            );
                          }

                          final slots = snapshot.data ?? [];

                          if (slots.isEmpty) {
                            return const EmptyStateWidget(
                              icon: Icons.event_busy,
                              title: 'No Viewing Slots Listed',
                              message:
                                  'No viewing slots found in Firestore for this property yet.',
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: slots.length,
                            itemBuilder: (context, index) {
                              final slot = slots[index];
                              final isSelected = _selectedSlot?.id == slot.id;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                color: isSelected
                                    ? AppTheme.primaryBlue.withValues(alpha: 0.08)
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.borderSubtle,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  enabled: slot.isAvailable,
                                  onTap: slot.isAvailable
                                      ? () {
                                          setState(() {
                                            _selectedSlot = slot;
                                            _bookingError = null;
                                          });
                                        }
                                      : null,
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : (slot.isAvailable
                                            ? Icons.radio_button_unchecked
                                            : Icons.block),
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : (slot.isAvailable
                                            ? AppTheme.textMuted
                                            : Colors.grey),
                                  ),
                                  title: Text(
                                    slot.formattedDate,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: slot.isAvailable
                                          ? AppTheme.textDark
                                          : Colors.grey,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Time Window: ${slot.formattedTimeWindow}',
                                    style: TextStyle(
                                      color: slot.isAvailable
                                          ? AppTheme.textMuted
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: slot.isAvailable
                                          ? const Color(0xFFD1FAE5)
                                          : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      slot.isAvailable ? 'AVAILABLE' : 'BOOKED',
                                      style: TextStyle(
                                        color: slot.isAvailable
                                            ? const Color(0xFF065F46)
                                            : const Color(0xFF991B1B),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit Booking Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isBooking ? null : _confirmBooking,
                          icon: const Icon(Icons.check_circle_outline),
                          label: _isBooking
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('Confirm & Book Viewing Slot'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
