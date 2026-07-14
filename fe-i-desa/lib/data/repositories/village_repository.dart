import '../models/village.dart';
import '../services/api_service.dart';
import '../services/mock_api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class VillageRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  /// Villages for the registration dropdown.
  ///
  /// Read from the backend rather than hardcoded: villages are inserted into the
  /// database by hand, and a hardcoded list meant adding one required a frontend
  /// rebuild. Throws so the register screen can distinguish "offline" from
  /// "no villages exist yet".
  Future<List<Village>> getAllVillages() async {
    final response = await _api.get(ApiConstants.villages);

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final villages = data['villages'] as List? ?? [];
      return villages
          .map((json) => Village.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat daftar desa');
  }

  Future<Map<String, dynamic>> createVillage(String name) async {
    try {
      final response = await _api.post(
        ApiConstants.villages,
        data: {'name': name},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': true,
          'message': data['message'] ?? 'Desa berhasil ditambahkan',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menambahkan desa'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }
}
