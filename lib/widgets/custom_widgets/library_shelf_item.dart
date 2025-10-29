import 'package:flutter/material.dart';

import '../../models/product.dart';

class LibraryShelfItem extends StatelessWidget {
  final Product product;
  const LibraryShelfItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Icon(Icons.book, size: 70),
          Text(product.title, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
