import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/kemudahan_akses.dart';
import '../data/repositories/kemudahan_akses_repository.dart';

final kemudahanAksesRepositoryProvider = Provider<KemudahanAksesRepository>((ref) {
  return KemudahanAksesRepository();
});

class KemudahanAksesState {
  final List<KemudahanAkses> records;
  final bool isLoading;
  final String? error;

  KemudahanAksesState({this.records = const [], this.isLoading = false, this.error});

  KemudahanAksesState copyWith({List<KemudahanAkses>? records, bool? isLoading, String? error}) {
    return KemudahanAksesState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final kemudahanAksesProvider = StateNotifierProvider<KemudahanAksesNotifier, KemudahanAksesState>((ref) {
  return KemudahanAksesNotifier(ref.read(kemudahanAksesRepositoryProvider));
});

class KemudahanAksesNotifier extends StateNotifier<KemudahanAksesState> {
  final KemudahanAksesRepository _repository;

  KemudahanAksesNotifier(this._repository) : super(KemudahanAksesState()) {
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

  Future<Map<String, dynamic>> create(KemudahanAkses data) async {
    final result = await _repository.createKemudahanAkses(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, KemudahanAkses data) async {
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