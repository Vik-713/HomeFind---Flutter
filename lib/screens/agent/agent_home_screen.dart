// File: lib/screens/agent/agent_home_screen.dart

import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/property.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/property_card.dart';
import '../common/splash_screen.dart';
import 'add_property_screen.dart';
import 'manage_slots_screen.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();
  final BookingService _bookingService = BookingService();

  int _selectedTabIndex = 0; // 0: My Listings, 1: Scheduled Visits

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of your agent account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PublicLandingScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final agentName = user?.displayName ?? user?.email?.split('@').first ?? 'Agent';
    final agentUid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agent Dashboard'),
            Text(
              'Logged in as $agentName (${user?.email ?? ''})',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (My Listings vs Scheduled Visits)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.darkBackground,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('My Listings'),
                        icon: Icon(Icons.home_work_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('Scheduled Visits'),
                        icon: Icon(Icons.event_available_outlined, size: 18),
                      ),
                    ],
                    selected: {_selectedTabIndex},
                    onSelectionChanged: (set) {
                      setState(() {
                        _selectedTabIndex = set.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.darkBorder),

          // Main View Area
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildMyListingsView(agentUid, agentName)
                : _buildScheduledVisitsView(agentUid),
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('New Property Listing'),
              backgroundColor: const Color(0xFF3A3A3A),
              foregroundColor: AppTheme.textPrimary,
            )
          : null,
    );
  }

  /// 1. My Listings View (No scheduling options on property cards)
  Widget _buildMyListingsView(String agentUid, String agentName) {
    final propertyStream = agentUid.isNotEmpty
        ? _propertyService.getAgentPropertiesStream(agentUid)
        : _propertyService.getPropertiesStream();

    return StreamBuilder<List<Property>>(
      stream: propertyStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget(message: 'Loading property listings...');
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Notice: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final properties = snapshot.data ?? [];

        if (properties.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.add_business_outlined,
            title: 'No Property Listings Found',
            message: 'You have not created any property listings under your account ($agentName). Click below to post your first listing.',
            actionLabel: 'Add Property Listing',
            onAction: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 1;
            if (constraints.maxWidth >= 1100) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth >= 650) {
              crossAxisCount = 2;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'My Listings (${properties.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddPropertyScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Listing'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.88,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return PropertyCard(
                          property: property,
                          showBookButton: false, // Scheduling option removed from agent listing section
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ManageSlotsScreen(property: property),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 2. Scheduled Visits View (Shows buyer visits specifically for this agent's properties)
  Widget _buildScheduledVisitsView(String agentUid) {
    return StreamBuilder<List<Property>>(
      stream: _propertyService.getAgentPropertiesStream(agentUid),
      builder: (context, propertySnapshot) {
        final agentProperties = propertySnapshot.data ?? [];
        final agentPropertyIds = agentProperties.map((p) => p.id).toList();

        return StreamBuilder<List<Booking>>(
          stream: _bookingService.getAgentBookingsStream(agentUid, agentPropertyIds: agentPropertyIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(message: 'Loading scheduled property visits...');
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Notice: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.event_busy_outlined,
                title: 'No Scheduled Visits Found',
                message: 'No buyers have scheduled viewing visits for your properties yet.',
              );
            }

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scheduled Visits For Your Properties (${bookings.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return _buildScheduledVisitCard(context, booking);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduledVisitCard(BuildContext context, Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Photo
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 95,
              height: 95,
              child: _buildVisitImage(booking.propertyImage),
            ),
          ),
          const SizedBox(width: 16),

          // Visit & Buyer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.propertyTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46).withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentEmerald, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 14, color: AppTheme.accentEmerald),
                          SizedBox(width: 4),
                          Text(
                            'Confirmed Visit',
                            style: TextStyle(
                              color: AppTheme.accentEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Buyer Name & Email
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        const Text(
                          'Buyer: ',
                          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                        Text(
                          booking.buyerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, size: 14, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          booking.buyerEmail,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Visit Date & Time Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            booking.formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${booking.startTime} - ${booking.endTime}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/images/property1.jpg', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset('assets/images/property1.jpg', fit: BoxFit.cover),
    );
  }
}
 