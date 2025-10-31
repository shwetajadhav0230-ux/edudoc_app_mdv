// lib/widgets/custom_widgets/library_grid_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart' show AppState, AppScreen;

class LibraryGridItem extends StatelessWidget {
  final Product product;

  const LibraryGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final theme = Theme.of(context);
    final Color accentColor = const Color(0xFF14B8A6); // Backup/Read Now color

    // Determine content status and icons
    final String statusText = product.isFree ? 'Free' : 'Owned';
    final IconData typeIcon = product.type == 'Books'
        ? Icons.book
        : Icons.note_alt;
    final bool hasImage =
        product.imageUrl != null && product.imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: () =>
          appState.navigate(AppScreen.reading, id: product.id.toString()),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Media Thumbnail (Left)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: hasImage
                    ? Image.network(
                        product.imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 100,
                          height: 100,
                          color: theme.disabledColor.withOpacity(0.1),
                          child: Icon(typeIcon, color: accentColor, size: 30),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: theme.disabledColor.withOpacity(0.1),
                        child: Icon(typeIcon, color: accentColor, size: 30),
                      ),
              ),
              const SizedBox(width: 12),

              // 2. Details (Center)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Author
                    Text(
                      product.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'by ${product.author}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Status/Action Row
                    Row(
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        Text(
                          product.rating.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Action Button (Right)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextButton.icon(
                  onPressed: () => appState.navigate(
                    AppScreen.reading,
                    id: product.id.toString(),
                  ),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: const Text('Read'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
