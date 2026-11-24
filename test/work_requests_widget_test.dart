import 'package:esme26/data/mocks/mock_data.dart';
import 'package:esme26/data/repositories/in_memory_user_repository.dart';
import 'package:esme26/data/repositories/work_request_repository_impl.dart';
import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/repositories/region_map_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/ui/router.dart';
import 'package:esme26/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _EmptyRegionMapRepository implements RegionMapRepository {
  @override
  Future<RegionMap> load() async => RegionMap(
    name: 'Test',
    attribution: 'OpenStreetMap contributors',
    southWest: GeoPoint(latitude: 48.1, longitude: 1.4),
    northEast: GeoPoint(latitude: 49.3, longitude: 3.6),
    roads: const [],
    rivers: const [],
    boundary: const [],
    places: const [],
  );
}

Future<GoRouter> pumpApp(
  WidgetTester tester, {
  required UserRepository userRepository,
}) async {
  final darkMode = ValueNotifier(false);
  final router = createRouter(
    darkMode: darkMode,
    onToggleDarkMode: () => darkMode.value = !darkMode.value,
    userRepository: userRepository,
    regionMapRepository: _EmptyRegionMapRepository(),
  );
  addTearDown(() {
    router.dispose();
    darkMode.dispose();
  });
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
  );
  return router;
}

Future<void> openHome(
  GoRouter router,
  WidgetTester tester,
  UserRole role,
) async {
  router.go('/homepage', extra: (role: role, firstName: 'Test'));
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterField(WidgetTester tester, String label, String value) async {
  final finder = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, value);
}

void main() {
  // Pages use the shared mock repository: restore its fixtures after each test.
  tearDown(() => WorkRequestRepositoryImpl().reset());

  testWidgets('Artisan browses open requests, filters by trade and opens one', (
    tester,
  ) async {
    final users = InMemoryUserRepository()..setUser(MockData.artisan);
    final router = await pumpApp(tester, userRepository: users);
    await openHome(router, tester, UserRole.artisan);

    expect(find.text('8 demandes ouvertes aux devis'), findsOneWidget);
    await tap(tester, find.text('Demandes de projet'));

    expect(router.state.uri.path, '/requests');
    expect(find.text('Remplacement d’un chauffe-eau en panne'), findsOneWidget);
    expect(find.text('Repeindre le salon'), findsNothing);

    await tap(tester, find.widgetWithText(ChoiceChip, 'Peinture'));
    expect(find.text('Peinture d’une chambre d’enfant'), findsOneWidget);
    expect(find.text('Rafraîchir les peintures du couloir'), findsOneWidget);
    expect(find.text('Remplacement d’un chauffe-eau en panne'), findsNothing);

    await tap(tester, find.text('Peinture d’une chambre d’enfant'));
    expect(router.state.uri.path, '/requests/request-7');
    expect(find.widgetWithText(Chip, 'Peinture intérieure'), findsOneWidget);
    expect(find.text('Montreuil (93100)'), findsOneWidget);
    expect(find.text('Du 14 déc. 2026 au 23 déc. 2026'), findsOneWidget);
    expect(find.text('Publiée'), findsNothing);

    await tap(tester, find.byType(BackButton));
    expect(find.text('Rafraîchir les peintures du couloir'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Customer validates and publishes a request seen by artisans', (
    tester,
  ) async {
    final router = await pumpApp(
      tester,
      userRepository: InMemoryUserRepository(),
    );
    await openHome(router, tester, UserRole.customer);

    expect(find.text('5 demandes · 3 en cours'), findsOneWidget);
    await tap(tester, find.text('Mes demandes de projet'));
    expect(find.text('Fuite sous l’évier de la cuisine'), findsOneWidget);
    expect(find.text('Publiée'), findsWidgets);

    // Already on screen: tap without scrolling the list header away.
    await tester.tap(find.text('Nouvelle demande'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/requests/new');
    expect(find.text('Paris'), findsOneWidget);

    await tap(tester, find.text('Publier ma demande'));
    expect(find.text('Au moins 5 caractères.'), findsOneWidget);
    expect(
      find.text('Choisissez au moins un corps de métier.'),
      findsOneWidget,
    );

    await enterField(tester, 'Titre du projet', 'Installer des spots LED');
    await enterField(
      tester,
      'Description',
      'Six spots encastrés dans le faux plafond du séjour.',
    );
    await tap(tester, find.widgetWithText(FilterChip, 'Électricité'));
    expect(find.text('Choisissez au moins un corps de métier.'), findsNothing);
    await tap(tester, find.widgetWithText(ChoiceChip, 'Urgent'));
    expect(
      find.text('Une intervention rapide est nécessaire.'),
      findsOneWidget,
    );
    await enterField(tester, 'Minimum', '500');
    await enterField(tester, 'Maximum', '200');
    await tap(tester, find.text('Publier ma demande'));
    expect(find.text('Doit être supérieur au minimum.'), findsOneWidget);
    expect(router.state.uri.path, '/requests/new');

    await enterField(tester, 'Maximum', '900');
    await tap(tester, find.text('Publier ma demande'));

    expect(router.state.uri.path, '/my-requests');
    expect(find.text('Votre demande a été publiée.'), findsOneWidget);
    expect(find.text('Installer des spots LED'), findsOneWidget);
    expect(find.text('6 demandes · 4 en cours'), findsOneWidget);

    router.go('/requests');
    await tester.pumpAndSettle();
    expect(find.text('9 demandes ouvertes aux devis'), findsOneWidget);
    expect(find.text('Installer des spots LED'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('A customer without requests is invited to create one', (
    tester,
  ) async {
    final users = InMemoryUserRepository()
      ..setUser(
        User(
          id: 'user-new',
          firstName: 'Nina',
          lastName: 'Petit',
          email: '',
          birthDateInMillisFromEpoch: 0,
          adress: const Adress(
            street: '',
            city: 'Vincennes',
            postalCode: '94300',
            country: 'France',
          ),
        ),
      );
    final router = await pumpApp(tester, userRepository: users);
    await openHome(router, tester, UserRole.customer);

    expect(find.text('Décrivez vos travaux aux artisans'), findsOneWidget);
    await tap(tester, find.text('Mes demandes de projet'));
    expect(find.text('Nouvelle demande'), findsNothing);

    await tap(tester, find.text('Créer ma première demande'));
    expect(find.text('Vincennes'), findsOneWidget);
    expect(find.text('94300'), findsOneWidget);
  });

  testWidgets('An unknown request shows a not found message', (tester) async {
    final router = await pumpApp(
      tester,
      userRepository: InMemoryUserRepository(),
    );
    router.go('/requests/missing');
    await tester.pumpAndSettle();
    expect(
      find.text('Cette demande de projet est introuvable.'),
      findsOneWidget,
    );
  });

  testWidgets('Request screens fit a small phone screen', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = await pumpApp(
      tester,
      userRepository: InMemoryUserRepository(),
    );
    for (final path in [
      '/requests',
      '/my-requests',
      '/requests/new',
      '/requests/request-8',
    ]) {
      router.go(path);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: path);
    }
  });
}
