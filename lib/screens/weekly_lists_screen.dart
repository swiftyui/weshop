import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/weekly_list.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class WeeklyListsScreen extends StatefulWidget {
  const WeeklyListsScreen({super.key});

  @override
  State<WeeklyListsScreen> createState() => _WeeklyListsScreenState();
}

class _WeeklyListsScreenState extends State<WeeklyListsScreen> {
  List<WeeklyList> weeklyLists = [];
  String? activeWeekId;

  @override
  void initState() {
    super.initState();
    _loadWeeklyLists();
  }

  void _loadWeeklyLists() async {
    final lists = await StorageService.getAllWeeklyLists();
    final activeId = StorageService.getActiveWeekId();
    setState(() {
      weeklyLists = lists..sort((a, b) => b.startDate.compareTo(a.startDate));
      activeWeekId = activeId;
    });
  }

  void _createWeeklyList() {
    showDialog(
      context: context,
      builder: (context) => _CreateWeeklyListDialog(
        onSave: (weeklyList) async {
          await StorageService.saveWeeklyList(weeklyList);
          _loadWeeklyLists();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${weeklyList.name} created'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  void _selectWeek(WeeklyList week) async {
    await StorageService.setActiveWeek(week.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _deleteWeek(WeeklyList week) async {
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
              // Header banner
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
                      'Delete Week?',
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
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              week.name,
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
                      'This will permanently delete this week and all its items.',
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
      await StorageService.deleteWeeklyList(week.id);
      _loadWeeklyLists();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${week.name} deleted'),
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
            // AppBar
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
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Weekly Lists',
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

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Organize your shopping by week',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // View All button
                    if (activeWeekId != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          child: InkWell(
                            onTap: () async {
                              await StorageService.clearActiveWeek();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.view_list_rounded, color: AppTheme.primaryColor),
                                  SizedBox(width: 8),
                                  Text(
                                    'View All Items (Normal Mode)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    if (weeklyLists.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 60),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No weekly lists yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first weekly shopping list',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = weeklyLists.removeAt(oldIndex);
                            weeklyLists.insert(newIndex, item);
                          });
                        },
                        children: weeklyLists.map((week) => _buildWeekCard(week)).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          onPressed: _createWeeklyList,
          tooltip: 'Create Weekly List',
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildWeekCard(WeeklyList week) {
    final isActive = week.id == activeWeekId;
    final isCurrentWeek = week.isCurrentWeek();

    return Container(
      key: ValueKey(week.id),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
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
          onTap: () => _selectWeek(week),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          )
                        : null,
                    color: isActive ? null : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        week.startDate.day.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        _getMonthAbbr(week.startDate.month),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            week.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppTheme.primaryColor : Colors.black87,
                            ),
                          ),
                          if (isCurrentWeek) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Current',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        week.getDateRange(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primaryColor,
                    size: 24,
                  )
                else
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
                    onPressed: () => _deleteWeek(week),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

class _CreateWeeklyListDialog extends StatefulWidget {
  final Function(WeeklyList) onSave;

  const _CreateWeeklyListDialog({required this.onSave});

  @override
  State<_CreateWeeklyListDialog> createState() => _CreateWeeklyListDialogState();
}

class _CreateWeeklyListDialogState extends State<_CreateWeeklyListDialog> {
  final nameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Default to current week
    final now = DateTime.now();
    startDate = now.subtract(Duration(days: now.weekday - 1));
    endDate = startDate!.add(Duration(days: 6));
    nameController.text = 'Week of ${startDate!.month}/${startDate!.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Weekly List',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'List Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: startDate!,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                          endDate = date.add(Duration(days: 6));
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('${startDate!.month}/${startDate!.day}'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('to'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: endDate!,
                        firstDate: startDate!,
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => endDate = date);
                      }
                    },
                    icon: Icon(Icons.calendar_today),
                    label: Text('${endDate!.month}/${endDate!.day}'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final weeklyList = WeeklyList(
                          id: Uuid().v4(),
                          name: nameController.text.isEmpty ? 'Week of ${startDate!.month}/${startDate!.day}' : nameController.text,
                          startDate: startDate!,
                          endDate: endDate!,
                          createdAt: DateTime.now(),
                        );
                        widget.onSave(weeklyList);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text('Create'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
