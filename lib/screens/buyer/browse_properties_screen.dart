// File: lib/screens/buyer/browse_properties_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/property_card.dart';
import '../auth/login_screen.dart';
import 'property_details_screen.dart';
import 'viewing_scheduler_screen.dart';

class BrowsePropertiesScreen extends StatefulWidget {
  const BrowsePropertiesScreen({super.key});

  @override
  State<BrowsePropertiesScreen> createState() => _BrowsePropertiesScreenState();
}

class _BrowsePropertiesScreenState extends State<BrowsePropertiesScreen> {
  final PropertyService _propertyService = PropertyService();

  String _searchQuery = '';
  String _selectedTypeFilter = 'All';

  final List<String> _typeFilters = [
    'All',
    'Apartment',
    'Villa',
    'Penthouse',
    'Studio',
    'Townhouse',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.home_work_rounded, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text(
              'HOMEFIND',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_person_outlined),
            tooltip: 'Agent Login',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, location, or price...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Pills
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _typeFilters.length,
                    itemBuilder: (context, index) {
                      final filter = _typeFilters[index];
                      final isSelected = _selectedTypeFilter == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(filter),
                          onSelected: (selected) {
                            setState(() {
                              _selectedTypeFilter = filter;
                            });
                          },
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : AppTheme.borderSubtle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderSubtle),

          // Real-time Firestore Stream Body
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: _propertyService.getPropertiesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Fetching real-time listings from Firestore...');
                }

                if (snapshot.hasError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Firestore Access Notice',
                    message:
                        'Unable to access Cloud Firestore. Please check your internet connection or publish firestore.rules in Firebase Console.',
                  );
                }

                final rawProperties = snapshot.data ?? [];

                // Apply client-side search & category filtering
                final filteredProperties = rawProperties.where((property) {
                  final matchesType = _selectedTypeFilter == 'All' ||
                      property.propertyType.toLowerCase() ==
                          _selectedTypeFilter.toLowerCase();

                  final matchesSearch = _searchQuery.isEmpty ||
                      property.title.toLowerCase().contains(_searchQuery) ||
                      property.location.toLowerCase().contains(_searchQuery) ||
                      property.propertyType.toLowerCase().contains(_searchQuery) ||
                      property.price.toString().contains(_searchQuery);

                  return matchesType && matchesSearch;
                }).toList();

                if (rawProperties.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.home_work_outlined,
                    title: 'No Properties Available Yet',
                    message:
                        'No property listings found in Cloud Firestore. Log in as an agent to create a property listing.',
                    actionLabel: 'Agent Login',
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  );
                }

                if (filteredProperties.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Properties',
                    message: 'No property listings match your search criteria "$_searchQuery".',
                    actionLabel: 'Clear Search',
                    onAction: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedTypeFilter = 'All';
                      });
                    },
                  );
                }

                // Responsive Layout using LayoutBuilder
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    double childAspectRatio = 0.74;

                    if (constraints.maxWidth >= 1200) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.72;
                    } else if (constraints.maxWidth >= 900) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.74;
                    } else if (constraints.maxWidth >= 600) {
                      crossAxisCount = 2;
                      childAspectRatio = 0.76;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 0.78;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProperties.length,
                        itemBuilder: (context, index) {
                          final property = filteredProperties[index];

                          return PropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PropertyDetailsScreen(property: property),
                                ),
                              );
                            },
                            onBookViewing: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ViewingSchedulerScreen(property: property),
                                ),
                              );
                            },
                          );
                        },
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
  }
}
