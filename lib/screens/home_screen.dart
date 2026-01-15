import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/grocery_item.dart';
import '../services/storage_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grocery_item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_edit_item_dialog.dart';

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
    showDialog(
      context: context,
      builder: (context) => AddEditItemDialog(
        item: item,
        onSave: item == null ? _addItem : _updateItem,
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
            expandedHeight: 140,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.surfaceColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'MilkPlease',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (items.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard('${items.length}', 'Total Items'),
                            _buildStatCard(
                                '${checkedItems.length}', 'Completed'),
                            _buildStatCard(
                              '\$${items.fold<double>(0, (sum, item) => sum + (item.estimatedPrice ?? 0)).toStringAsFixed(2)}',
                              'Est. Cost',
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
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
                        backgroundColor: Colors.grey.shade200,
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (items.isNotEmpty)
            FloatingActionButton.extended(
              onPressed: _generatePdf,
              label: Text('Share PDF'),
              icon: Icon(Icons.share),
              backgroundColor: AppTheme.secondaryColor,
              heroTag: 'share_btn',
            ),
          SizedBox(height: 12),
          FloatingActionButton(
            onPressed: () => _showAddEditDialog(null),
            tooltip: 'Add Item',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
