// lib/screens/product/reading_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import '../../state/app_state.dart';
import '../../models/product.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  String? _localPath;
  bool _isLoading = true;
  bool _hasError = false;

  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _enableSecureMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDocument();
    });
  }

  @override
  void dispose() {
    _disableSecureMode();
    super.dispose();
  }

  Future<void> _enableSecureMode() async {
    try {
      await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    } catch (e) {
      debugPrint("Could not enable secure mode: $e");
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
    } catch (e) {
      debugPrint("Could not disable secure mode: $e");
    }
  }

  Future<void> _loadDocument() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 0;

    // ✅ FIXED: Restored product lookup logic so 'product' is defined
    Product product = appState.products.firstWhere(
          (p) => p.id == productId,
      orElse: () => Product(
        id: 0,
        title: 'Unknown',
        type: '',
        description: '',
        price: 0,
        isFree: false,
        category: '',
        tags: [],
        rating: 0,
        author: '',
        pages: 0,
        reviewCount: 0,
        details: '',
        content: '',
        imageUrl: '',
      ),
    );

    // If not found in online list, check offline library
    if (product.id == 0) {
      product = appState.offlineProducts.firstWhere(
            (p) => p.id == productId,
        orElse: () => Product(
          id: 0,
          title: 'Unknown',
          type: '',
          description: '',
          price: 0,
          isFree: false,
          category: '',
          tags: [],
          rating: 0,
          author: '',
          pages: 0,
          reviewCount: 0,
          details: '',
          content: '',
          imageUrl: '',
        ),
      );
    }

    if (product.id == 0) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
      return;
    }

    final path = await appState.getLocalPdfPath(product);

    if (path != null) {
      if (mounted) setState(() { _localPath = path; _isLoading = false; });
    } else {
      // Fetch silently if not found locally
      await appState.prepareBookForReading(product);
      final newPath = await appState.getLocalPdfPath(product);

      if (mounted) {
        if (newPath != null) {
          setState(() { _localPath = newPath; _isLoading = false; });
        } else {
          setState(() { _isLoading = false; _hasError = true; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (This build method remains exactly as you had it)
    final appState = Provider.of<AppState>(context);
    final productId = int.tryParse(appState.selectedProductId ?? '') ?? 0;
    final isDownloading = appState.downloadProgress.containsKey(productId.toString());
    final progress = appState.downloadProgress[productId.toString()] ?? 0.0;

    Product product = appState.products.firstWhere(
          (p) => p.id == productId,
      orElse: () => Product(id: 0, title: 'Reading', type: '', description: '', price: 0, isFree: false, category: '', tags: [], rating: 0, author: '', pages: 0, reviewCount: 0, details: '', content: '', imageUrl: ''),
    );

    if (product.id == 0) {
      product = appState.offlineProducts.firstWhere(
            (p) => p.id == productId,
        orElse: () => Product(id: 0, title: 'Reading', type: '', description: '', price: 0, isFree: false, category: '', tags: [], rating: 0, author: '', pages: 0, reviewCount: 0, details: '', content: '', imageUrl: ''),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: const TextStyle(fontSize: 16)),
            if (_isReady)
              Text("Page ${_currentPage + 1} of $_totalPages", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateBack(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Reader Settings',
            onPressed: () => _showReaderSettings(context, appState),
          ),
        ],
      ),
      body: _buildBody(appState, isDownloading, progress),
    );
  }

  Widget _buildBody(AppState appState, bool isDownloading, double progress) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text("Unable to load document."),
            TextButton(onPressed: _loadDocument, child: const Text("Retry"))
          ],
        ),
      );
    }
    if (isDownloading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: progress > 0 ? progress : null),
            const SizedBox(height: 16),
            Text("Downloading... ${(progress * 100).toStringAsFixed(0)}%"),
          ],
        ),
      );
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_localPath != null) {
      return Stack(
        children: [
          KeyedSubtree(
            key: ValueKey("pdf_${appState.readerPageFlipping}_${appState.readerColorMode}"),
            child: PDFView(
              filePath: _localPath,
              enableSwipe: true,
              swipeHorizontal: appState.readerPageFlipping == 'Horizontal',
              autoSpacing: true,
              pageFling: true,
              nightMode: appState.readerColorMode == 'Night',
              onRender: (pages) {
                setState(() { _totalPages = pages!; _isReady = true; });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                if (!_controller.isCompleted) { _controller.complete(pdfViewController); }
              },
              onPageChanged: (int? page, int? total) {
                setState(() { _currentPage = page!; });
              },
              onError: (e) => debugPrint("PDF Error: $e"),
            ),
          ),
          if (_isReady && _totalPages > 0)
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Text("${_currentPage + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          activeTrackColor: Colors.white, inactiveTrackColor: Colors.white24, thumbColor: Colors.amber,
                        ),
                        child: Slider(
                          value: _currentPage.toDouble(),
                          min: 0,
                          max: (_totalPages - 1).toDouble(),
                          divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                          onChanged: (double value) { setState(() { _currentPage = value.toInt(); }); },
                          onChangeEnd: (double value) async { final controller = await _controller.future; controller.setPage(value.toInt()); },
                        ),
                      ),
                    ),
                    Text("$_totalPages", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return const Center(child: Text("Document not found"));
  }

  void _showReaderSettings(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reader Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(appState.readerPageFlipping == 'Horizontal' ? Icons.swap_horiz : Icons.swap_vert),
              title: const Text('Scroll Direction'),
              subtitle: Text(appState.readerPageFlipping),
              onTap: () {
                final newVal = appState.readerPageFlipping == 'Horizontal' ? 'Vertical' : 'Horizontal';
                appState.setReaderPageFlipping(newVal);
                Navigator.pop(context);
              },
              trailing: Switch(
                value: appState.readerPageFlipping == 'Horizontal',
                onChanged: (val) {
                  appState.setReaderPageFlipping(val ? 'Horizontal' : 'Vertical');
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(appState.readerColorMode == 'Night' ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Color Mode'),
              subtitle: Text(appState.readerColorMode),
              onTap: () {
                final newVal = appState.readerColorMode == 'Night' ? 'Day' : 'Night';
                appState.setReaderColorMode(newVal);
                Navigator.pop(context);
              },
              trailing: Switch(
                value: appState.readerColorMode == 'Night',
                activeColor: Colors.indigo,
                onChanged: (val) {
                  appState.setReaderColorMode(val ? 'Night' : 'Day');
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}