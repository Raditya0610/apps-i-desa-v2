import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/pengelolaan_lingkungan.dart';
import '../data/repositories/pengelolaan_lingkungan_repository.dart';

final pengelolaanLingkunganRepositoryProvider = Provider<PengelolaanLingkunganRepository>((ref) {
  return PengelolaanLingkunganRepository();
});

class PengelolaanLingkunganState {
  final List<PengelolaanLingkungan> records;
  final bool isLoading;
  final String? error;

  PengelolaanLingkunganState({this.records = const [], this.isLoading = false, this.error});

  PengelolaanLingkunganState copyWith({List<PengelolaanLingkungan>? records, bool? isLoading, String? error}) {
    return PengelolaanLingkunganState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final pengelolaanLingkunganProvider = StateNotifierProvider<PengelolaanLingkunganNotifier, PengelolaanLingkunganState>((ref) {
  return PengelolaanLingkunganNotifier(ref.read(pengelolaanLingkunganRepositoryProvider));
});

class PengelolaanLingkunganNotifier extends StateNotifier<PengelolaanLingkunganState> {
  final PengelolaanLingkunganRepository _repository;

  PengelolaanLingkunganNotifier(this._repository) : super(PengelolaanLingkunganState()) {
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

  Future<Map<String, dynamic>> create(PengelolaanLingkungan data) async {
    final result = await _repository.createPengelolaanLingkungan(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, PengelolaanLingkungan data) async {
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