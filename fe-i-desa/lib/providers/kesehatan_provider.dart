import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/kesehatan.dart';
import '../data/repositories/kesehatan_repository.dart';
import 'idm_score_provider.dart';

final kesehatanRepositoryProvider = Provider<KesehatanRepository>((ref) {
  return KesehatanRepository();
});

class KesehatanState {
  final List<Kesehatan> records;
  final bool isLoading;
  final String? error;

  KesehatanState({this.records = const [], this.isLoading = false, this.error});

  KesehatanState copyWith({List<Kesehatan>? records, bool? isLoading, String? error}) {
    return KesehatanState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final kesehatanProvider = StateNotifierProvider<KesehatanNotifier, KesehatanState>((ref) {
  return KesehatanNotifier(ref.read(kesehatanRepositoryProvider), ref);
});

class KesehatanNotifier extends StateNotifier<KesehatanState> {
  final KesehatanRepository _repository;
  final Ref _ref;

  KesehatanNotifier(this._repository, this._ref) : super(KesehatanState()) {
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

  Future<Map<String, dynamic>> create(Kesehatan data) async {
    final result = await _repository.createKesehatan(data);
    if (result['success'] == true) {
      await loadRecords();
      _ref.invalidate(idmScoreProvider);
    }
    return result;
  }

  Future<Map<String, dynamic>> update(String id, Kesehatan data) async {
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