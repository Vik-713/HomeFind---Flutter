// File: lib/services/property_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../utils/error_handler.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _propertiesCollection =>
      _firestore.collection('properties');

  /// Stream of all properties, sorted by creation date descending
  Stream<List<Property>> getPropertiesStream() {
    return _propertiesCollection.snapshots().map((snapshot) {
      debugPrint('PropertyService: Stream received ${snapshot.docs.length} total property documents from Firestore.');
      final list = snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Stream of properties posted by a specific agent ID
  Stream<List<Property>> getAgentPropertiesStream(String agentId) {
    return _propertiesCollection.snapshots().map((snapshot) {
      final allList = snapshot.docs.map((doc) => Property.fromFirestore(doc)).toList();
      final agentList = allList.where((p) => p.agentId == agentId).toList();
      debugPrint('PropertyService: Agent ($agentId) stream filtered ${agentList.length} properties out of ${allList.length} total properties.');
      agentList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return agentList;
    });
  }

  /// Fetch single property by ID
  Future<Property?> getPropertyById(String propertyId) async {
    try {
      final doc = await _propertiesCollection.doc(propertyId).get();
      if (doc.exists) {
        return Property.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Create a new property document in Cloud Firestore
  /// Returns the generated property ID
  Future<String> createProperty(Property property) async {
    try {
      final docRef = _propertiesCollection.doc();
      final newProperty = Property(
        id: docRef.id,
        title: property.title,
        description: property.description,
        price: property.price,
        area: property.area,
        location: property.location,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        propertyType: property.propertyType,
        imageUrls: property.imageUrls,
        agentId: property.agentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mapData = newProperty.toMap();
      debugPrint('PropertyService: Writing new property document ${docRef.id} to Firestore with agentId: ${property.agentId}');
      await docRef.set(mapData);
      debugPrint('PropertyService: Document ${docRef.id} written successfully to Firestore.');
      return docRef.id;
    } catch (e) {
      debugPrint('PropertyService Error: Failed to write property to Firestore: $e');
      throw ErrorHandler.getErrorMessage(e);
    }
  }

  /// Delete a property listing (for agent management)
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _propertiesCollection.doc(propertyId).delete();
    } catch (e) {
      throw ErrorHandler.getErrorMessage(e);
    }
  }
}
