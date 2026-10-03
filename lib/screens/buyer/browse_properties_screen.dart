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
    '2 BHK',
    'Apartment',
    'Under ₹50k',
    'Villa',
    'Penthouse',
    'Studio',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D3D3D), Color(0xFF1A1A1A)],
                ),
                border: Border.all(color: const Color(0xFF4A4A4A), width: 0.5),
              ),
              child: const Icon(Icons.home, size: 18, color: Color(0xFFE6E6E6)),
            ),
            const SizedBox(width: 10),
            const Text(
              'HomeFind',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
            ),
            child: IconButton(
              icon: const Icon(Icons.lock_person_outlined, size: 20, color: AppTheme.textPrimary),
              tooltip: 'Agent Portal Login',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 1. Hero Banner + Overlapping Search Bar matching Mockup Specs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Hero Card Container
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/property1.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.88),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 54),
                      alignment: Alignment.topLeft,
                      child: const Text(
                        "Find a place you'll love\nto call home",
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  // Overlapping Pill Search Bar (Matching Mockup Specs)
                  Positioned(
                    bottom: -22,
                    left: 14,
                    right: 14,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF232323), Color(0xFF171717)],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF383838), width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: 'Search by location, property...',
                          hintStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9A9A), size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppTheme.textSecondary, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // 3. Category Filter Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _typeFilters.length,
                itemBuilder: (context, index) {
                  final filter = _typeFilters[index];
                  final isSelected = _selectedTypeFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTypeFilter = filter;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF5A5A5A), Color(0xFF3A3A3A)],
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF1C1C1C),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6B6B6B) : const Color(0xFF2E2E2E),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 4. Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Featured properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // 5. Real-time Firestore Stream Grid Body
            StreamBuilder<List<Property>>(
              stream: _propertyService.getPropertiesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: LoadingWidget(message: 'Fetching real-time listings from Firestore...'),
                  );
                }

                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: EmptyStateWidget(
                      icon: Icons.error_outline,
                      title: 'Firestore Notice',
                      message: 'Unable to access Cloud Firestore. Please check your connection.',
                    ),
                  );
                }

                final rawProperties = snapshot.data ?? [];

                // Filter logic
                final filteredProperties = rawProperties.where((property) {
                  bool matchesType = true;
                  if (_selectedTypeFilter == 'Under ₹50k') {
                    matchesType = property.price <= 50000;
                  } else if (_selectedTypeFilter == '2 BHK') {
                    matchesType = property.bedrooms == 2;
                  } else if (_selectedTypeFilter != 'All') {
                    matchesType = property.propertyType.toLowerCase() == _selectedTypeFilter.toLowerCase();
                  }

                  final matchesSearch = _searchQuery.isEmpty ||
                      property.title.toLowerCase().contains(_searchQuery) ||
                      property.location.toLowerCase().contains(_searchQuery) ||
                      property.propertyType.toLowerCase().contains(_searchQuery) ||
                      property.price.toString().contains(_searchQuery);

                  return matchesType && matchesSearch;
                }).toList();

                if (rawProperties.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: EmptyStateWidget(
                      icon: Icons.home_work_outlined,
                      title: 'No Properties Available Yet',
                      message: 'No property listings found in Cloud Firestore. Log in as an agent to post a property listing.',
                      actionLabel: 'Agent Login',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                    ),
                  );
                }

                if (filteredProperties.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: EmptyStateWidget(
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
                    ),
                  );
                }

                // Responsive Layout Builder
                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1;
                    double childAspectRatio = 0.68;

                    if (constraints.maxWidth >= 1200) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.68;
                    } else if (constraints.maxWidth >= 900) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.68;
                    } else if (constraints.maxWidth >= 600) {
                      crossAxisCount = 2;
                      childAspectRatio = 0.68;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 0.74;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
 