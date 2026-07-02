import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/kondisi_akses_jalan.dart';
import '../data/repositories/kondisi_akses_jalan_repository.dart';

final kondisiAksesJalanRepositoryProvider = Provider<KondisiAksesJalanRepository>((ref) {
  return KondisiAksesJalanRepository();
});

class KondisiAksesJalanState {
  final List<KondisiAksesJalan> records;
  final bool isLoading;
  final String? error;

  KondisiAksesJalanState({this.records = const [], this.isLoading = false, this.error});

  KondisiAksesJalanState copyWith({List<KondisiAksesJalan>? records, bool? isLoading, String? error}) {
    return KondisiAksesJalanState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final kondisiAksesJalanProvider = StateNotifierProvider<KondisiAksesJalanNotifier, KondisiAksesJalanState>((ref) {
  return KondisiAksesJalanNotifier(ref.read(kondisiAksesJalanRepositoryProvider));
});

class KondisiAksesJalanNotifier extends StateNotifier<KondisiAksesJalanState> {
  final KondisiAksesJalanRepository _repository;

  KondisiAksesJalanNotifier(this._repository) : super(KondisiAksesJalanState()) {
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

  Future<Map<String, dynamic>> create(KondisiAksesJalan data) async {
    final result = await _repository.createKondisiAksesJalan(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, KondisiAksesJalan data) async {
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