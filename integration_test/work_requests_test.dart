import 'package:esme26/data/repositories/in_memory_user_repository.dart';
import 'package:esme26/main.dart';
import 'package:esme26/ui/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end tour of the work request screens on a device or emulator.
///
/// flutter drive --driver=test_driver/integration_test.dart \
///   --target=integration_test/work_requests_test.dart -d DEVICE_ID
///
/// Screenshots are written to build/screenshots/.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Customer publishes a request, artisan browses requests', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    // In-memory users: the run does not touch the device's Drift database.
    await tester.pumpWidget(
      MyApp(preferences: preferences, userRepository: InMemoryUserRepository()),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    Future<void> tapOn(Finder finder) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> tapText(String text) => tapOn(find.text(text));

    Future<void> enter(String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, value);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    Future<void> scrollTo(Finder finder) => tester.scrollUntilVisible(
      finder,
      300,
      scrollable: find.byType(Scrollable).last,
    );

    // --- Customer -------------------------------------------------------
    await tapText('Je suis particulier');
    await tapText('Rénovation');
    await tapText('Continuer');
    await enter('Prénom', 'Nina');
    await enter('Nom', 'Petit');
    await tapText('Continuer');
    await enter('Ville', 'Vincennes');
    await enter('Code postal', '94300');
    await tapText('Continuer');
    expect(find.text('Mes demandes de projet'), findsOneWidget);
    await shot('01_customer_home');

    await tapText('Mes demandes de projet');
    expect(find.text('Créer ma première demande'), findsOneWidget);
    await shot('02_customer_empty_list');

    await tapText('Créer ma première demande');
    await shot('03_create_form');

    await tapText('Publier ma demande');
    expect(
      find.text('Choisissez au moins un corps de métier.'),
      findsOneWidget,
    );
    await shot('04_create_form_errors');

    await enter('Titre du projet', 'Installer des spots LED');
    await enter(
      'Description',
      'Six spots encastrés dans le faux plafond du séjour, avec variateur.',
    );
    await tapOn(find.widgetWithText(FilterChip, 'Électricité'));
    await tapOn(find.widgetWithText(ChoiceChip, 'Planifié'));
    await enter('Minimum', '400');
    await enter('Maximum', '700');
    await tester.ensureVisible(find.text('Publier ma demande'));
    await shot('05_create_form_filled');

    await tapText('Publier ma demande');
    expect(find.text('Installer des spots LED'), findsOneWidget);
    await shot('06_customer_list_after_publish');

    await tapText('Installer des spots LED');
    expect(find.textContaining('Votre demande, publiée le'), findsOneWidget);
    await shot('07_customer_request_details');

    // --- Artisan (same app run, so the new request is shared) ----------
    GoRouter.of(tester.element(find.byType(AppShell).last)).go('/');
    await tester.pumpAndSettle();
    await tapText('Je suis artisan');
    await enter('Métier', 'Plombier');
    await tapText('Continuer');
    await enter('Ville', 'Paris');
    await enter('Code postal', '75011');
    await tapText('Continuer');
    await tapText('Simuler la vérification');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('Demandes de projet'), findsOneWidget);
    await shot('08_artisan_home');

    await tapText('Demandes de projet');
    expect(find.text('Installer des spots LED'), findsOneWidget);
    await shot('09_artisan_board');

    await tapOn(find.widgetWithText(ChoiceChip, 'Plomberie'));
    expect(find.text('Installer des spots LED'), findsNothing);
    await shot('10_artisan_board_plumbing');

    final bathroom = find.text('Rénovation complète de la salle de bain');
    await scrollTo(bathroom);
    await tapOn(bathroom);
    expect(find.text('Plomberie'), findsWidgets);
    await shot('11_artisan_request_details');
    await scrollTo(find.text('salle-de-bain-actuelle.jpg'));
    await shot('12_artisan_request_details_bottom');

    await tapOn(find.byType(BackButton));
    final darkModeToggle = find.byTooltip('Activer le mode sombre');
    await tapOn(darkModeToggle.last);
    await shot('13_artisan_board_dark');
    await tapOn(find.byTooltip('Activer le mode clair').last);
  });
}
