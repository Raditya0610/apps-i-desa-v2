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

  /// Villages hidden from the registration dropdown but kept in the database
  /// (they may still own accounts/data). Matched by id so a name edit can't
  /// accidentally unhide them. Remove an id here to show that village again.
  static const Set<String> _hiddenVillageIds = {
    '83eb95cc-e9ac-425f-8cef-2c3db0e0c24a', // Ohoi Iso
    'ce964e83-4a13-45eb-a2e5-9b903b0c9033', // Ohoi Wain Baru
    '9caa4ba3-3d4a-4fad-a5a0-6ca8ebc41ef7', // Ohoi Disuk
  };

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
          .where((v) => !_hiddenVillageIds.contains(v.id))
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
