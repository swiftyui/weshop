import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/grocery_item.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';

class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? weekName;
  final Color? weekColor;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionTap;

  const GroceryItemCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.weekName,
    this.weekColor,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelectionTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.categoryColors[item.category] ??
        AppTheme.categoryColors['Other']!;

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.12),
                    AppTheme.secondaryColor.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: Offset(0, 3),
                  ),
                ],
              )
            : null,
        child: Card(
          margin: EdgeInsets.zero,
          elevation: isSelected ? 0 : 1,
          color: isSelected ? Colors.transparent : null,
          child: InkWell(
            onTap: isSelectionMode ? onSelectionTap : onToggle,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.primaryColor.withOpacity(0.1),
            highlightColor: AppTheme.primaryColor.withOpacity(0.05),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox or Selection Checkbox
                  if (isSelectionMode)
                    Container(
                      width: 28,
                      height: 28,
                      margin: EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.secondaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppTheme.primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        isSelected ? Icons.check_rounded : null,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: item.isChecked
                            ? LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.secondaryColor
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: item.isChecked ? null : Colors.grey.shade200,
                      ),
                      child: Icon(
                        item.isChecked ? Icons.check : Icons.circle_outlined,
                        color: item.isChecked
                            ? Colors.white
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  SizedBox(width: 16),

                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: item.isChecked
                                ? Colors.grey.shade400
                                : (isSelected ? Colors.black : Colors.black87),
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            if (weekName != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : (weekColor?.withOpacity(0.15) ??
                                          Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: weekColor?.withOpacity(0.4) ??
                                        Colors.grey.shade400,
                                    width: 1,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ] : [],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: weekColor ?? Colors.grey.shade700,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      weekName!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color:
                                            weekColor ?? Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 6),
                            ],
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected ? Border.all(
                                  color: categoryColor.withOpacity(0.3),
                                  width: 1,
                                ) : null,
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ] : [],
                              ),
                              child: Text(
                                item.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${item.quantity} ${item.unit}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.estimatedPrice != null) ...[
                                      SizedBox(width: 6),
                                      Container(
                                        width: 1,
                                        height: 12,
                                        color: Colors.grey.shade300,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        '${SettingsService.getCurrencySymbol()}${item.estimatedPrice!.toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Actions (hidden in selection mode)
                  if (!isSelectionMode)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: onEdit,
                          child: Row(
                            children: [
                              Icon(Icons.edit,
                                  size: 18, color: AppTheme.primaryColor),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          onTap: onDelete,
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  size: 18, color: AppTheme.errorColor),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: AppTheme.errorColor)),
                            ],
                          ),
                        ),
                      ],
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),
        )); // Closes Container and return statement
  }
}
