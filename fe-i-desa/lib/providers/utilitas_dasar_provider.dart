import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/utilitas_dasar.dart';
import '../data/repositories/utilitas_dasar_repository.dart';

final utilitasDasarRepositoryProvider = Provider<UtilitasDasarRepository>((ref) {
  return UtilitasDasarRepository();
});

class UtilitasDasarState {
  final List<UtilitasDasar> records;
  final bool isLoading;
  final String? error;

  UtilitasDasarState({this.records = const [], this.isLoading = false, this.error});

  UtilitasDasarState copyWith({List<UtilitasDasar>? records, bool? isLoading, String? error}) {
    return UtilitasDasarState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final utilitasDasarProvider = StateNotifierProvider<UtilitasDasarNotifier, UtilitasDasarState>((ref) {
  return UtilitasDasarNotifier(ref.read(utilitasDasarRepositoryProvider));
});

class UtilitasDasarNotifier extends StateNotifier<UtilitasDasarState> {
  final UtilitasDasarRepository _repository;

  UtilitasDasarNotifier(this._repository) : super(UtilitasDasarState()) {
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

  Future<Map<String, dynamic>> create(UtilitasDasar data) async {
    final result = await _repository.createUtilitasDasar(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, UtilitasDasar data) async {
    final result = await _repository.update(id, data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> delete(String id) async {
    final result = await _repository.delete(id);
    if (result['success'] == true) await loadRecords();
    return result;
  }
}