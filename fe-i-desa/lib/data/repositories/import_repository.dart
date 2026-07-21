import 'package:dio/dio.dart';
import '../models/import_result.dart';
import '../services/api_service.dart';
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

  /// Uploads a filled-in workbook and returns the row-by-row report. A 200
  /// response is returned even when some rows failed or were skipped — that
  /// is the normal shape of a mixed bulk-import outcome, not an HTTP error.
  Future<Map<String, dynamic>> uploadImportFile(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _apiService.post(
        ApiConstants.importUpload,
        data: formData,
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
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}
