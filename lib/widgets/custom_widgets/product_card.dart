import 'package:flutter/material.dart'; // <-- CORRECT
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../state/app_state.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<AppState>(context, listen: false);

    // Get the correct icon based on the product type
    IconData typeIcon = Icons.article; // Default
    if (product.type == 'Books') {
      typeIcon = Icons.book_outlined;
    } else if (product.type == 'Journals') {
      typeIcon = Icons.edit_note;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            onTap ??
            () => appState.navigate(
              AppScreen.productDetails,
              id: product.id.toString(),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Section ---
            Stack(
              children: [
                _buildImage(theme),
                _buildTypeChip(theme, typeIcon),
                _buildBookmarkIcon(),
              ],
            ),
            // --- Content Section ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(theme),
                  const SizedBox(height: 4),
                  _buildAuthor(theme),
                  const SizedBox(height: 5),
                  _buildRating(theme),
                  const Divider(height: 20),
                  _buildPrice(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Builder Methods ---

  Widget _buildImage(ThemeData theme) {
    return Image.network(
      product.imageUrl,
      height: 100, // As seen in your design
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        return progress == null
            ? child
            : Container(
                height: 50,
                color: theme.cardColor,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 130,
          color: theme.disabledColor.withOpacity(0.1),
          child: Icon(
            Icons.broken_image_outlined,
            color: theme.disabledColor,
            size: 40,
          ),
        );
      },
    );
  }

  Widget _buildTypeChip(ThemeData theme, IconData typeIcon) {
    return Positioned(
      top: 10,
      left: 10,
      child: Chip(
        avatar: Icon(
          typeIcon,
          size: 16,
          color: theme.colorScheme.onSecondaryContainer,
        ),
        label: Text(product.type),
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildBookmarkIcon() {
    // We use a Consumer here so ONLY this icon rebuilds when bookmarks change,
    // not the whole card.
    return Positioned(
      top: 8,
      right: 8,
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final isBookmarked = appState.bookmarkedProductIds.contains(
            product.id,
          );
          return Card(
            elevation: 0,
            color: Colors.black.withOpacity(0.3),
            shape: const CircleBorder(),
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
              ),
              iconSize: 22,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                appState.toggleBookmark(product.id);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      product.title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthor(ThemeData theme) {
    return Text(
      'by ${product.author}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.star_rounded, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          product.rating.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // --- FIX IS HERE ---
        Flexible(
          // Added Flexible widget
          child: Text(
            ' (${product.reviewCount} reviews)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            maxLines: 1, // Ensure it stays on one line
            overflow: TextOverflow.ellipsis, // Add '...' if it's too long
          ),
        ),
        // --- END FIX ---
      ],
    );
  }

  Widget _buildPrice(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Price',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        // --- FIX IS HERE ---
        Expanded(
          // Changed to Expanded for better alignment
          child: Text(
            product.isFree ? 'FREE' : '${product.price} Tokens',
            style: theme.textTheme.titleMedium?.copyWith(
              color: product.isFree
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end, // Aligns text to the right
            maxLines: 1, // Ensure it stays on one line
            overflow: TextOverflow.ellipsis, // Add '...' if it's too long
          ),
        ),
        // --- END FIX ---
      ],
    );
  }
}
