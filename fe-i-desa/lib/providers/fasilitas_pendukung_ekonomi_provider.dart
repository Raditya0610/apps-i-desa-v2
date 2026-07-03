import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/fasilitas_pendukung_ekonomi.dart';
import '../data/repositories/fasilitas_pendukung_ekonomi_repository.dart';

final fasilitasPendukungEkonomiRepositoryProvider = Provider<FasilitasPendukungEkonomiRepository>((ref) {
  return FasilitasPendukungEkonomiRepository();
});

class FasilitasPendukungEkonomiState {
  final List<FasilitasPendukungEkonomi> records;
  final bool isLoading;
  final String? error;

  FasilitasPendukungEkonomiState({this.records = const [], this.isLoading = false, this.error});

  FasilitasPendukungEkonomiState copyWith({List<FasilitasPendukungEkonomi>? records, bool? isLoading, String? error}) {
    return FasilitasPendukungEkonomiState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final fasilitasPendukungEkonomiProvider = StateNotifierProvider<FasilitasPendukungEkonomiNotifier, FasilitasPendukungEkonomiState>((ref) {
  return FasilitasPendukungEkonomiNotifier(ref.read(fasilitasPendukungEkonomiRepositoryProvider));
});

class FasilitasPendukungEkonomiNotifier extends StateNotifier<FasilitasPendukungEkonomiState> {
  final FasilitasPendukungEkonomiRepository _repository;

  FasilitasPendukungEkonomiNotifier(this._repository) : super(FasilitasPendukungEkonomiState()) {
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

  Future<Map<String, dynamic>> create(FasilitasPendukungEkonomi data) async {
    final result = await _repository.createFasilitasPendukungEkonomi(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, FasilitasPendukungEkonomi data) async {
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