import 'dart:io';

import 'package:flutter/material.dart';
// Note: These libraries must be added to your pubspec.yaml for this code to compile.
// packages required: flutter_pdfview, http, path_provider
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';

// ----------------------------------------------------------------------
// PDF VIEWER SCREEN (Handles downloading and rendering the PDF)
// ----------------------------------------------------------------------

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  // PDFView controller properties
  int _pages = 0;
  int _currentPage = 0;
  // ignore: unused_field
  PDFViewController? _pdfViewController;

  // --- Helper to download the PDF and save it locally ---
  Future<void> _downloadAndLoadPdf() async {
    try {
      final directory = await getTemporaryDirectory();
      final cleanedTitle = widget.title.replaceAll(RegExp(r'[^\w]'), '_');
      // Use a stable file name instead of one with a timestamp
      final localFilePath = '${directory.path}/$cleanedTitle.pdf';
      final file = File(localFilePath);

      // --- ADD THIS CHECK ---
      if (await file.exists()) {
        setState(() {
          localPath = localFilePath;
          isLoading = false;
        });
        return; // File already exists, no need to download
      }
      // --- END CHECK ---

      // If file doesn't exist, proceed with download
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        // ... (handle error) ...
      }
    } catch (e) {
      // ... (handle error) ...
    }
  }

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
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
        actions: _pages > 0
            ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      '${_currentPage + 1} / $_pages',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ]
            : null,
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
              'Downloading and loading PDF from network...',
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
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (localPath == null) {
      return const Center(
        child: Text('File path is null.', style: TextStyle(color: Colors.red)),
      );
    }

    // --- PDF Rendering Widget ---
    return PDFView(
      filePath: localPath,
      enableSwipe: true,
      swipeHorizontal:true,
      autoSpacing: true,
      pageFling: false,
      preventLinkNavigation:
          false, // <-- Allows hyperlinks within PDFs to open in a browser
      onRender: (pages) {
        setState(() {
          _pages = pages ?? 0;
        });
      },
      onViewCreated: (controller) {
        _pdfViewController = controller;
      },
      onPageChanged: (page, total) {
        setState(() {
          _currentPage = page ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = 'Error displaying PDF: $error';
        });
        print('PDFView Error: $error');
      },
      onPageError: (page, error) {
        setState(() {
          errorMessage = 'Error on page $page: $error';
        });
        print('PDFView Page Error: $page - $error');
      },
    );
  }
}

// ----------------------------------------------------------------------
// READING SCREEN (Now acts as the PDF List Screen)
// ----------------------------------------------------------------------

class ReadingScreen extends StatelessWidget {
  const ReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Filter dummyProducts to only show products with a valid PDF link
    // This retrieves the data from the imported mock_data.dart file.
    final List<Map<String, String?>> pdfDocuments = dummyProducts
        .where((p) => p.pdfUrl != null)
        .map((p) => {'title': p.title, 'author': p.author, 'pdfUrl': p.pdfUrl})
        .toList();

    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);

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
          ? const Center(
              child: Text(
                'No PDF documents with valid URLs are available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
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
                    leading: Icon(
                      Icons.picture_as_pdf,
                      color: theme.colorScheme.secondary,
                      size: 30,
                    ),
                    title: Text(
                      doc['title'] ?? 'Untitled Document',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('By: ${doc['author'] ?? 'Unknown'}'),
                    trailing: const Icon(
                      Icons.open_in_new,
                      size: 24,
                      color: Colors.blueGrey,
                    ),
                    onTap: () {
                      if (doc['pdfUrl'] != null) {
                        // Navigate to the PDF viewer screen
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
                          const SnackBar(content: Text('PDF link is missing.')),
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
