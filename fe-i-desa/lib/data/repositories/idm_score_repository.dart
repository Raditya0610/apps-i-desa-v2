import '../models/idm_score_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class IdmScoreRepository {
  final ApiService _api = ApiService();

  Future<IdmScoreModel?> getIdmScores() async {
    try {
      final response = await _api.get(ApiConstants.idmScores);
      if (response.statusCode == 200) {
        return IdmScoreModel.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
