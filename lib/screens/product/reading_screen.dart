// Auto-generated screen from main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/mock_data.dart';
import '../../state/app_state.dart';


class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 1;
    final product = dummyProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => dummyProducts.first,
    );

    // This simulates the E-Reader by showing the content property
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: appState.navigateBack,
        ),
        title: Text(product.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Removed unnecessary backslash stripping from the Raw String content
            Text(
              product.content.replaceAll('## ', '\n\nCHAPTER: '),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 50),
            if (product.pdfUrl != null)
              Center(
                child: Text(
                  'PDF Viewer Placeholder. Link: ${product.pdfUrl}',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
