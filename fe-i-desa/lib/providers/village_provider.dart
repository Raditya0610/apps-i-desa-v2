import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/village.dart';
import '../data/repositories/village_repository.dart';

final villageRepositoryProvider = Provider<VillageRepository>((ref) {
  return VillageRepository();
});

/// Villages available on the registration screen.
///
/// Not cached offline on purpose: registering needs the network anyway, so a
/// stale list would only let someone fill in a form that cannot be submitted.
final villagesProvider = FutureProvider<List<Village>>((ref) async {
  return ref.read(villageRepositoryProvider).getAllVillages();
});
