// File: lib/screens/buyer/buyer_account_screen.dart

import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class BuyerAccountScreen extends StatefulWidget {
  const BuyerAccountScreen({super.key});

  @override
  State<BuyerAccountScreen> createState() => _BuyerAccountScreenState();
}

class _BuyerAccountScreenState extends State<BuyerAccountScreen> {
  final BookingService _bookingService = BookingService();

  // Notification Preferences State
  bool _notifyNewListings = true;
  bool _notifyViewingReminders = true;
  bool _notifyPriceAlerts = true;
  bool _notifySmsReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewer Account & Preferences'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Profile Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5A5A5A), Color(0xFF2B2B2B)],
                          ),
                          border: Border.all(color: const Color(0xFF6B6B6B), width: 1),
                        ),
                        child: const Icon(Icons.person, color: AppTheme.textPrimary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Home Buyer / Viewer',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'buyer@homefind.app • Active Searcher',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Viewer Stats: No. of Scheduled Visits & Budgets
                StreamBuilder<List<Booking>>(
                  stream: _bookingService.getAllBookingsStream(),
                  builder: (context, snapshot) {
                    final visitsCount = snapshot.data?.length ?? 0;

                    return Row(
                      children: [
                        // Scheduled Visits Stat Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181818),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.calendar_month, color: AppTheme.accentEmerald, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Scheduled Visits',
                                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$visitsCount',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Booked Viewing Slots',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Budget Stat Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF181818),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, color: AppTheme.textPrimary, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Target Budget',
                                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '₹45k - ₹1.5 Cr',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE0E0E0),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Preferred Rent & Sale Range',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 3. Notification Preferences ("To Be Notified")
                Text(
                  'Notification & Alert Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: [
                      SwitchListTile(
                        value: _notifyNewListings,
                        onChanged: (val) {
                          setState(() {
                            _notifyNewListings = val;
                          });
                        },
                        title: const Text('Notify on new property listings', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: const Text('Receive alerts when new 2BHK & Apartments match your budget', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        secondary: const Icon(Icons.notifications_active_outlined, color: AppTheme.textPrimary),
                        activeThumbColor: AppTheme.textPrimary,
                      ),
                      const Divider(height: 1, color: Color(0xFF262626)),
                      SwitchListTile(
                        value: _notifyViewingReminders,
                        onChanged: (val) {
                          setState(() {
                            _notifyViewingReminders = val;
                          });
                        },
                        title: const Text('Viewing appointment reminders', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: const Text('Get notified 1 hour prior to your scheduled property visit', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        secondary: const Icon(Icons.event_note, color: AppTheme.textPrimary),
                        activeThumbColor: AppTheme.textPrimary,
                      ),
                      const Divider(height: 1, color: Color(0xFF262626)),
                      SwitchListTile(
                        value: _notifyPriceAlerts,
                        onChanged: (val) {
                          setState(() {
                            _notifyPriceAlerts = val;
                          });
                        },
                        title: const Text('Price drop & offer alerts', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: const Text('Instant updates when saved listings reduce pricing', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        secondary: const Icon(Icons.trending_down, color: AppTheme.textPrimary),
                        activeThumbColor: AppTheme.textPrimary,
                      ),
                      const Divider(height: 1, color: Color(0xFF262626)),
                      SwitchListTile(
                        value: _notifySmsReminders,
                        onChanged: (val) {
                          setState(() {
                            _notifySmsReminders = val;
                          });
                        },
                        title: const Text('SMS text notifications', style: TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                        subtitle: const Text('Send SMS confirmation code for scheduled visits', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        secondary: const Icon(Icons.sms_outlined, color: AppTheme.textPrimary),
                        activeThumbColor: AppTheme.textPrimary,
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: 28),

                // 4. Portal Switch Button
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFF262626),
                      border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.real_estate_agent_outlined, color: AppTheme.textPrimary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Switch to Agent Portal / Sign In',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 