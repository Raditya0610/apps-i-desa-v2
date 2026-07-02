import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/tata_kelola_keuangan_desa.dart';
import '../data/repositories/tata_kelola_keuangan_desa_repository.dart';

final tataKelolaKeuanganDesaRepositoryProvider = Provider<TataKelolaKeuanganDesaRepository>((ref) {
  return TataKelolaKeuanganDesaRepository();
});

class TataKelolaKeuanganDesaState {
  final List<TataKelolaKeuanganDesa> records;
  final bool isLoading;
  final String? error;

  TataKelolaKeuanganDesaState({this.records = const [], this.isLoading = false, this.error});

  TataKelolaKeuanganDesaState copyWith({List<TataKelolaKeuanganDesa>? records, bool? isLoading, String? error}) {
    return TataKelolaKeuanganDesaState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final tataKelolaKeuanganDesaProvider = StateNotifierProvider<TataKelolaKeuanganDesaNotifier, TataKelolaKeuanganDesaState>((ref) {
  return TataKelolaKeuanganDesaNotifier(ref.read(tataKelolaKeuanganDesaRepositoryProvider));
});

class TataKelolaKeuanganDesaNotifier extends StateNotifier<TataKelolaKeuanganDesaState> {
  final TataKelolaKeuanganDesaRepository _repository;

  TataKelolaKeuanganDesaNotifier(this._repository) : super(TataKelolaKeuanganDesaState()) {
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

  Future<Map<String, dynamic>> create(TataKelolaKeuanganDesa data) async {
    final result = await _repository.createTataKelolaKeuanganDesa(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, TataKelolaKeuanganDesa data) async {
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