import '../models/sub_dimensions/kemudahan_akses.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class KemudahanAksesRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createKemudahanAkses(KemudahanAkses data) async {
    try {
      final response = await _apiService.post(
        ApiConstants.subDimensionKemudahanAkses,
        data: data.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Data kemudahan akses berhasil disimpan',
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


  Future<List<KemudahanAkses>> getAll() async {
    try {
      final response = await _apiService.get(ApiConstants.subDimensionKemudahanAkses);
      if (response.statusCode == 200) {
        final list = response.data as List;
        return list.map((json) => KemudahanAkses.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> update(String id, KemudahanAkses data) async {
    try {
      final response = await _apiService.put(ApiConstants.subDimensionKemudahanAksesById(id), data: data.toJson());
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil diperbarui'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal memperbarui data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }

  Future<Map<String, dynamic>> delete(String id) async {
    try {
      final response = await _apiService.delete(ApiConstants.subDimensionKemudahanAksesById(id));
      if (response.statusCode == 200) return {'success': true, 'message': 'Data berhasil dihapus'};
      final d = response.data as Map<String, dynamic>;
      return {'success': false, 'message': d['message'] ?? 'Gagal menghapus data'};
    } catch (e) {
      return {'success': false, 'message': ApiService.getErrorMessage(e)};
    }
  }
}