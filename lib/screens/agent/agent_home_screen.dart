// File: lib/screens/agent/agent_home_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/auth_service.dart';
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

  int _selectedTabIndex = 0; // 0: My Listings, 1: All Listings

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

    final propertyStream = _selectedTabIndex == 0 && agentUid.isNotEmpty
        ? _propertyService.getAgentPropertiesStream(agentUid)
        : _propertyService.getPropertiesStream();

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
                color: AppTheme.textMuted,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (My Listings vs All Listings)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text('My Listings'),
                        icon: Icon(Icons.person_pin_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text('All System Listings'),
                        icon: Icon(Icons.apartment_outlined, size: 18),
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
          const Divider(height: 1, color: AppTheme.borderSubtle),

          // Main Stream Area
          Expanded(
            child: StreamBuilder<List<Property>>(
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
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final properties = snapshot.data ?? [];

                if (properties.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.add_business_outlined,
                    title: _selectedTabIndex == 0
                        ? 'No Listings Found For Your Account'
                        : 'No Properties Posted Yet',
                    message: _selectedTabIndex == 0
                        ? 'You have not added any properties under your account ($agentName). Click below to add a property or switch to "All System Listings".'
                        : 'No listings exist in Cloud Firestore yet. Click below to add your first property listing.',
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
                                  _selectedTabIndex == 0
                                      ? 'My Listings (${properties.length})'
                                      : 'All Active Properties (${properties.length})',
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
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Add Listing'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: 0.76,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: properties.length,
                              itemBuilder: (context, index) {
                                final property = properties[index];
                                return PropertyCard(
                                  property: property,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ManageSlotsScreen(property: property),
                                      ),
                                    );
                                  },
                                  onBookViewing: () {
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPropertyScreen()),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('New Property Listing'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
