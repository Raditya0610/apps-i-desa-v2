import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/produksi_desa.dart';
import '../data/repositories/produksi_desa_repository.dart';

final produksiDesaRepositoryProvider = Provider<ProduksiDesaRepository>((ref) {
  return ProduksiDesaRepository();
});

class ProduksiDesaState {
  final List<ProduksiDesa> records;
  final bool isLoading;
  final String? error;

  ProduksiDesaState({this.records = const [], this.isLoading = false, this.error});

  ProduksiDesaState copyWith({List<ProduksiDesa>? records, bool? isLoading, String? error}) {
    return ProduksiDesaState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final produksiDesaProvider = StateNotifierProvider<ProduksiDesaNotifier, ProduksiDesaState>((ref) {
  return ProduksiDesaNotifier(ref.read(produksiDesaRepositoryProvider));
});

class ProduksiDesaNotifier extends StateNotifier<ProduksiDesaState> {
  final ProduksiDesaRepository _repository;

  ProduksiDesaNotifier(this._repository) : super(ProduksiDesaState()) {
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

  Future<Map<String, dynamic>> create(ProduksiDesa data) async {
    final result = await _repository.createProduksiDesa(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, ProduksiDesa data) async {
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