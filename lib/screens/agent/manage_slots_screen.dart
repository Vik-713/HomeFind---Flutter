// File: lib/screens/agent/manage_slots_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../models/viewing_slot.dart';
import '../../services/viewing_slot_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class ManageSlotsScreen extends StatefulWidget {
  final Property property;

  const ManageSlotsScreen({super.key, required this.property});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final ViewingSlotService _slotService = ViewingSlotService();
  bool _isSeeding = false;

  Future<void> _seedSlots() async {
    setState(() {
      _isSeeding = true;
    });
    try {
      await _slotService.seedDefaultSlotsForProperty(widget.property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generated 12 default viewing slots for this property!'),
            backgroundColor: AppTheme.secondaryEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating slots: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeeding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slots: ${widget.property.title}'),
      ),
      body: StreamBuilder<List<ViewingSlot>>(
        stream: _slotService.getSlotsForPropertyStream(widget.property.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isSeeding) {
            return const LoadingWidget(message: 'Loading viewing slots...');
          }

          final slots = snapshot.data ?? [];

          if (slots.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: 'No Viewing Slots Available',
              message: 'Generate default slots for buyers to schedule viewings.',
              actionLabel: 'Generate Viewing Slots',
              onAction: _seedSlots,
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Viewing Slots (${slots.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: _seedSlots,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Add More Slots'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      final slot = slots[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: slot.isAvailable
                                  ? AppTheme.secondaryEmerald.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              slot.isAvailable ? Icons.check_circle : Icons.cancel,
                              color: slot.isAvailable
                                  ? AppTheme.secondaryEmerald
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            slot.formattedDate,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Time Window: ${slot.formattedTimeWindow}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: slot.isAvailable
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
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
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
 