// File: lib/services/asset_image_service.dart
//
// Asset Image Manager Service
// Manages local property image assets in assets/images/ without using Firebase Cloud Storage.

class AssetImageService {
  /// Predefined local property asset images bundled with the app
  static const List<String> availablePropertyAssets = [
    'assets/images/property1.jpg',
    'assets/images/property2.jpg',
    'assets/images/property3.jpg',
    'assets/images/property4.jpg',
    'assets/images/property5.jpg',
  ];

  /// Get default primary asset image path
  static String get defaultAsset => availablePropertyAssets.first;

  /// Get sample asset for a given property index or property type
  static String getAssetForType(String propertyType) {
    switch (propertyType.toLowerCase()) {
      case 'apartment':
        return 'assets/images/property1.jpg';
      case 'villa':
        return 'assets/images/property2.jpg';
      case 'studio':
        return 'assets/images/property3.jpg';
      case 'penthouse':
        return 'assets/images/property4.jpg';
      case 'townhouse':
        return 'assets/images/property5.jpg';
      default:
        return 'assets/images/property1.jpg';
    }
  }
}
 