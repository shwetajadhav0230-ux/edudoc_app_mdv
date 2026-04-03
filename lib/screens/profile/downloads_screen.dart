// lib/screens/profile/downloads_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../product/reading_screen.dart'; // ✅ Import Reading Screen directly
import '../../widgets/custom_widgets/audio_player_sheet.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh list on enter
    Provider.of<AppState>(context, listen: false).loadOfflineLibrary();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final offlineBooks = appState.offlineProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Offline Library"),
      ),
      body: offlineBooks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    "No downloads yet.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Browse Books"),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: offlineBooks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = offlineBooks[index];

                return Dismissible(
                  key: Key(product.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    appState.removeFromOfflineLibrary(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.title} removed")),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      // ✅ 1. MAKE WHOLE TILE CLICKABLE
                      onTap: () {
                        // 1. Set the ID using the new method
                        appState.setSelectedProduct(product.id.toString());

                        // 2. Push the Reading Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingScreen(),
                          ),
                        );
                      },
                      leading: Container(
                        width: 50,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                          image: (product.imageUrl.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (_, __) {},
                                )
                              : null,
                        ),
                        child: product.imageUrl.isEmpty
                            ? const Icon(Icons.book, color: Colors.grey)
                            : null,
                      ),
                      title: Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(product.author),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.audioUrl != null &&
                              product.audioUrl!.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.headphones,
                                  color: Colors.blue),
                              onPressed: () async {
                                final localPath = await appState
                                    .getOfflineAudioPath(product.id.toString());
                                if (context.mounted) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => AudioPlayerSheet(
                                      title: product.title,
                                      author: product.author,
                                      coverImageUrl: product.imageUrl,
                                      audioUrl: product.audioUrl,
                                      localAudioPath: localPath,
                                    ),
                                  );
                                }
                              },
                            ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
