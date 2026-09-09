import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/catalog_repository.dart';
import '../../domain/models/catalog_models.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(),
);

final statesProvider = FutureProvider<List<StateCatalog>>((ref) {
  return ref.watch(catalogRepositoryProvider).getStates();
});

final municipalitiesProvider = FutureProvider.autoDispose.family<List<Municipality>, String>(
  (ref, stateId) =>
      ref.watch(catalogRepositoryProvider).getMunicipalities(stateId),
);

final schoolsByMunicipalityProvider = FutureProvider.autoDispose.family<List<School>, String?>(
  (ref, municipalityId) => ref
      .watch(catalogRepositoryProvider)
      .getSchools(municipalityId: municipalityId),
);

final schoolsProvider = FutureProvider<List<School>>((ref) {
  return ref.watch(catalogRepositoryProvider).getSchools();
});

final motherLanguagesProvider = FutureProvider<List<Language>>((ref) {
  return ref.watch(catalogRepositoryProvider).getLanguages(type: 'mother');
});

final foreignLanguagesProvider = FutureProvider<List<Language>>((ref) {
  return ref.watch(catalogRepositoryProvider).getLanguages(type: 'foreign');
});

final allLanguagesProvider = FutureProvider<List<Language>>((ref) {
  return ref.watch(catalogRepositoryProvider).getLanguages();
});

final careersCatalogProvider = FutureProvider<List<CareerCatalog>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCareers();
});
