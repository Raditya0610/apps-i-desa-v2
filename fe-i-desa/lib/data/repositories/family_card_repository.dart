import '../models/cached_result.dart';
import '../models/family_card.dart';
import '../models/family_card_detail.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/mock_api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/config/app_config.dart';

class FamilyCardRepository {
  final ApiService _apiService = ApiService();
  final MockApiService _mockApiService = MockApiService();
  final CacheService _cache = CacheService();

  // Get the appropriate API service based on config
  dynamic get _api => AppConfig.useMockApi ? _mockApiService : _apiService;

  Future<CachedResult<List<FamilyCard>>> getAllFamilyCards() async {
    try {
      final response = await _api.get(ApiConstants.familyCards);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final familyCards = data['family_cards'] as List;
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.familyCards, familyCards);
        }
        return CachedResult.fresh(_parseFamilyCards(familyCards));
      }
      return const CachedResult.fresh([]);
    } catch (e) {
      print('Error fetching family cards: ${ApiService.getErrorMessage(e)}');

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.familyCards);
        if (cached != null) {
          print('Serving family cards from cache (${cached.cachedAt})');
          return CachedResult.fromCache(
            _parseFamilyCards(cached.data as List),
            cached.cachedAt,
          );
        }
      }

      return const CachedResult.fresh([]);
    }
  }

  List<FamilyCard> _parseFamilyCards(List json) => json
      .map((e) => FamilyCard.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<FamilyCard?> getFamilyCardById(String nik) async {
    try {
      final response = await _api.get(
        ApiConstants.familyCardById(nik),
      );

      if (response.statusCode == 200) {
        return FamilyCard.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching family card: ${ApiService.getErrorMessage(e)}');
      return null;
    }
  }

  Future<CachedResult<FamilyCardDetail?>> getFamilyCardDetail(String nik) async {
    try {
      final response = await _api.get(
        ApiConstants.familyCardById(nik),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (!AppConfig.useMockApi) {
          await _cache.write(CacheKeys.familyCardDetail(nik), json);
        }
        return CachedResult.fresh(FamilyCardDetail.fromJson(json));
      }
      return const CachedResult.fresh(null);
    } catch (e) {
      print('Error fetching family card detail: ${ApiService.getErrorMessage(e)}');

      if (CacheService.isOffline(e)) {
        final cached = await _cache.read(CacheKeys.familyCardDetail(nik));
        if (cached != null) {
          print('Serving family card $nik from cache (${cached.cachedAt})');
          return CachedResult.fromCache(
            FamilyCardDetail.fromJson(cached.data as Map<String, dynamic>),
            cached.cachedAt,
          );
        }
      }

      return const CachedResult.fresh(null);
    }
  }

  Future<Map<String, dynamic>> deleteFamilyCard(String nik) async {
    try {
      final response = await _api.delete(ApiConstants.familyCardById(nik));
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil dihapus',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menghapus kartu keluarga'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> updateFamilyCard(
    String nik,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _api.put(
        ApiConstants.familyCardById(nik),
        data: data,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil diperbarui',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal memperbarui kartu keluarga'),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': ApiService.getErrorMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> createFamilyCard(FamilyCard familyCard) async {
    try {
      final response = await _api.post(
        ApiConstants.familyCards,
        data: familyCard.toCreateJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Kartu keluarga berhasil ditambahkan',
        };
      } else {
        final data = response.data as Map<String, dynamic>;
        return {
          'success': false,
          'message': ApiService.getResponseError(data, fallback: 'Gagal menambahkan kartu keluarga'),
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
