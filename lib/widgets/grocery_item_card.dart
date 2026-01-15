import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/grocery_item.dart';
import '../theme/app_theme.dart';

class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GroceryItemCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.categoryColors[item.category] ??
        AppTheme.categoryColors['Other']!;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isChecked
                      ? AppTheme.primaryColor
                      : Colors.grey.shade200,
                ),
                child: Icon(
                  item.isChecked ? Icons.check : Icons.circle_outlined,
                  color: item.isChecked ? Colors.white : Colors.grey.shade600,
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
                        fontWeight: FontWeight.w600,
                        color: item.isChecked
                            ? Colors.grey.shade400
                            : Colors.black87,
                        decoration:
                            item.isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: categoryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
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
                            '\$${item.estimatedPrice!.toStringAsFixed(2)}',
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
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.edit,
                            size: 18, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: onEdit,
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete,
                            size: 18, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text('Delete',
                            style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                    onTap: onDelete,
                  ),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
