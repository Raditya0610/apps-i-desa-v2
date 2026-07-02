import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/penanggulangan_bencana.dart';
import '../data/repositories/penanggulangan_bencana_repository.dart';

final penanggulanganBencanaRepositoryProvider = Provider<PenanggulanganBencanaRepository>((ref) {
  return PenanggulanganBencanaRepository();
});

class PenanggulanganBencanaState {
  final List<PenanggulanganBencana> records;
  final bool isLoading;
  final String? error;

  PenanggulanganBencanaState({this.records = const [], this.isLoading = false, this.error});

  PenanggulanganBencanaState copyWith({List<PenanggulanganBencana>? records, bool? isLoading, String? error}) {
    return PenanggulanganBencanaState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final penanggulanganBencanaProvider = StateNotifierProvider<PenanggulanganBencanaNotifier, PenanggulanganBencanaState>((ref) {
  return PenanggulanganBencanaNotifier(ref.read(penanggulanganBencanaRepositoryProvider));
});

class PenanggulanganBencanaNotifier extends StateNotifier<PenanggulanganBencanaState> {
  final PenanggulanganBencanaRepository _repository;

  PenanggulanganBencanaNotifier(this._repository) : super(PenanggulanganBencanaState()) {
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

  Future<Map<String, dynamic>> create(PenanggulanganBencana data) async {
    final result = await _repository.createPenanggulanganBencana(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, PenanggulanganBencana data) async {
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