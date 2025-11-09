// reading_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart'
    show dummyProducts; // Retained for ReadingScreen list
import '../../state/app_state.dart'; // Retained for AppState usage

// --- Helper Dialogs and Widgets ---

// 1. Settings Dialog (Retained for structure)
class ReaderSettingsDialog extends StatefulWidget {
  final AppState appState;

  const ReaderSettingsDialog({super.key, required this.appState});

  @override
  State<ReaderSettingsDialog> createState() => _ReaderSettingsDialogState();
}

class _ReaderSettingsDialogState extends State<ReaderSettingsDialog> {
  // CRITICAL: Initialized fields to avoid LateInitializationError
  late String _pageFlipping;
  late String _colorMode;
  late double _fontSize;
  late double _lineSpacing;

  // Local toggles and non-AppState managed fields (placeholders)
  String _fontFace = 'Embedded + Merriwe...';
  double _fontThickness = 50;
  bool _twoPagesLandscape = true;
  bool _pageMargins = false;

  @override
  void initState() {
    super.initState();
    // Safely initialize the fields from AppState inside initState()
    final state = Provider.of<AppState>(context,
        listen: false); // Use Provider to access state in initState safely
    _pageFlipping = state.readerPageFlipping;
    _colorMode = state.readerColorMode;
    _fontSize = state.readerFontSize;
    _lineSpacing = state.readerLineSpacing;
  }

  // --- Helper Methods (buildSettingRow, buildSliderSetting, buildToggleSetting) ---
  Widget _buildSettingRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          control,
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    double step = 1.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                label: value.round().toString(),
                onChanged: onChanged,
                divisions: ((max - min) / step).round(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () {
                if (value > min) onChanged(value - step);
              },
            ),
            Text(value.round().toString()),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                if (value < max) onChanged(value + step);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleSetting(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: The AlertDialog handles the single scrollable form.
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      title: const Text('SETTINGS EPUB, FB2, MOBI, DOC, DOCX, RTF, TXT & CHM',
          style: TextStyle(fontSize: 14)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PAGE FLIPPING (Allows Vertical/Horizontal flip, Updates AppState) ---
            _buildSettingRow(
              'PAGE FLIPPING',
              DropdownButton<String>(
                value: _pageFlipping,
                dropdownColor: Theme.of(context).cardColor,
                items: ['Horizontal', 'Vertical'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _pageFlipping = newValue;
                    });
                    // Functionality: Updates AppState for page flipping
                    widget.appState.setReaderPageFlipping(newValue);
                  }
                },
              ),
            ),

            // --- COLOR MODE (Allows Day/Night/Sepia, Updates AppState) ---
            _buildSettingRow(
              'COLOR MODE',
              DropdownButton<String>(
                value: _colorMode,
                dropdownColor: Theme.of(context).cardColor,
                items: ['Day', 'Night', 'Sepia'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _colorMode = newValue;
                    });
                    // Functionality: Updates AppState for color mode
                    widget.appState.setReaderColorMode(newValue);
                  }
                },
              ),
            ),

            // --- FONT FACE (Allows Font Name Change) ---
            _buildSettingRow(
              'FONT FACE',
              DropdownButton<String>(
                value: _fontFace,
                dropdownColor: Theme.of(context).cardColor,
                items: ['Embedded + Merriwe...', 'Roboto', 'Times New Roman']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _fontFace = newValue;
                    });
                    // Add widget.appState.setReaderFontName(newValue); if state existed
                  }
                },
              ),
            ),

            // --- FONT SIZE (Allows size change, Updates AppState) ---
            _buildSliderSetting(
              'FONT SIZE',
              _fontSize,
              10,
              80,
              (newValue) {
                setState(() => _fontSize = newValue);
                // Functionality: Updates AppState for font size
                widget.appState.setReaderFontSize(newValue);
              },
              step: 1,
            ),

            // --- FONT THICKNESS (Allows thickness change) ---
            _buildSliderSetting(
              'FONT THICKNESS',
              _fontThickness,
              0,
              100,
              (newValue) {
                setState(() => _fontThickness = newValue);
                // Add widget.appState.setReaderFontThickness(newValue); if state existed
              },
              step: 1,
            ),

            // --- LINE SPACING (Allows spacing change, Updates AppState) ---
            _buildSliderSetting(
              'LINE SPACING',
              _lineSpacing,
              50,
              200,
              (newValue) {
                setState(() => _lineSpacing = newValue);
                // Functionality: Updates AppState for line spacing
                widget.appState.setReaderLineSpacing(newValue);
              },
              step: 10,
            ),

            _buildSettingRow(
                'TEXT ALIGN', const Text('Original + Hyphenation')),

            // --- TOGGLES ---
            _buildToggleSetting(
              'Two pages in landscape orientation',
              _twoPagesLandscape,
              (newValue) => setState(() => _twoPagesLandscape = newValue),
            ),
            _buildToggleSetting(
              'Page margins',
              _pageMargins,
              (newValue) => setState(() => _pageMargins = newValue),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text('GENERAL SETTINGS',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
      actionsAlignment: MainAxisAlignment.center,
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
    );
  }
}

