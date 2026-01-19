import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class AddEditItemDialog extends StatefulWidget {
  final GroceryItem? item;
  final Function(GroceryItem) onSave;

  const AddEditItemDialog({super.key, 
    this.item,
    required this.onSave,
  });

  @override
  State<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
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
    if (!_formKey.currentState!.validate()) {
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.03),
              AppTheme.secondaryColor.withOpacity(0.03),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar with darker gradient
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Color(0xFF1976D2),
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.item == null 
                        ? Icons.add_shopping_cart_rounded 
                        : Icons.edit_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.item == null ? 'Add Item' : 'Edit Item',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF2196F3),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Basic Information
                      _buildSectionTitle('Basic Information', Icons.info_outline),
                      SizedBox(height: 16),
                      
                      _buildCard(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              autofocus: widget.item == null,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.poppins(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Item Name *',
                                hintText: 'e.g., Whole Milk, Fresh Bread',
                                prefixIcon: Icon(Icons.shopping_bag_rounded, color: AppTheme.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.backgroundColor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter an item name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_rounded, color: AppTheme.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.backgroundColor,
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppTheme.categoryColors[category],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(category),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedCategory = value ?? 'Other');
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28),

                      // Section: Quantity & Pricing
                      _buildSectionTitle('Quantity & Pricing', Icons.shopping_cart_outlined),
                      SizedBox(height: 16),

                      _buildCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    style: GoogleFonts.poppins(fontSize: 16),
                                    decoration: InputDecoration(
                                      labelText: 'Quantity *',
                                      prefixIcon: Icon(Icons.inventory_2_rounded, color: AppTheme.primaryColor),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.backgroundColor,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: selectedUnit,
                                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                                    decoration: InputDecoration(
                                      labelText: 'Unit',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.backgroundColor,
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
                            TextFormField(
                              controller: priceController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.poppins(fontSize: 16),
                              decoration: InputDecoration(
                                labelText: 'Estimated Price',
                                hintText: '${SettingsService.getCurrencySymbol()}0.00',
                                helperText: 'Optional - helps track total cost',
                                prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.primaryColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28),

                      // Section: Additional Notes
                      _buildSectionTitle('Additional Notes', Icons.notes_rounded),
                      SizedBox(height: 16),

                      _buildCard(
                        child: TextFormField(
                          controller: notesController,
                          maxLines: 4,
                          style: GoogleFonts.poppins(fontSize: 15),
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            hintText: 'Add any special instructions or preferences...',
                            helperText: 'Optional',
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 60),
                              child: Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.backgroundColor,
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976D2).withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _saveItem,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.item == null ? Icons.add_rounded : Icons.check_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        widget.item == null ? 'Add to List' : 'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor.withOpacity(0.2), AppTheme.secondaryColor.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
