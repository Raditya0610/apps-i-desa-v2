import 'package:dio/dio.dart';
import '../models/import_result.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/file_saver/file_saver.dart';
import '../../core/constants/api_constants.dart';

class ImportRepository {
  final ApiService _apiService = ApiService();

  /// Downloads the import template workbook and saves it to disk (native) or
  /// triggers a browser download (web). Returns a success/message map rather
  /// than the raw bytes — matching the create/delete repository pattern — so
  /// the screen can show an Indonesian error straight from the response.
  Future<Map<String, dynamic>> downloadTemplate() async {
    try {
      final response = await _apiService.get(
        ApiConstants.importTemplate,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;
        final path = await saveBytesFile(bytes, 'template_import_data_penduduk.xlsx');
        if (path != null) {
          return {'success': true, 'message': 'Template berhasil diunduh', 'path': path};
        }
        return {'success': false, 'message': 'Gagal menyimpan file template'};
      }
      return {'success': false, 'message': 'Gagal mengunduh template'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  /// How long an import/preview request may take. A few hundred residents
  /// means one transaction per family on the server, which can easily exceed
  /// the app-wide 30 s default on a slow village connection.
  static const Duration importTimeout = Duration(minutes: 3);

  /// Uploads a filled-in workbook and returns the row-by-row report of what
  /// was actually committed. A 200 response is returned even when some rows
  /// failed or were skipped — that is the normal shape of a mixed
  /// bulk-import outcome, not an HTTP error.
  ///
  /// On failure the map carries `uncertain: true` when the request may have
  /// reached the server before the connection dropped (timeout, lost
  /// connection, 5xx). The server keeps processing even after the client is
  /// gone, so some or all rows may already be saved — the UI must say so
  /// instead of claiming the import failed.
  Future<Map<String, dynamic>> uploadImportFile(
    List<int> bytes,
    String filename, {
    ProgressCallback? onSendProgress,
  }) {
    return _postWorkbook(ApiConstants.importUpload, bytes, filename,
        onSendProgress: onSendProgress);
  }

  /// Same file, same validation, but nothing is written to the database —
  /// the review step shown before the operator commits an import. Returns
  /// the same report shape as [uploadImportFile], describing what *would*
  /// happen.
  Future<Map<String, dynamic>> previewImportFile(
    List<int> bytes,
    String filename, {
    ProgressCallback? onSendProgress,
  }) {
    return _postWorkbook(ApiConstants.importPreview, bytes, filename,
        onSendProgress: onSendProgress);
  }

  Future<Map<String, dynamic>> _postWorkbook(
    String path,
    List<int> bytes,
    String filename, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _apiService.post(
        path,
        data: formData,
        options: Options(
          sendTimeout: importTimeout,
          receiveTimeout: importTimeout,
        ),
        onSendProgress: onSendProgress,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': ImportSummaryResponse.fromJson(response.data as Map<String, dynamic>),
        };
      }

      final data = response.data as Map<String, dynamic>;
      return {
        'success': false,
        'message': ApiService.getResponseError(data, fallback: 'Gagal memproses file'),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
        // Same classification the offline cache/queue uses: connection lost,
        // timed out, or server 5xx — i.e. we can't know what was written.
        'uncertain': CacheService.isOffline(e),
      };
    }
  }
}
