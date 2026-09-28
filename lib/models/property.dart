// File: lib/models/property.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final double area; // in sq. ft.
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String propertyType;
  final List<String> imageUrls; // Asset image paths, e.g. ["assets/images/property1.jpg"]
  final String agentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.area,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyType,
    required this.imageUrls,
    required this.agentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromMap(Map<String, dynamic> map, String docId) {
    // Handle single 'image' string or 'imageUrls' list
    List<String> images = [];
    if (map['imageUrls'] != null && (map['imageUrls'] as List).isNotEmpty) {
      images = List<String>.from(map['imageUrls']);
    } else if (map['image'] != null && (map['image'] as String).isNotEmpty) {
      images = [map['image'] as String];
    } else {
      images = ['assets/images/property1.jpg'];
    }

    return Property(
      id: docId,
      title: map['title'] ?? 'Untitled Property',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      area: (map['area'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? 'Unknown Location',
      bedrooms: (map['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (map['bathrooms'] as num?)?.toInt() ?? 0,
      propertyType: map['propertyType'] ?? 'Apartment',
      imageUrls: images,
      agentId: map['agentId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Property.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'area': area,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'propertyType': propertyType,
      'image': imageUrls.isNotEmpty ? imageUrls.first : 'assets/images/property1.jpg',
      'imageUrls': imageUrls,
      'agentId': agentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Primary image asset path
  String get primaryImage =>
      imageUrls.isNotEmpty ? imageUrls.first : 'assets/images/property1.jpg';

  /// Formatted Price string, e.g. ₹85,00,000
  String get formattedPrice {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  /// Formatted Area string, e.g. 1,250 sq.ft
  String get formattedArea {
    final formatter = NumberFormat('#,##0');
    return '${formatter.format(area)} sq.ft';
  }
}
