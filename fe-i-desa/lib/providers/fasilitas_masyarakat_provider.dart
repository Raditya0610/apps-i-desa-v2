import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sub_dimensions/fasilitas_masyarakat.dart';
import '../data/repositories/fasilitas_masyarakat_repository.dart';

final fasilitasMasyarakatRepositoryProvider = Provider<FasilitasMasyarakatRepository>((ref) {
  return FasilitasMasyarakatRepository();
});

class FasilitasMasyarakatState {
  final List<FasilitasMasyarakat> records;
  final bool isLoading;
  final String? error;

  FasilitasMasyarakatState({this.records = const [], this.isLoading = false, this.error});

  FasilitasMasyarakatState copyWith({List<FasilitasMasyarakat>? records, bool? isLoading, String? error}) {
    return FasilitasMasyarakatState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final fasilitasMasyarakatProvider = StateNotifierProvider<FasilitasMasyarakatNotifier, FasilitasMasyarakatState>((ref) {
  return FasilitasMasyarakatNotifier(ref.read(fasilitasMasyarakatRepositoryProvider));
});

class FasilitasMasyarakatNotifier extends StateNotifier<FasilitasMasyarakatState> {
  final FasilitasMasyarakatRepository _repository;

  FasilitasMasyarakatNotifier(this._repository) : super(FasilitasMasyarakatState()) {
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

  Future<Map<String, dynamic>> create(FasilitasMasyarakat data) async {
    final result = await _repository.createFasilitasMasyarakat(data);
    if (result['success'] == true) await loadRecords();
    return result;
  }

  Future<Map<String, dynamic>> update(String id, FasilitasMasyarakat data) async {
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