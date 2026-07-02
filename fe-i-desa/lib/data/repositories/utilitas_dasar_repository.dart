import '../models/sub_dimensions/utilitas_dasar.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class UtilitasDasarRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createUtilitasDasar(UtilitasDasar data) async {
    try {
      final response = await _apiService.post(
        ApiConstants.subDimensionUtilitasDasar,
        data: data.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data utilitas dasar berhasil disimpan',
        };
      } else {
        final responseData = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal menyimpan data',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }


  Future<List<UtilitasDasar>> getAll() async {
    try {
      final response = await _apiService.get(ApiConstants.subDimensionUtilitasDasar);
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((json) => UtilitasDasar.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> update(String id, UtilitasDasar data) async {
    try {
      final response = await _apiService.put(ApiConstants.subDimensionUtilitasDasarById(id), data: data.toJson());
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil diperbarui'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal memperbarui data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> delete(String id) async {
    try {
      final response = await _apiService.delete(ApiConstants.subDimensionUtilitasDasarById(id));
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil dihapus'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal menghapus data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}