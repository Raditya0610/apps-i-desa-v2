import '../models/sub_dimensions/pengelolaan_lingkungan.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class PengelolaanLingkunganRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createPengelolaanLingkungan(PengelolaanLingkungan data) async {
    try {
      final response = await _apiService.post(
        ApiConstants.subDimensionPengelolaanLingkungan,
        data: data.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data pengelolaan lingkungan berhasil disimpan',
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


  Future<List<PengelolaanLingkungan>> getAll() async {
    try {
      final response = await _apiService.get(ApiConstants.subDimensionPengelolaanLingkungan);
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((json) => PengelolaanLingkungan.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> update(String id, PengelolaanLingkungan data) async {
    try {
      final response = await _apiService.put(ApiConstants.subDimensionPengelolaanLingkunganById(id), data: data.toJson());
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil diperbarui'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal memperbarui data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> delete(String id) async {
    try {
      final response = await _apiService.delete(ApiConstants.subDimensionPengelolaanLingkunganById(id));
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil dihapus'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal menghapus data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}