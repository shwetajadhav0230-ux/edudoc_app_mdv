// FIX: Changed 'dart:js_interop' to the standard 'dart:html' conditional import
import 'dart:html' if (dart.library.html) 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
// CRITICAL FIX: The path 'package:provider/providerservices.dart' is wrong.
import 'package:provider/provider.dart';

import '../../data/mock_data.dart'; // Ensure this path is correct
import '../../state/app_state.dart'; // Ensure this path is correct

// --- NETWORK/ASSET PDF VIEWER (Using pdfx for All Platforms) ---
class NetworkPDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const NetworkPDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<NetworkPDFViewerScreen> createState() => _NetworkPDFViewerScreenState();
}

class _NetworkPDFViewerScreenState extends State<NetworkPDFViewerScreen> {
  late PdfControllerPinch _pdfController;
  bool isLoading = true;
  String? errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final documentFuture = _loadPdfDocument();

      _pdfController = PdfControllerPinch(
        document: documentFuture,
        initialPage: 1,
      );

      _controllerInitialized = true;

      final document = await documentFuture;

      if (!mounted) return;

      setState(() {
        _totalPages = document.pagesCount;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Failed to load PDF: ${e.toString()}';
        isLoading = false;
      });
      print('PDF Load Error: $e');
    }
  }

  Future<PdfDocument> _loadPdfDocument() async {
    // FIX: Check for the full expected asset path (assuming mock_data.dart saves 'assets/pdfs/')
    if (widget.pdfUrl.startsWith('assets/pdfs/')) {
      try {
        // We expect rootBundle to load the path exactly as stored in pdfUrl.
        final data = await rootBundle.load(widget.pdfUrl);
        return PdfDocument.openData(data.buffer.asUint8List());
      } catch (e) {
        throw Exception('Failed to load local asset PDF: $e');
      }
    } else {
      // 2. Network loading: If URL is http/https (or external)
      try {
        final bytes = await _fetchPdfBytes(widget.pdfUrl);
        return PdfDocument.openData(bytes);
      } catch (e) {
        throw Exception('Failed to load network PDF: $e');
      }
    }
  }

  Future<Uint8List> _fetchPdfBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  void dispose() {
    // Safely dispose of controller
    if (_controllerInitialized) {
      try {
        _pdfController.dispose();
      } catch (e) {
        print('Error disposing PDF controller: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Open in new tab button for web
          if (kIsWeb)
            Tooltip(
              message: 'Open PDF in new tab',
              child: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  // The conditional import ensures 'html' is only used on web
                  if (widget.pdfUrl.startsWith('assets/pdfs/')) {
                    // Correctly constructs http://localhost:PORT/assets/pdfs/sample1.pdf
                    final assetUrl =
                        '${html.window.location!.origin}/${widget.pdfUrl}';
                    html.window.open(assetUrl, '_blank');
                  } else {
                    html.window.open(widget.pdfUrl, '_blank');
                  }
                },
              ),
            ),
          // Page counter
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isDarkTheme),
    );
  }

  Widget _buildBody(bool isDarkTheme) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: isDarkTheme ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_controllerInitialized) {
      return const Center(
        child: Text('PDF controller not initialized'),
      );
    }

    return PdfViewPinch(
      controller: _pdfController,
      onPageChanged: (page) {
        if (mounted) {
          setState(() {
            _currentPage = page ?? 1;
          });
        }
      },
      onDocumentLoaded: (document) {
        if (mounted) {
          setState(() {
            _totalPages = document.pagesCount;
          });
        }
      },
      onDocumentError: (error) {
        if (mounted) {
          setState(() {
            errorMessage = 'PDF Error: $error';
          });
        }
      },
      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        pageLoaderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}

// --- UNIFIED PDF VIEWER SCREEN ---
class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return NetworkPDFViewerScreen(pdfUrl: pdfUrl, title: title);
  }
}

// --- READING SCREEN (List of PDFs) ---
class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final List<Map<String, String?>> pdfDocuments = dummyProducts
        .where((p) => p.pdfUrl != null)
        .map((p) => {'title': p.title, 'author': p.author, 'pdfUrl': p.pdfUrl})
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: appState.navigateBack,
        ),
        title: const Text(
          'Available PDF Documents',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: pdfDocuments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No PDF documents available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: pdfDocuments.length,
              itemBuilder: (context, index) {
                final doc = pdfDocuments[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.secondary,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      doc['title'] ?? 'Untitled Document',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'By: ${doc['author'] ?? 'Unknown'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    onTap: () {
                      if (doc['pdfUrl'] != null && doc['pdfUrl']!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PDFViewerScreen(
                              pdfUrl: doc['pdfUrl']!,
                              title: doc['title'] ?? 'PDF Document',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF link is missing.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
