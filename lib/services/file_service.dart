  // lib/services/file_service.dart

  import 'dart:io';
  import 'package:path_provider/path_provider.dart';
  import 'package:dio/dio.dart';
  import 'package:flutter/foundation.dart';

  class FileService {
    final Dio _dio = Dio();

    // 1. Get the secure internal path for a document
    Future<String> _getSecurePath(String fileName) async {
      final directory = await getApplicationSupportDirectory();
      return '${directory.path}/$fileName';
    }

    // 2. Check if a file already exists locally
    Future<bool> fileExists(String fileName) async {
      final path = await _getSecurePath(fileName);
      return File(path).existsSync();
    }

    // 3. Get the File object (only if exists)
    Future<String?> getLocalFilePath(String fileName) async {
      final path = await _getSecurePath(fileName);
      if (File(path).existsSync()) {
        return path;
      }
      return null;
    }

    // 4. Download and save document (Network Only)
    Future<String?> downloadAndSaveDocument({
      required String url,
      required String fileName,
      required Function(double) onProgress,
    }) async {
      try {
        // ✅ STRICT CHECK: Only allow http/https downloads
        if (!url.startsWith('http')) {
          debugPrint("Invalid URL for download: $url");
          return null;
        }

        final savePath = await _getSecurePath(fileName);

        await _dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = received / total;
              onProgress(progress);
            }
          },
        );

        return savePath;
      } catch (e) {
        debugPrint("Download Error: $e");
        return null;
      }
    }

    // Delete local file
    Future<void> deleteDownloadedFile(String fileName) async {
      final path = await _getSecurePath(fileName);
      final file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }