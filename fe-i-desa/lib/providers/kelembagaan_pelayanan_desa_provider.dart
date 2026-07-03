import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/kelembagaan_pelayanan_desa.dart';
import '../data/repositories/kelembagaan_pelayanan_desa_repository.dart';

final kelembagaanPelayananDesaRepositoryProvider = Provider<KelembagaanPelayananDesaRepository>((ref) {
  return KelembagaanPelayananDesaRepository();
});

class KelembagaanPelayananDesaState {
  final List<KelembagaanPelayananDesa> records;
  final bool isLoading;
  final String? error;

  KelembagaanPelayananDesaState({this.records = const [], this.isLoading = false, this.error});

  KelembagaanPelayananDesaState copyWith({List<KelembagaanPelayananDesa>? records, bool? isLoading, String? error}) {
    return KelembagaanPelayananDesaState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final kelembagaanPelayananDesaProvider = StateNotifierProvider<KelembagaanPelayananDesaNotifier, KelembagaanPelayananDesaState>((ref) {
  return KelembagaanPelayananDesaNotifier(ref.read(kelembagaanPelayananDesaRepositoryProvider));
});

class KelembagaanPelayananDesaNotifier extends StateNotifier<KelembagaanPelayananDesaState> {
  final KelembagaanPelayananDesaRepository _repository;

  KelembagaanPelayananDesaNotifier(this._repository) : super(KelembagaanPelayananDesaState()) {
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

  Future<Map<String, dynamic>> create(KelembagaanPelayananDesa data) async {
    final result = await _repository.createKelembagaanPelayananDesa(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, KelembagaanPelayananDesa data) async {
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