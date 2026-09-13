import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/pendidikan.dart';
import '../data/repositories/pendidikan_repository.dart';
import 'idm_score_provider.dart';

final pendidikanRepositoryProvider = Provider<PendidikanRepository>((ref) {
  return PendidikanRepository();
});

class PendidikanState {
  final List<Pendidikan> records;
  final bool isLoading;
  final String? error;

  PendidikanState({this.records = const [], this.isLoading = false, this.error});

  PendidikanState copyWith({List<Pendidikan>? records, bool? isLoading, String? error}) {
    return PendidikanState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final pendidikanProvider = StateNotifierProvider<PendidikanNotifier, PendidikanState>((ref) {
  return PendidikanNotifier(ref.read(pendidikanRepositoryProvider), ref);
});

class PendidikanNotifier extends StateNotifier<PendidikanState> {
  final PendidikanRepository _repository;
  final Ref _ref;

  PendidikanNotifier(this._repository, this._ref) : super(PendidikanState()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _repository.getAll();
      state = state.copyWith(records: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>> create(Pendidikan data) async {
    final result = await _repository.createPendidikan(data);
    if (result['success'] == true) {
      await loadRecords();
      _ref.invalidate(idmScoreProvider);
    }
    return result;
  }

  Future<Map<String, dynamic>> update(String id, Pendidikan data) async {
    final result = await _repository.update(id, data);
    if (result['success'] == true) {
      await loadRecords();
      _ref.invalidate(idmScoreProvider);
    }
    return result;
  }

  Future<Map<String, dynamic>> delete(String id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) {
      await loadRecords();
      _ref.invalidate(idmScoreProvider);
    }
    return result;
  }
}