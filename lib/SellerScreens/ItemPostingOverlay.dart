import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../CommonScreens/onboarding.dart';
import '../SellerLogic/post_item.dart';
import 'LocationPicker.dart';

class ItemPostingOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const ItemPostingOverlay({Key? key, required this.onClose}) : super(key: key);

  @override
  State<ItemPostingOverlay> createState() => _ItemPostingOverlayState();
}

class _ItemPostingOverlayState extends State<ItemPostingOverlay> {
  final _formKey = GlobalKey<FormState>();

  String? _condition;
  String? _category;
  bool _manualLocation = false;

  final _titleCtrl       = TextEditingController();
  final _priceCtrl       = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl    = TextEditingController();

  double? _pickedLat;
  double? _pickedLng;
  Uint8List? _pickedImage;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _pickedImage = await file.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await submitNewItem(
        title:       _titleCtrl.text.trim(),
        price:       double.parse(_priceCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        condition:   _condition!,
        category:    _category!,
        location:    _locationCtrl.text.trim(),
        latitude:    _manualLocation ? null : _pickedLat,
        longitude:   _manualLocation ? null : _pickedLng,
        imageBytes:  _pickedImage,
      );

      Navigator.of(context).pop(); // remove spinner
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item posted! 🎉')),
      );

      // Clear all fields
      _titleCtrl.clear();
      _priceCtrl.clear();
      _descriptionCtrl.clear();
      _locationCtrl.clear();
      setState(() {
        _condition = null;
        _category = null;
        _manualLocation = false;
        _pickedImage = null;
        _pickedLat = null;
        _pickedLng = null;
      });

      widget.onClose();
    } catch (err) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post item: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: sh * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Upload Item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image picker
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _pickedImage == null
                            ? Center(
                                child: IconButton(
                                  icon: const Icon(Icons.image, size: 48),
                                  onPressed: _pickImage,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final t = newValue.text;
                            if (t.isEmpty || !t.contains('.')) return newValue;
                            if (t.indexOf('.') != t.lastIndexOf('.')) return oldValue;
                            return newValue;
                          }),
                        ],
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),

                      // Condition dropdown with full labels
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Condition'),
                        value: _condition,
                        items: [
                          'New (In sealed condition)',
                          'Like new (Less than 3 months of use)',
                          'Good condition (3-12 months of use)',
                          'Fair condition (Over 12 months of use)',
                          'Worn (Repair needed)',
                        ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _condition = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      // Category dropdown with icons
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Category'),
                        value: _category,
                        items: [
                          Icons.directions_car,
                          Icons.chair,
                          Icons.checkroom,
                          Icons.watch,
                          Icons.electrical_services,
                          Icons.build,
                          Icons.more_horiz,
                        ].asMap().entries.map((e) {
                          final idx = e.key;
                          final icon = e.value;
                          final labels = [
                            'Vehicles',
                            'Furniture',
                            'Clothes',
                            'Accessories',
                            'Electronics',
                            'Services',
                            'Others'
                          ];
                          return DropdownMenuItem(
                            value: labels[idx],
                            child: Row(
                              children: [
                                Icon(icon, size: 20),
                                const SizedBox(width: 8),
                                Text(labels[idx]),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _category = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      // Manual location toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Enter location manually?'),
                          Switch(
                            value: _manualLocation,
                            onChanged: (val) => setState(() {
                              _manualLocation = val;
                              if (_manualLocation) _pickedLat = _pickedLng = null;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Location input or map picker
                      if (_manualLocation)
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(labelText: 'Location'),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        )
                      else
                        LocationPicker(
                          controller: _locationCtrl,
                          onLocationChanged: (coords, address) {
                            setState(() {
                              _pickedLat = coords.latitude;
                              _pickedLng = coords.longitude;
                              _locationCtrl.text = address;
                            });
                          },
                        ),

                      const SizedBox(height: 16),

                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThriftNestApp.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: _onSubmit,
                          child: const Text('Post Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}