// File: lib/screens/agent/add_property_screen.dart

import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../services/asset_image_service.dart';
import '../../services/auth_service.dart';
import '../../services/property_service.dart';
import '../../services/viewing_slot_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/property_image_picker.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedroomsController = TextEditingController(text: '2');
  final _bathroomsController = TextEditingController(text: '2');

  String _selectedPropertyType = 'Apartment';
  final List<String> _propertyTypes = [
    'Apartment',
    'Villa',
    'Penthouse',
    'Studio',
    'Townhouse',
    'Commercial',
  ];

  String _selectedAssetImage = AssetImageService.availablePropertyAssets.first;
  String? _imageErrorText;

  final AuthService _authService = AuthService();
  final PropertyService _propertyService = PropertyService();
  final ViewingSlotService _slotService = ViewingSlotService();

  bool _isSaving = false;
  String _statusMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  Future<void> _submitProperty() async {
    setState(() {
      _imageErrorText = null;
    });

    final isFormValid = _formKey.currentState!.validate();
    if (_selectedAssetImage.isEmpty) {
      setState(() {
        _imageErrorText = 'Please select a property image asset.';
      });
      return;
    }

    if (!isFormValid) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent authentication required to create a listing.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = 'Saving property listing to Cloud Firestore...';
    });

    try {
      // Create property document in Firestore with local asset path
      final property = Property(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        area: double.parse(_areaController.text.trim()),
        location: _locationController.text.trim(),
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        propertyType: _selectedPropertyType,
        imageUrls: [_selectedAssetImage],
        agentId: currentUser.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final String createdPropertyId = await _propertyService.createProperty(property);

      // Seed default viewing slots for this property in Firestore
      setState(() {
        _statusMessage = 'Initializing viewing slots in Cloud Firestore...';
      });
      await _slotService.seedDefaultSlotsForProperty(createdPropertyId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property listing published successfully!'),
            backgroundColor: AppTheme.secondaryEmerald,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish property: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Property Information',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Fill out the property details and choose a local property photo asset.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // Image Picker Widget (Local Asset Selector)
                        PropertyImagePicker(
                          selectedAsset: _selectedAssetImage,
                          onAssetSelected: (asset) {
                            setState(() {
                              _selectedAssetImage = asset;
                              _imageErrorText = null;
                            });
                          },
                          errorText: _imageErrorText,
                        ),
                        const SizedBox(height: 24),

                        // Property Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Property Title *',
                            hintText: 'e.g., Modern 2 BHK Apartment',
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (v) =>
                              Validators.validateMinLength(v, 'Property Title', 5),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            hintText: 'Provide detailed information about layout, amenities, nearby expressways...',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (v) =>
                              Validators.validateRequired(v, 'Description'),
                        ),
                        const SizedBox(height: 16),

                        // Price & Area
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Price (₹) *',
                                  hintText: '8500000',
                                  prefixIcon: Icon(Icons.currency_rupee),
                                ),
                                validator: (v) =>
                                    Validators.validatePositiveNumber(v, 'Price'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _areaController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Area (sq.ft) *',
                                  hintText: '1250',
                                  prefixIcon: Icon(Icons.square_foot),
                                ),
                                validator: (v) =>
                                    Validators.validatePositiveNumber(v, 'Area'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location / Address *',
                            hintText: 'e.g., Navi Mumbai',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) =>
                              Validators.validateRequired(v, 'Location'),
                        ),
                        const SizedBox(height: 16),

                        // Bedrooms & Bathrooms
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _bedroomsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Bedrooms *',
                                  prefixIcon: Icon(Icons.king_bed_outlined),
                                ),
                                validator: (v) => Validators.validateNonNegativeInteger(
                                    v, 'Bedrooms'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _bathroomsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Bathrooms *',
                                  prefixIcon: Icon(Icons.bathtub_outlined),
                                ),
                                validator: (v) => Validators.validateNonNegativeInteger(
                                    v, 'Bathrooms'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Property Type Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPropertyType,
                          decoration: const InputDecoration(
                            labelText: 'Property Type *',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          items: _propertyTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedPropertyType = val;
                                // Auto-suggest matching asset
                                _selectedAssetImage =
                                    AssetImageService.getAssetForType(val);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 28),

                        // Saving Status Indicator
                        if (_isSaving) ...[
                          Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Submit Button
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSaving ? null : _submitProperty,
                            icon: const Icon(Icons.post_add),
                            label: Text(
                              _isSaving ? 'Publishing Listing...' : 'Publish Property Listing',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 