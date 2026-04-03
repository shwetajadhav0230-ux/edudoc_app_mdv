// lib/services/file_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class FileService {
  final Dio _dio = Dio();
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationService _notificationService = NotificationService();

  // --- 1. DOWNLOAD LOGIC ---

  Future<String> _getSecurePath(String fileName) async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/$fileName';
  }

  Future<bool> fileExists(String fileName) async {
    final path = await _getSecurePath(fileName);
    return File(path).existsSync();
  }

  Future<String?> getLocalFilePath(String fileName) async {
    final path = await _getSecurePath(fileName);
    if (File(path).existsSync()) {
      return path;
    }
    return null;
  }

  // ✅ FIXED: Added showNotification parameter (defaulting to true)
  Future<String?> downloadAndSaveDocument({
    required String url,
    required String fileName,
    required String title,
    required Function(double) onProgress,
    bool showNotification = true,
  }) async {
    try {
      if (url.isEmpty || !url.startsWith('http')) {
        debugPrint("❌ Invalid URL: $url");
        return null;
      }

      final savePath = await _getSecurePath(fileName);
      int lastProgress = 0;
      final int notificationId = DateTime.now().millisecond;

      // 1. Start Notification (Only if enabled)
      if (showNotification) {
        await _notificationService.showProgressNotification(
          id: notificationId,
          progress: 0,
          title: "Downloading $title",
          body: "Starting...",
        );
      }

      // 2. Start Download
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            int percentage = (progress * 100).toInt();

            onProgress(progress);

            // Update Notification (Throttled)
            if (showNotification && percentage > lastProgress + 5) {
              _notificationService.showProgressNotification(
                id: notificationId,
                progress: percentage,
                title: "Downloading $title",
                body: "$percentage%",
              );
              lastProgress = percentage;
            }
          }
        },
      );

      // 3. Success Notification
      if (showNotification) {
        await _notificationService.showCompletionNotification(
          id: notificationId,
          title: title,
          body: "Download finished successfully",
          isSuccess: true,
        );
      }

      return savePath;

    } catch (e) {
      debugPrint("❌ Download Error: $e");

      // 4. Error Notification
      if (showNotification) {
        await _notificationService.showCompletionNotification(
          id: 999,
          title: title,
          body: "Check your internet connection.",
          isSuccess: false,
        );
      }
      return null;
    }
  }

  Future<void> deleteDownloadedFile(String fileName) async {
    final path = await _getSecurePath(fileName);
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  // --- 2. UPLOAD LOGIC ---
  Future<String?> uploadOfferImage(File imageFile, String offerTitle) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final sanitizedTitle = offerTitle.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'covers/${sanitizedTitle}_$timestamp.$fileExt';

      await _supabase.storage.from('offer_images').upload(
        filePath,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      return _supabase.storage.from('offer_images').getPublicUrl(filePath);
    } catch (e) {
      debugPrint("Upload Error: $e");
      return null;
    }
  }
}