// File: lib/screens/buyer/search_explore_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/property_card.dart';
import 'property_details_screen.dart';
import 'viewing_scheduler_screen.dart';

class SearchExploreScreen extends StatefulWidget {
  const SearchExploreScreen({super.key});

  @override
  State<SearchExploreScreen> createState() => _SearchExploreScreenState();
}

class _SearchExploreScreenState extends State<SearchExploreScreen> {
  final PropertyService _propertyService = PropertyService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    '2 BHK',
    'Apartment',
    'Under ₹50k',
    'Villa',
    'Penthouse',
    'Studio',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore properties'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar Input (Matching Mockup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2E2E2E), width: 0.8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search location, property name...',
                  hintStyle: const TextStyle(color: Color(0xFF6B6B6B), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9A9A), size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textSecondary, size: 18),
                          onPressed: () {
                            _searchController.clear();
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

          // 2. Category Filter Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
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
                        category,
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
          const SizedBox(height: 12),

          // 3. Results Stream Grid
          Expanded(
            child: StreamBuilder<List<Property>>(
              stream: _propertyService.getPropertiesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Searching real-time properties...');
                }

                if (snapshot.hasError) {
                  return const EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Search Notice',
                    message: 'Unable to query Firestore properties.',
                  );
                }

                final rawProperties = snapshot.data ?? [];

                final filtered = rawProperties.where((property) {
                  bool matchesCat = true;
                  if (_selectedCategory == 'Under ₹50k') {
                    matchesCat = property.price <= 50000;
                  } else if (_selectedCategory == '2 BHK') {
                    matchesCat = property.bedrooms == 2;
                  } else if (_selectedCategory != 'All') {
                    matchesCat = property.propertyType.toLowerCase() == _selectedCategory.toLowerCase();
                  }

                  final matchesSearch = _searchQuery.isEmpty ||
                      property.title.toLowerCase().contains(_searchQuery) ||
                      property.location.toLowerCase().contains(_searchQuery) ||
                      property.propertyType.toLowerCase().contains(_searchQuery) ||
                      property.price.toString().contains(_searchQuery);

                  return matchesCat && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Matching Properties Found',
                    message: 'No properties match your filter "$_selectedCategory" and search "$_searchQuery".',
                    actionLabel: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      });
                    },
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double childAspectRatio = 0.68;

                    if (constraints.maxWidth >= 1100) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.68;
                    } else if (constraints.maxWidth >= 750) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.68;
                    } else if (constraints.maxWidth >= 550) {
                      crossAxisCount = 2;
                      childAspectRatio = 0.68;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 0.74;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final property = filtered[index];
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
 