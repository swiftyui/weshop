import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/grocery_item.dart';
import '../services/storage_service.dart';
import '../services/settings_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grocery_item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_edit_item_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> items = [];
  String filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final loadedItems = await StorageService.getAllItems();
    setState(() {
      items = loadedItems;
    });
  }

  void _addItem(GroceryItem item) async {
    await StorageService.addItem(item);
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to list'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _updateItem(GroceryItem item) async {
    await StorageService.updateItem(item);
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} updated'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _deleteItem(String id, String name) async {
    await StorageService.deleteItem(id);
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from list'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _toggleItem(GroceryItem item) {
    _updateItem(item.copyWith(isChecked: !item.isChecked));
  }

  void _showAddEditDialog(GroceryItem? item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditItemDialog(
          item: item,
          onSave: item == null ? _addItem : _updateItem,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _generatePdf() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Generating PDF...'),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );
      await PdfService.generateAndSharePdf(items);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  List<GroceryItem> get filteredItems {
    if (filterCategory == 'All') {
      return items;
    }
    return items.where((item) => item.category == filterCategory).toList();
  }

  List<GroceryItem> get checkedItems {
    return filteredItems.where((item) => item.isChecked).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.share_rounded, color: Colors.white),
                  tooltip: 'Share PDF',
                  onPressed: _generatePdf,
                ),
              if (checkedItems.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear_all_rounded, color: Colors.white),
                  tooltip: 'Clear Completed',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Clear Completed Items?'),
                        content: Text('This will remove all checked items from your list.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              for (var item in checkedItems) {
                                StorageService.deleteItem(item.id);
                              }
                              _loadItems();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cleared ${checkedItems.length} items'),
                                  backgroundColor: AppTheme.secondaryColor,
                                ),
                              );
                            },
                            child: Text('Clear', style: TextStyle(color: AppTheme.errorColor)),
                          ),
                        ],
                      ),
                    );  
                  },
                ),
              IconButton(
                icon: Icon(Icons.settings_rounded, color: Colors.white),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  ).then((_) => setState(() {})); // Refresh on return
                },
              ),
              SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 60, bottom: 16),
              title: Row(
                children: [
                  Text(
                    'Milk',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Please',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1976D2), // Darker blue
                      Color(0xFF2196F3), // Medium blue
                      Color(0xFF64B5F6).withOpacity(0.9), // Light blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF1976D2).withOpacity(0.3),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stat Cards
          if (items.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      icon: Icons.inventory_2_rounded,
                      value: '${items.length}',
                      label: 'Total',
                      color: AppTheme.primaryColor,
                    ),
                    _buildStatCard(
                      icon: Icons.check_circle_rounded,
                      value: '${checkedItems.length}',
                      label: 'Done',
                      color: AppTheme.secondaryColor,
                    ),
                    _buildStatCard(
                      icon: Icons.attach_money_rounded,
                      value: '${SettingsService.getCurrencySymbol()}${items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0)).toStringAsFixed(0)}',
                      label: 'Est. Cost',
                      color: AppTheme.accentColor,
                    ),
                  ],
                ),
              ),
            ),

          // Filter Chips
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = filterCategory == category;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => filterCategory = category);
                        },
                        backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Items List
          if (filteredItems.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                title: 'No items yet',
                subtitle: filterCategory == 'All'
                    ? 'Add your first item to get started!'
                    : 'No items in $filterCategory category',
                icon: Icons.shopping_basket_outlined,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = filteredItems[index];
                  return GroceryItemCard(
                    item: item,
                    onToggle: () => _toggleItem(item),
                    onEdit: () => _showAddEditDialog(item),
                    onDelete: () {
                      _deleteItem(item.id, item.name);
                    },
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF1976D2).withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEditDialog(null),
          tooltip: 'Add Item',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
