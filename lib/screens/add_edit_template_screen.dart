import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_template.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class AddEditTemplateScreen extends StatefulWidget {
  final ShoppingTemplate? template;

  const AddEditTemplateScreen({super.key, this.template});

  @override
  State<AddEditTemplateScreen> createState() => _AddEditTemplateScreenState();
}

class _AddEditTemplateScreenState extends State<AddEditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String selectedIcon = 'shopping_cart';
  List<TemplateItem> items = [];

  final List<Map<String, dynamic>> availableIcons = [
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart},
    {'name': 'free_breakfast', 'icon': Icons.free_breakfast},
    {'name': 'celebration', 'icon': Icons.celebration},
    {'name': 'local_dining', 'icon': Icons.local_dining},
    {'name': 'outdoor_grill', 'icon': Icons.outdoor_grill},
    {'name': 'cake', 'icon': Icons.cake},
    {'name': 'local_pizza', 'icon': Icons.local_pizza},
    {'name': 'coffee', 'icon': Icons.coffee},
    {'name': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'lunch_dining', 'icon': Icons.lunch_dining},
    {'name': 'fastfood', 'icon': Icons.fastfood},
    {'name': 'local_grocery_store', 'icon': Icons.local_grocery_store},
  ];

  final List<String> categories = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat',
    'Pantry',
    'Frozen',
    'Beverages',
    'Snacks',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      selectedIcon = widget.template!.icon;
      items = List.from(widget.template!.items);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AddEditTemplateItemScreen(
          categories: categories,
          onSave: (item) {
            setState(() {
              items.add(item);
            });
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _editItem(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AddEditTemplateItemScreen(
          categories: categories,
          item: items[index],
          onSave: (item) {
            setState(() {
              items[index] = item;
            });
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      final template = ShoppingTemplate(
        id: widget.template?.id ?? Uuid().v4(),
        name: _nameController.text.trim(),
        icon: selectedIcon,
        items: items,
      );
      Navigator.pop(context, template);
    } else if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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
          ),
        ),
        child: CustomScrollView(
          slivers: [
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
                      widget.template == null ? Icons.add : Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    widget.template == null ? 'Create Template' : 'Edit Template',
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
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template Name
                      Text(
                        'Template Name',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Weekend Shopping',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a template name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Icon Selection
                      Text(
                        'Select Icon',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: availableIcons.map((iconData) {
                          final isSelected = selectedIcon == iconData['name'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedIcon = iconData['name'];
                              });
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.2),
                                  width: 2,
                                ),
                                boxShadow: isSelected ? [] : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                iconData['icon'],
                                color: isSelected ? Colors.white : AppTheme.primaryColor,
                                size: 28,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 24),

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items (${items.length})',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: Icon(Icons.add_circle_outline, size: 20),
                            label: Text('Add Item'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      
                      if (items.isEmpty)
                        Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.primaryColor.withOpacity(0.3)),
                                SizedBox(height: 8),
                                Text(
                                  'No items yet',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item.quantity} ${item.unit}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (item.estimatedPrice != null) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    '${SettingsService.getCurrencySymbol()}${item.estimatedPrice!.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () => _editItem(index),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 20, color: AppTheme.errorColor),
                                  onPressed: () => _deleteItem(index),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _saveTemplate,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Template',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _AddEditTemplateItemScreen extends StatefulWidget {
  final List<String> categories;
  final TemplateItem? item;
  final Function(TemplateItem) onSave;

  const _AddEditTemplateItemScreen({
    required this.categories,
    required this.onSave,
    this.item,
  });

  @override
  State<_AddEditTemplateItemScreen> createState() => _AddEditTemplateItemScreenState();
}

class _AddEditTemplateItemScreenState extends State<_AddEditTemplateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _priceController = TextEditingController();
  String? selectedCategory;

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
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _quantityController.text = widget.item!.quantity.toString();
      _unitController.text = widget.item!.unit;
      _priceController.text = widget.item!.estimatedPrice?.toString() ?? '';
      selectedCategory = widget.item!.category;
    } else {
      selectedCategory = widget.categories.first;
      _quantityController.text = '1';
      _unitController.text = 'pcs';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(TemplateItem(
        name: _nameController.text.trim(),
        category: selectedCategory!,
        quantity: int.tryParse(_quantityController.text) ?? 1,
        unit: _unitController.text.trim(),
        estimatedPrice: _priceController.text.isEmpty ? null : double.tryParse(_priceController.text),
      ));
      Navigator.pop(context);
    }
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
          ),
        ),
        child: CustomScrollView(
          slivers: [
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
                      widget.item == null ? Icons.add : Icons.edit,
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
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item Name
                      Text(
                        'Item Name',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Milk',
                          prefixIcon: Icon(Icons.shopping_bag_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Category
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.category_outlined),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: widget.categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      SizedBox(height: 24),

                      // Quantity and Unit
                      Text(
                        'Quantity & Unit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                hintText: 'Qty',
                                prefixIcon: Icon(Icons.numbers),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
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
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: _unitController.text.isEmpty ? 'pcs' : _unitController.text,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.scale_outlined),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _unitController.text = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Estimated Price (Optional)
                      Text(
                        'Estimated Price (Optional)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: 'e.g., 3.99',
                          prefixIcon: Icon(Icons.attach_money),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 16),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
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
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      widget.item == null ? 'Add Item' : 'Save Item',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
