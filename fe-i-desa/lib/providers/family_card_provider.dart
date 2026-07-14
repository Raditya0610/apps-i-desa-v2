import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/family_card.dart';
import '../data/repositories/family_card_repository.dart';

// Family Card Repository Provider
final familyCardRepositoryProvider = Provider<FamilyCardRepository>((ref) {
  return FamilyCardRepository();
});

// Family Cards Provider
final familyCardsProvider = StateNotifierProvider<FamilyCardsNotifier, FamilyCardsState>((ref) {
  return FamilyCardsNotifier(ref.read(familyCardRepositoryProvider));
});

// Family Cards State
class FamilyCardsState {
  final List<FamilyCard> familyCards;
  final bool isLoading;
  final String? error;

  /// Set when the server was unreachable and [familyCards] is a cached copy.
  final bool isFromCache;
  final DateTime? cachedAt;

  FamilyCardsState({
    this.familyCards = const [],
    this.isLoading = false,
    this.error,
    this.isFromCache = false,
    this.cachedAt,
  });

  FamilyCardsState copyWith({
    List<FamilyCard>? familyCards,
    bool? isLoading,
    String? error,
    bool? isFromCache,
    DateTime? cachedAt,
  }) {
    return FamilyCardsState(
      familyCards: familyCards ?? this.familyCards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFromCache: isFromCache ?? this.isFromCache,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}

// Family Cards Notifier
class FamilyCardsNotifier extends StateNotifier<FamilyCardsState> {
  final FamilyCardRepository _repository;

  FamilyCardsNotifier(this._repository) : super(FamilyCardsState()) {
    loadFamilyCards();
  }

  Future<void> loadFamilyCards() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getAllFamilyCards();
      // Built directly rather than via copyWith so a fresh load clears the
      // stale-cache flags left by a previous offline load.
      state = FamilyCardsState(
        familyCards: result.data,
        isLoading: false,
        isFromCache: result.isFromCache,
        cachedAt: result.cachedAt,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data kartu keluarga: $e',
      );
    }
  }

  Future<Map<String, dynamic>> addFamilyCard(FamilyCard familyCard) async {
    final result = await _repository.createFamilyCard(familyCard);

    if (result['success']) {
      await loadFamilyCards(); // Refresh the list
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteFamilyCard(String nik) async {
    final result = await _repository.deleteFamilyCard(nik);
    if (result['success'] == true) {
      await loadFamilyCards();
    }
    return result;
  }

  Future<void> refresh() async {
    await loadFamilyCards();
  }
}
