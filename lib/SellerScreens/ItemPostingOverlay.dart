import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../CommonScreens/onboarding.dart';

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
  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _priceCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
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
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.camera_alt,
                          color: ThriftNestApp.primaryColor,
                        ),
                        label: const Text('Add Photo'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceCtrl,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          // 1) Allow only digits and dot
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9\.]')),
                          // 2) Prevent entering more than one dot
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            if (text.isEmpty || !text.contains('.')) {
                              return newValue;
                            }
                            // if there's more than one dot, reject
                            if (text.indexOf('.') != text.lastIndexOf('.')) {
                              return oldValue;
                            }
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
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _condition = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
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
                          final label = [
                            'Vehicles',
                            'Furniture',
                            'Clothes',
                            'Accessories',
                            'Electronics',
                            'Services',
                            'Others'
                          ][idx];
                          return DropdownMenuItem(
                            value: label,
                            child: Row(
                              children: [
                                Icon(icon, size: 20),
                                const SizedBox(width: 8),
                                Text(label),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _category = v),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(labelText: 'Location'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
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
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Add post logic here
                            }
                          },
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