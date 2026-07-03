import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/idm_score_model.dart';
import '../data/repositories/idm_score_repository.dart';

final idmScoreRepositoryProvider = Provider<IdmScoreRepository>((ref) {
  return IdmScoreRepository();
});

final idmScoreProvider =
    StateNotifierProvider<IdmScoreNotifier, IdmScoreState>((ref) {
  return IdmScoreNotifier(ref.read(idmScoreRepositoryProvider));
});

class IdmScoreState {
  final IdmScoreModel? scores;
  final bool isLoading;
  final String? error;

  const IdmScoreState({this.scores, this.isLoading = false, this.error});

  IdmScoreState copyWith({
    IdmScoreModel? scores,
    bool? isLoading,
    String? error,
  }) {
    return IdmScoreState(
      scores: scores ?? this.scores,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class IdmScoreNotifier extends StateNotifier<IdmScoreState> {
  final IdmScoreRepository _repository;

  IdmScoreNotifier(this._repository) : super(const IdmScoreState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getIdmScores();
      if (result != null) {
        state = state.copyWith(scores: result, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Belum ada data IDM');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat skor IDM');
    }
  }

  Future<void> refresh() => load();
}