// 2. Overflow Menu (Removed)
class OverflowMenu extends StatelessWidget {
  final VoidCallback onGoToPremium;
  const OverflowMenu({super.key, required this.onGoToPremium});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// 3. Contents Dialog (Retained with mock data structure)
class ContentsDialog extends StatelessWidget {
  final String title;
  final int totalPages;
  const ContentsDialog(
      {super.key, required this.title, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    // Retained mock contents since the dynamic outline logic was removed
    final contents = [
      {'title': 'Contents', 'page': 5},
      {'title': 'Chapter 1', 'page': 7},
      {'title': 'Chapter 2', 'page': 18},
      {'title': 'Chapter 3', 'page': 26},
      {'title': 'Dear Dr. Love', 'page': 30},
      {'title': 'Chapter 4', 'page': 32},
      {'title': 'Chapter 5', 'page': 46},
      {'title': 'Dear Dr. Love', 'page': 56},
      {'title': 'Chapter 6', 'page': 57},
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: TabBar(
              tabs: [
                Tab(text: 'CONTENTS'),
                Tab(text: 'BOOKMARKS'),
                Tab(text: 'QUOTES'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // CONTENTS Tab (Using mock data)
            ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final item = contents[index];
                return ListTile(
                  title: Text(item['title'] as String),
                  trailing: Text(item['page'].toString()),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Jumping to page ${item['page']}...')),
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
            // BOOKMARKS Tab
            const Center(child: Text('No bookmarks yet.')),
            // QUOTES Tab
            const Center(child: Text('No quotes saved.')),
          ],
        ),
      ),
    );
  }
}

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

  // Method to safely dispose controller
  void _disposeController() {
    if (_controllerInitialized) {
      try {
        _pdfController.dispose();
      } catch (e) {
        // print('Error disposing PDF controller: $e'); // Removed print
      }
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
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
      // print('PDF Load Error: $e'); // Removed print
    }
  }

  Future<PdfDocument> _loadPdfDocument() async {
    // Check for the expected asset path (assuming mock_data.dart saves 'assets/pdfs/...')
    if (widget.pdfUrl.startsWith('assets/pdfs/')) {
      try {
        final data = await rootBundle.load(widget.pdfUrl);
        return PdfDocument.openData(data.buffer.asUint8List());
      } catch (e) {
        throw Exception('Failed to load local asset PDF: $e');
      }
    } else {
      // Network loading: If URL is http/https (or external)
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

  // --- Core Functions ---

  // Replaced original _showContents with simple version
  void _showContents() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: DefaultTabController(
            length: 3, // Contents, Bookmarks, Quotes
            initialIndex: 0,
            child: ContentsDialog(
              title: widget.title,
              totalPages: _totalPages,
            ),
          ),
        );
      },
    );
  }

  void _jumpToPage(int page) {
    if (_pdfController != null && page >= 1 && page <= _totalPages) {
      _pdfController.jumpToPage(page);
      setState(() {
        _currentPage = page;
      });
    }
  }

  // Custom back handler
  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // SIMPLIFIED UI COLORS
    const Color toolbarColor = Colors.white;
    const Color iconColor = Colors.black;

    return Scaffold(
      // --- SIMPLIFIED APPBAR ---
      appBar: AppBar(
        // We handle back navigation manually to ensure the icon is correct
        automaticallyImplyLeading: false,
        backgroundColor: toolbarColor,
        elevation: 1,

        // CRITICAL FIX: Replace three lines icon with back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: iconColor),
          onPressed: _goBack, // Navigate back to the list screen
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: iconColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Emma St. Clair', // Placeholder for author/subtitle
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Chapter 1 :: page $_currentPage/$_totalPages', // Dynamic page info
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        // REMOVE ALL ACTIONS (Bookmark, New Release, Audio, Search, Settings, Overflow)
        actions: const [],
      ),

      // Add Bottom page count and slider
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: toolbarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: _currentPage.toDouble(),
              min: 1,
              max: _totalPages.toDouble().clamp(1, double.infinity),
              divisions: _totalPages.clamp(1, 100),
              onChanged: (double newValue) {
                setState(() {
                  _currentPage = newValue.round();
                });
              },
              onChangeEnd: (double newValue) {
                _jumpToPage(newValue.round());
              },
              label: _currentPage.toString(),
            ),
            Text(
              '${_currentPage} of $_totalPages',
              style: const TextStyle(fontSize: 14, color: iconColor),
            ),
          ],
        ),
      ),

      // Call the correctly defined _buildBody method
      body: _buildBody(isDarkTheme),
    );
  }

  // DEFINITION: The _buildBody method handles the PDF viewer content and loading states
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

    // Get document data safely
    final List<Map<String, String?>> pdfDocuments = dummyProducts
        .where((p) => p.pdfUrl != null)
        .map((p) => {
              'title': p.title,
              'author': p.author,
              'pdfUrl': p.pdfUrl,
              'id': p.id.toString()
            }) // Added id as String for safety
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
