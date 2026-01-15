import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';

class AddEditItemDialog extends StatefulWidget {
  final GroceryItem? item;
  final Function(GroceryItem) onSave;

  const AddEditItemDialog({
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<AddEditItemDialog> {
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController priceController;
  late TextEditingController notesController;
  late String selectedCategory;
  late String selectedUnit;

  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Pantry',
    'Frozen',
    'Beverages',
    'Snacks',
    'Other',
  ];

  final List<String> units = [
    'pcs',
    'kg',
    'g',
    'l',
    'ml',
    'lb',
    'oz',
    'cup',
    'tbsp',
    'tsp',
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item?.name ?? '');
    quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    priceController = TextEditingController(
      text: widget.item?.estimatedPrice?.toString() ?? '',
    );
    notesController = TextEditingController(text: widget.item?.notes ?? '');
    selectedCategory = widget.item?.category ?? 'Other';
    selectedUnit = widget.item?.unit ?? 'pcs';
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter item name')),
      );
      return;
    }

    final newItem = GroceryItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: nameController.text,
      category: selectedCategory,
      quantity: int.tryParse(quantityController.text) ?? 1,
      unit: selectedUnit,
      isChecked: widget.item?.isChecked ?? false,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      estimatedPrice: double.tryParse(priceController.text),
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item == null ? 'Add Item' : 'Edit Item',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),

              // Item Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Milk, Bread, Apples',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
              ),
              SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value ?? 'Other');
                },
              ),
              SizedBox(height: 16),

              // Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Qty',
                        prefixIcon:
                            Icon(Icons.production_quantity_limits_outlined),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                      ),
                      items: units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedUnit = value ?? 'pcs');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Price
              TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Estimated Price (Optional)',
                  hintText: '\$0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              SizedBox(height: 16),

              // Notes
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any notes...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveItem,
                      child: Text(
                          widget.item == null ? 'Add Item' : 'Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
