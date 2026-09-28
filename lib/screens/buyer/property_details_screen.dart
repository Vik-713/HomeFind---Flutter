// File: lib/screens/buyer/property_details_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../theme/app_theme.dart';
import 'viewing_scheduler_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _activeImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final property = widget.property;
    final images = property.imageUrls;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Photo Gallery / Carousel Header
                if (images.isNotEmpty) ...[
                  SizedBox(
                    height: 360,
                    child: PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _activeImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final imagePath = images[index];
                        return _buildPropertyImage(imagePath);
                      },
                    ),
                  ),
                  if (images.length > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          width: _activeImageIndex == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _activeImageIndex == index
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else
                  _buildPlaceholder(),

                // 2. Property Main Info
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Property Type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            property.formattedPrice,
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: AppTheme.secondaryEmerald,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Chip(
                            label: Text(property.propertyType),
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        property.title,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            property.location,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Key Features Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeatureItem(
                              icon: Icons.king_bed_outlined,
                              label: '${property.bedrooms} Bedrooms',
                            ),
                            _buildFeatureItem(
                              icon: Icons.bathtub_outlined,
                              label: '${property.bathrooms} Bathrooms',
                            ),
                            _buildFeatureItem(
                              icon: Icons.square_foot,
                              label: property.formattedArea,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      Text(
                        'About This Property',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Direct Viewing Scheduler CTA
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ViewingSchedulerScreen(property: property),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month, size: 22),
                          label: const Text('Schedule Property Viewing'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryNavy, size: 26),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyImage(String path) {
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
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 280,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.apartment, size: 72, color: Colors.grey),
      ),
    );
  }
}
