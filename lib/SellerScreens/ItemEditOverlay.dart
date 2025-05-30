// lib/SellerScreens/ItemEditOverlay.dart


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';              
import 'package:image_picker/image_picker.dart';

import '../main.dart';                             
import '../SellerLogic/item_crud.dart';
import '../SellerLogic/seller_listings_service.dart';
import '../SellerLogic/Item_model.dart';
import 'LocationPicker.dart';

class ItemEditOverlay extends StatefulWidget {
  /// The existing item to edit.
  final ItemModel item;
  /// Called to close this overlay.
  final VoidCallback onClose;

  const ItemEditOverlay({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  State<ItemEditOverlay> createState() => _ItemEditOverlayState();
}

class _ItemEditOverlayState extends State<ItemEditOverlay> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _locationCtrl;
  bool _manualLocation = false;
  String? _condition;
  String? _category;
  Uint8List? _pickedImage;

  @override
  void initState() {
    super.initState();
    _titleCtrl       = TextEditingController(text: widget.item.title);
    _priceCtrl       = TextEditingController(text: widget.item.price.toString());
    _descriptionCtrl = TextEditingController(text: widget.item.description);
    _locationCtrl    = TextEditingController(text: widget.item.location);
    _condition       = widget.item.condition;
    _category        = widget.item.category;
  }

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
    final xfile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (xfile != null) {
      final bytes = await xfile.readAsBytes();
      setState(() => _pickedImage = bytes);
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
      await updateItem(
        itemId: widget.item.id,
        title: _titleCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        description: _descriptionCtrl.text.trim(),
        condition: _condition,
        category: _category,
        location: _locationCtrl.text.trim(),
        imageBytes: _pickedImage,
      );

      // Refresh the seller's live list
      final uid = FirebaseAuth.instance.currentUser!.uid;
      SellerListingsService.instance.initForOwner(uid);

      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated!')),
      );
      widget.onClose();
    } catch (err) {
      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $err')),
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
            // ─── Header ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text('Edit Item',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ─── Form ──────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image preview + picker
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: IconButton(
                            iconSize: 48,
                            icon: _pickedImage != null
                                ? Image.memory(_pickedImage!,
                                    fit: BoxFit.cover,
                                    width: 64,
                                    height: 64)
                                : (widget.item.imageBytes != null
                                    ? Image.memory(widget.item.imageBytes!,
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64)
                                    : const Icon(Icons.image,
                                        size: 48, color: Colors.grey)),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      // Price
                      TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                          TextInputFormatter.withFunction((oldV, newV) {
                            final t = newV.text;
                            // prevent more than one dot
                            return t.indexOf('.') != t.lastIndexOf('.')
                                ? oldV
                                : newV;
                          }),
                        ],
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),

                      // Condition
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Condition'),
                        value: _condition,
                        items: [
                          'New (In sealed condition)',
                          'Like new (Less than 3 months of use)',
                          'Good condition (3-12 months of use)',
                          'Fair condition (Over 12 months of use)',
                          'Worn (Repair needed)',
                        ]
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _condition = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),

                      // Category
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
                            'Others',
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

                      // Manual toggle + picker for location
                      SwitchListTile(
                        title: const Text("Enter location manually?"),
                        value: _manualLocation,
                        onChanged: (v) => setState(() => _manualLocation = v),
                      ),
                      const SizedBox(height: 8),

                      // show either a text field or the map-based picker
                      if (_manualLocation) ...[
                        TextFormField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(labelText: 'Location'),
                          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                        ),
                      ] else ...[
                        LocationPicker(
                          controller: _locationCtrl,
                          onLocationChanged: (coords, address) {
                            setState(() => _locationCtrl.text = address);
                          },
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Submit
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
                          child: const Text('Save Changes'),
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
