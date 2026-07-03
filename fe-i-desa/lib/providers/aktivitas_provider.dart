import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/aktivitas.dart';
import '../data/repositories/aktivitas_repository.dart';

final aktivitasRepositoryProvider = Provider<AktivitasRepository>((ref) {
  return AktivitasRepository();
});

class AktivitasState {
  final List<Aktivitas> records;
  final bool isLoading;
  final String? error;

  AktivitasState({this.records = const [], this.isLoading = false, this.error});

  AktivitasState copyWith({List<Aktivitas>? records, bool? isLoading, String? error}) {
    return AktivitasState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final aktivitasProvider = StateNotifierProvider<AktivitasNotifier, AktivitasState>((ref) {
  return AktivitasNotifier(ref.read(aktivitasRepositoryProvider));
});

class AktivitasNotifier extends StateNotifier<AktivitasState> {
  final AktivitasRepository _repository;

  AktivitasNotifier(this._repository) : super(AktivitasState()) {
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

  Future<Map<String, dynamic>> create(Aktivitas data) async {
    final result = await _repository.createAktivitas(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, Aktivitas data) async {
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