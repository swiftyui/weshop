import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_template.dart';
import '../models/grocery_item.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'add_edit_template_screen.dart';

class TemplatesScreen extends StatefulWidget {
  final String? weekId;
  
  const TemplatesScreen({super.key, this.weekId});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<ShoppingTemplate> customTemplates = [];
  final List<ShoppingTemplate> defaultTemplates = [
    ShoppingTemplate(
      id: 'default_1',
      name: 'Weekly Essentials',
      icon: 'shopping_cart',
      items: [
        TemplateItem(name: 'Milk', category: 'Dairy', quantity: 2, unit: 'L'),
        TemplateItem(name: 'Bread', category: 'Pantry', quantity: 1, unit: 'loaf'),
        TemplateItem(name: 'Eggs', category: 'Dairy', quantity: 12, unit: 'pcs'),
        TemplateItem(name: 'Chicken Breast', category: 'Meat', quantity: 500, unit: 'g'),
        TemplateItem(name: 'Bananas', category: 'Fruits', quantity: 6, unit: 'pcs'),
        TemplateItem(name: 'Tomatoes', category: 'Vegetables', quantity: 4, unit: 'pcs'),
        TemplateItem(name: 'Lettuce', category: 'Vegetables', quantity: 1, unit: 'head'),
      ],
    ),
    ShoppingTemplate(
      id: 'default_2',
      name: 'Breakfast Items',
      icon: 'free_breakfast',
      items: [
        TemplateItem(name: 'Cereal', category: 'Pantry', quantity: 1, unit: 'box'),
        TemplateItem(name: 'Orange Juice', category: 'Beverages', quantity: 1, unit: 'L'),
        TemplateItem(name: 'Yogurt', category: 'Dairy', quantity: 6, unit: 'cups'),
        TemplateItem(name: 'Bagels', category: 'Pantry', quantity: 6, unit: 'pcs'),
        TemplateItem(name: 'Cream Cheese', category: 'Dairy', quantity: 1, unit: 'pack'),
        TemplateItem(name: 'Strawberries', category: 'Fruits', quantity: 1, unit: 'pack'),
      ],
    ),
    ShoppingTemplate(
      id: 'default_3',
      name: 'Party Supplies',
      icon: 'celebration',
      items: [
        TemplateItem(name: 'Chips', category: 'Snacks', quantity: 3, unit: 'bags'),
        TemplateItem(name: 'Soda', category: 'Beverages', quantity: 6, unit: 'bottles'),
        TemplateItem(name: 'Pizza', category: 'Frozen', quantity: 2, unit: 'pcs'),
        TemplateItem(name: 'Ice Cream', category: 'Frozen', quantity: 2, unit: 'tubs'),
        TemplateItem(name: 'Salsa', category: 'Pantry', quantity: 2, unit: 'jars'),
        TemplateItem(name: 'Cheese Platter', category: 'Dairy', quantity: 1, unit: 'pack'),
      ],
    ),
    ShoppingTemplate(
      id: 'default_4',
      name: 'Healthy Week',
      icon: 'local_dining',
      items: [
        TemplateItem(name: 'Spinach', category: 'Vegetables', quantity: 1, unit: 'bag'),
        TemplateItem(name: 'Broccoli', category: 'Vegetables', quantity: 2, unit: 'heads'),
        TemplateItem(name: 'Salmon', category: 'Meat', quantity: 400, unit: 'g'),
        TemplateItem(name: 'Quinoa', category: 'Pantry', quantity: 500, unit: 'g'),
        TemplateItem(name: 'Avocados', category: 'Fruits', quantity: 4, unit: 'pcs'),
        TemplateItem(name: 'Greek Yogurt', category: 'Dairy', quantity: 4, unit: 'cups'),
        TemplateItem(name: 'Almonds', category: 'Snacks', quantity: 1, unit: 'pack'),
      ],
    ),
    ShoppingTemplate(
      id: 'default_5',
      name: 'BBQ Essentials',
      icon: 'outdoor_grill',
      items: [
        TemplateItem(name: 'Beef Steaks', category: 'Meat', quantity: 4, unit: 'pcs'),
        TemplateItem(name: 'Burgers', category: 'Meat', quantity: 8, unit: 'patties'),
        TemplateItem(name: 'Hot Dog Buns', category: 'Pantry', quantity: 8, unit: 'pcs'),
        TemplateItem(name: 'BBQ Sauce', category: 'Pantry', quantity: 1, unit: 'bottle'),
        TemplateItem(name: 'Corn', category: 'Vegetables', quantity: 6, unit: 'ears'),
        TemplateItem(name: 'Coleslaw', category: 'Vegetables', quantity: 1, unit: 'pack'),
      ],
    ),
    ShoppingTemplate(
      id: 'default_6',
      name: 'Baking Day',
      icon: 'cake',
      items: [
        TemplateItem(name: 'Flour', category: 'Pantry', quantity: 1, unit: 'kg'),
        TemplateItem(name: 'Sugar', category: 'Pantry', quantity: 500, unit: 'g'),
        TemplateItem(name: 'Butter', category: 'Dairy', quantity: 250, unit: 'g'),
        TemplateItem(name: 'Vanilla Extract', category: 'Pantry', quantity: 1, unit: 'bottle'),
        TemplateItem(name: 'Chocolate Chips', category: 'Snacks', quantity: 1, unit: 'pack'),
        TemplateItem(name: 'Baking Powder', category: 'Pantry', quantity: 1, unit: 'pack'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomTemplates();
  }

  void _loadCustomTemplates() async {
    final templates = await StorageService.getAllTemplates();
    setState(() {
      customTemplates = templates;
    });
  }

  void _createTemplate() async {
    final result = await Navigator.push<ShoppingTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTemplateScreen(),
      ),
    );
    
    if (result != null) {
      await StorageService.saveTemplate(result);
      _loadCustomTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template created'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _editTemplate(ShoppingTemplate template) async {
    final result = await Navigator.push<ShoppingTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTemplateScreen(template: template),
      ),
    );
    
    if (result != null) {
      await StorageService.saveTemplate(result);
      _loadCustomTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template updated'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  void _deleteTemplate(ShoppingTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.errorColor,
                      AppTheme.errorColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Delete Template?',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconData(template.icon),
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              template.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'This will permanently delete this template.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Navigator.pop(context, false),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.errorColor,
                                  AppTheme.errorColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.errorColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, true),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text(
                                    'Delete',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteTemplate(template.id);
      _loadCustomTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template deleted'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _addTemplateToList(ShoppingTemplate template) async {
    final uuid = Uuid();
    int addedCount = 0;

    for (var templateItem in template.items) {
      final item = GroceryItem(
        id: uuid.v4(),
        name: templateItem.name,
        category: templateItem.category,
        quantity: templateItem.quantity,
        unit: templateItem.unit,
        estimatedPrice: templateItem.estimatedPrice,
        createdAt: DateTime.now(),
        isChecked: false,
      );

      if (widget.weekId != null) {
        await StorageService.addItemToWeek(widget.weekId!, item);
      } else {
        await StorageService.addItem(item);
      }
      addedCount++;
    }

    Navigator.pop(context, addedCount);
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
                      Icons.dashboard_customize_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Shopping Templates',
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
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.1),
                            AppTheme.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tips_and_updates, color: AppTheme.primaryColor, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap a template to add all items to your list',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    if (customTemplates.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Your Templates',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      ...customTemplates.map((template) => _buildTemplateCard(template, isCustom: true)).toList(),
                      SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 12),
                        child: Text(
                          'Default Templates',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                    ...defaultTemplates.map((template) => _buildTemplateCard(template, isCustom: false)).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTemplate,
        backgroundColor: AppTheme.primaryColor,
        elevation: 4,
        icon: Icon(Icons.add),
        label: Text(
          'New Template',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(ShoppingTemplate template, {required bool isCustom}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addTemplateToList(template),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(template.icon),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${template.items.length} items',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCustom) ...[
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 20),
                        color: AppTheme.primaryColor,
                        onPressed: () => _editTemplate(template),
                        tooltip: 'Edit template',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 20),
                        color: AppTheme.errorColor,
                        onPressed: () => _deleteTemplate(template),
                        tooltip: 'Delete template',
                      ),
                    ] else
                      Icon(
                        Icons.add_circle,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...template.items.take(5).map((item) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                    if (template.items.length > 5)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${template.items.length - 5} more',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'free_breakfast':
        return Icons.free_breakfast;
      case 'celebration':
        return Icons.celebration;
      case 'local_dining':
        return Icons.local_dining;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.shopping_bag;
    }
  }
}
