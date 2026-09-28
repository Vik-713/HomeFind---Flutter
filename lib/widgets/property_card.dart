// File: lib/widgets/property_card.dart

import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme/app_theme.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback? onBookViewing;
  final bool showBookButton;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    this.onBookViewing,
    this.showBookButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imagePath = property.primaryImage;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Property Photo Header
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: _buildPropertyImage(imagePath),
                ),
                // Property Type Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      property.propertyType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Body Content
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Clearly Readable Price
                  Text(
                    property.formattedPrice,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.secondaryEmerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: AppTheme.borderSubtle),
                  const SizedBox(height: 10),

                  // 4. Bedrooms & 5. Area Specs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bedroom count
                      Row(
                        children: [
                          const Icon(Icons.king_bed_outlined,
                              size: 18, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${property.bedrooms} Beds',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Bathroom count
                      Row(
                        children: [
                          const Icon(Icons.bathtub_outlined,
                              size: 18, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${property.bathrooms} Baths',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Area
                      Row(
                        children: [
                          const Icon(Icons.square_foot,
                              size: 18, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            property.formattedArea,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showBookButton && onBookViewing != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: FilledButton.icon(
                        onPressed: onBookViewing,
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('Book Viewing'),
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
      errorBuilder: (context, error, stackTrace) =>
          Image.asset('assets/images/property1.jpg', fit: BoxFit.cover),
    );
  }
}
