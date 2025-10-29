import 'package:edudoc_app_mdv/state/app_state.dart' show AppScreen;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
// Assuming AppState and AppScreen are accessible via imports/scope

class LibraryShelfItem extends StatelessWidget {
  final Product product;
  const LibraryShelfItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<dynamic>(context, listen: false);
    final theme = Theme.of(context);
    final Color backupColor = const Color(0xFF14B8A6);

    // Get the appropriate icon based on product type
    IconData typeIcon;
    if (product.type == 'Notes') {
      typeIcon = Icons.note_alt;
    } else if (product.type == 'Books') {
      typeIcon = Icons.book;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    } else {
      typeIcon = Icons.article;
    }

    final bool hasImage =
        product.imageUrl != null && product.imageUrl.isNotEmpty;

    // --- Dynamic Media Widget ---
    // Reduced height to free up maximum vertical space for text and padding
    const double mediaHeight = 80.0;

    Widget mediaWidget;

    if (hasImage) {
      // Option 1: Display Network Image
      mediaWidget = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          product.imageUrl,
          width: double.infinity,
          height: mediaHeight,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback if image fails to load
            return Icon(typeIcon, size: 36, color: backupColor);
          },
        ),
      );
    } else {
      // Option 2: Display Styled Icon Placeholder
      mediaWidget = Container(
        width: double.infinity,
        height: mediaHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: backupColor.withOpacity(0.5)),
        ),
        child: Center(child: Icon(typeIcon, size: 36, color: backupColor)),
      );
    }
    // --- End Dynamic Media Widget ---

    return Card(
      // TIGHTENING: Reduced horizontal margin
      margin: const EdgeInsets.symmetric(horizontal: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            appState.navigate(AppScreen.reading, id: product.id.toString()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Media Area
            mediaWidget,

            // 2. Text Content (Aggressively small padding)
            Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 2.0,
                right: 2.0,
                bottom: 4.0,
              ), // Reduced all padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 9, // Smallest font size
                      height: 1.0,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Read Now',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 8, // Very small font size
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
