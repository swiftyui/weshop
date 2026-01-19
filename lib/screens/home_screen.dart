import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/grocery_item.dart';
import '../models/weekly_list.dart';
import '../models/grocery_item_with_week.dart';
import '../services/storage_service.dart';
import '../services/settings_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grocery_item_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_edit_item_dialog.dart';
import 'settings_screen.dart';
import 'weekly_lists_screen.dart';
import 'templates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GroceryItem> items = [];
  List<GroceryItemWithWeek> itemsWithWeeks = [];
  String filterCategory = 'All';
  WeeklyList? activeWeek;
  List<String> frequentItems = [];
  bool isSelectionMode = false;
  Set<String> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadFrequentItems();
  }

  void _enterSelectionMode(String itemId) {
    setState(() {
      isSelectionMode = true;
      selectedItemIds.add(itemId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      isSelectionMode = false;
      selectedItemIds.clear();
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (selectedItemIds.contains(itemId)) {
        selectedItemIds.remove(itemId);
        if (selectedItemIds.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedItemIds.add(itemId);
      }
    });
  }

  void _selectAllItems() {
    setState(() {
      selectedItemIds.clear();
      for (var itemData in filteredItems) {
        if (itemData is GroceryItemWithWeek) {
          selectedItemIds.add(itemData.item.id);
        } else {
          selectedItemIds.add((itemData as GroceryItem).id);
        }
      }
    });
  }

  void _markSelectedAsBought() async {
    for (var itemId in selectedItemIds) {
      // Find the item
      GroceryItem? item;
      String? weekId;
      
      for (var itemData in filteredItems) {
        if (itemData is GroceryItemWithWeek) {
          if (itemData.item.id == itemId) {
            item = itemData.item;
            weekId = itemData.week?.id;
            break;
          }
        } else if ((itemData as GroceryItem).id == itemId) {
          item = itemData;
          break;
        }
      }
      
      if (item != null && !item.isChecked) {
        final updatedItem = item.copyWith(isChecked: true);
        StorageService.trackItemPurchase(item.name);
        
        if (weekId != null) {
          await StorageService.updateItemInWeek(weekId, updatedItem);
        } else if (activeWeek != null) {
          await StorageService.updateItemInWeek(activeWeek!.id, updatedItem);
        } else {
          await StorageService.updateItem(updatedItem);
        }
      }
    }
    
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedItemIds.length} item${selectedItemIds.length != 1 ? 's' : ''} marked as bought'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    _exitSelectionMode();
  }

  void _loadFrequentItems() async {
    final items = await StorageService.getTopFrequentItems(limit: 6);
    setState(() {
      frequentItems = items;
    });
  }

  void _loadItems() async {
    final week = await StorageService.getActiveWeek();
    List<GroceryItem> loadedItems;
    List<GroceryItemWithWeek> loadedItemsWithWeeks = [];
    
    if (week != null) {
      loadedItems = await StorageService.getItemsForWeek(week.id);
    } else {
      // Load all items from all weeks
      final allData = await StorageService.getAllItemsFromAllWeeks();
      final legacyItems = allData['legacyItems'] as List<GroceryItem>;
      final weekItems = allData['itemsWithWeeks'] as List<Map<String, dynamic>>;
      
      // Combine legacy items
      loadedItems = legacyItems;
      
      // Build items with weeks
      for (var data in weekItems) {
        loadedItemsWithWeeks.add(GroceryItemWithWeek(
          item: data['item'] as GroceryItem,
          week: data['week'] as WeeklyList,
        ));
      }
    }
    
    setState(() {
      activeWeek = week;
      items = loadedItems;
      itemsWithWeeks = loadedItemsWithWeeks;
    });
  }

  void _addItem(GroceryItem item) async {
    if (activeWeek != null) {
      await StorageService.addItemToWeek(activeWeek!.id, item);
    } else {
      await StorageService.addItem(item);
    }
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
    if (activeWeek != null) {
      await StorageService.updateItemInWeek(activeWeek!.id, item);
    } else {
      await StorageService.updateItem(item);
    }
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} updated'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _deleteItem(String id, String name, {String? weekId}) async {
    if (weekId != null) {
      // Item belongs to a specific week
      await StorageService.deleteItemFromWeek(weekId, id);
    } else if (activeWeek != null) {
      // We're in a week view
      await StorageService.deleteItemFromWeek(activeWeek!.id, id);
    } else {
      // Legacy item
      await StorageService.deleteItem(id);
    }
    _loadItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name removed from list'),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _toggleItem(GroceryItem item, {String? weekId}) {
    final updatedItem = item.copyWith(isChecked: !item.isChecked);
    // Track frequently bought items when checking off
    if (updatedItem.isChecked) {
      StorageService.trackItemPurchase(item.name);
    }
    if (weekId != null) {
      StorageService.updateItemInWeek(weekId, updatedItem).then((_) => _loadItems());
    } else if (activeWeek != null) {
      StorageService.updateItemInWeek(activeWeek!.id, updatedItem).then((_) => _loadItems());
    } else {
      StorageService.updateItem(updatedItem).then((_) => _loadItems());
    }
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

  List<dynamic> get filteredItems {
    List<dynamic> allItems = [];
    
    // Add items from active week or legacy items
    if (filterCategory == 'All') {
      allItems.addAll(items);
    } else {
      allItems.addAll(items.where((item) => item.category == filterCategory));
    }
    
    // Add items with weeks when in all view mode
    if (activeWeek == null) {
      if (filterCategory == 'All') {
        allItems.addAll(itemsWithWeeks);
      } else {
        allItems.addAll(itemsWithWeeks.where((iw) => iw.item.category == filterCategory));
      }
    }
    
    return allItems;
  }

  List<GroceryItem> get checkedItems {
    final allGroceryItems = <GroceryItem>[];
    for (var item in filteredItems) {
      if (item is GroceryItem) {
        allGroceryItems.add(item);
      } else if (item is GroceryItemWithWeek) {
        allGroceryItems.add(item.item);
      }
    }
    return allGroceryItems.where((item) => item.isChecked).toList();
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
            backgroundColor: Color(0xFF1976D2),
            actions: [
              if (isSelectionMode) ...[
                TextButton.icon(
                  icon: Icon(Icons.select_all, color: Colors.white, size: 20),
                  label: Text(
                    'All',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _selectAllItems,
                ),
                TextButton.icon(
                  icon: Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                  label: Text(
                    'Bought',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: selectedItemIds.isEmpty ? null : _markSelectedAsBought,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  tooltip: 'Cancel',
                  onPressed: _exitSelectionMode,
                ),
                SizedBox(width: 8),
              ] else ...[
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
                              // Header banner
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.secondaryColor,
                                      AppTheme.primaryColor,
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
                                        Icons.clear_all_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Clear Completed?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Content
                              Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '${checkedItems.length} completed item${checkedItems.length != 1 ? 's' : ''}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'This will remove all checked items from your list.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 24),
                                    
                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Material(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                            child: InkWell(
                                              onTap: () => Navigator.pop(context),
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
                                                  AppTheme.primaryColor,
                                                  AppTheme.secondaryColor,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Clear items based on their source
                                                  for (var itemData in filteredItems) {
                                                    GroceryItem item;
                                                    String? weekId;
                                                    
                                                    if (itemData is GroceryItemWithWeek) {
                                                      item = itemData.item;
                                                      weekId = itemData.week?.id;
                                                    } else {
                                                      item = itemData as GroceryItem;
                                                    }
                                                    
                                                    if (item.isChecked) {
                                                      if (weekId != null) {
                                                        await StorageService.deleteItemFromWeek(weekId, item.id);
                                                      } else {
                                                        await StorageService.deleteItem(item.id);
                                                      }
                                                    }
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
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 14),
                                                  child: Text(
                                                    'Clear',
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
                  },
                ),
              if (activeWeek != null)
                IconButton(
                  icon: Icon(Icons.view_list_rounded, color: Colors.white),
                  tooltip: 'View All Items',
                  onPressed: () async {
                    await StorageService.clearActiveWeek();
                    _loadItems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing all items'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                ),
              IconButton(
                icon: Icon(Icons.calendar_month_rounded, color: Colors.white),
                tooltip: 'Weekly Lists',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeeklyListsScreen(),
                    ),
                  ).then((_) => _loadItems());
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
                  ).then((_) => setState(() {}));
                },
              ),
              IconButton(
                icon: Icon(Icons.dashboard_customize_rounded, color: Colors.white),
                tooltip: 'Templates',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemplatesScreen(weekId: activeWeek?.id),
                    ),
                  ).then((count) {
                    if (count != null && count > 0) {
                      _loadItems();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $count items from template'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
                    }
                  });
                },
              ),
              SizedBox(width: 8),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                children: [
                  Image.asset(
                    'assets/icon/icon_transparent.png',
                    width: 36,
                    height: 36,
                  ),
                  SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Milk',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'Please',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.95),
                              letterSpacing: 0.5,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      if (activeWeek != null) ...[
                        SizedBox(height: 2),
                        Text(
                          activeWeek!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
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
          if (items.isNotEmpty || itemsWithWeeks.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          icon: Icons.inventory_2_rounded,
                          value: '${items.length + itemsWithWeeks.length}',
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
                          value: '${SettingsService.getCurrencySymbol()}${_calculateTotalCost().toStringAsFixed(0)}',
                          label: 'Est. Cost',
                          color: AppTheme.accentColor,
                        ),
                      ],
                    ),
                    if (activeWeek == null && itemsWithWeeks.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.1),
                              AppTheme.secondaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Viewing All Items from All Weeks',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

          // Frequently Bought Items
          if (frequentItems.isNotEmpty && filteredItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.08),
                      AppTheme.secondaryColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quick Add Favorites',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: frequentItems.map((itemName) {
                        return Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              final uuid = Uuid();
                              final item = GroceryItem(
                                id: uuid.v4(),
                                name: itemName,
                                category: 'Other',
                                quantity: 1,
                                unit: 'pcs',
                                createdAt: DateTime.now(),
                                isChecked: false,
                              );
                              _addItem(item);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    itemName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
            SliverPadding(
              padding: EdgeInsets.only(bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final itemData = filteredItems[index];
                    
                    if (itemData is GroceryItemWithWeek) {
                      final item = itemData.item;
                      final week = itemData.week;
                      return GroceryItemCard(
                        key: ValueKey(item.id),
                        item: item,
                        weekName: week?.name,
                        weekColor: _getWeekColor(index),
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedItemIds.contains(item.id),
                        onToggle: () => _toggleItem(item, weekId: week?.id),
                        onEdit: () => _showAddEditDialog(item),
                        onDelete: () {
                          _deleteItem(item.id, item.name, weekId: week?.id);
                        },
                        onLongPress: () => _enterSelectionMode(item.id),
                        onSelectionTap: () => _toggleItemSelection(item.id),
                      );
                    } else {
                      final item = itemData as GroceryItem;
                      return GroceryItemCard(
                        key: ValueKey(item.id),
                        item: item,
                        isSelectionMode: isSelectionMode,
                        isSelected: selectedItemIds.contains(item.id),
                        onToggle: () => _toggleItem(item),
                        onEdit: () => _showAddEditDialog(item),
                        onDelete: () {
                          _deleteItem(item.id, item.name);
                        },
                        onLongPress: () => _enterSelectionMode(item.id),
                        onSelectionTap: () => _toggleItemSelection(item.id),
                      );
                    }
                  },
                  childCount: filteredItems.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isSelectionMode ? null : Container(
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

  Color _getWeekColor(int index) {
    final colors = [
      Color(0xFF2196F3), // Blue
      Color(0xFF9C27B0), // Purple
      Color(0xFFFF9800), // Orange
      Color(0xFF4CAF50), // Green
      Color(0xFFE91E63), // Pink
      Color(0xFF00BCD4), // Cyan
      Color(0xFFFF5722), // Deep Orange
      Color(0xFF009688), // Teal
    ];
    return colors[index % colors.length];
  }

  double _calculateTotalCost() {
    double total = 0;
    for (var item in items) {
      total += item.estimatedPrice ?? 0;
    }
    for (var itemWithWeek in itemsWithWeeks) {
      total += itemWithWeek.item.estimatedPrice ?? 0;
    }
    return total;
  }
}
