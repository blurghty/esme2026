import 'package:esme26/data/models/adress.dart';
import 'package:esme26/data/models/user.dart';
import 'package:esme26/data/repositories/user_repository.dart';
import 'package:esme26/data/repositories/user_repository_JP.dart';
import 'package:esme26/data/repositories/user_repository_impl.dart';
import 'package:esme26/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    UserRepositoryJP().reset();
    UserRepositoryImpl().reset();
  });
  tearDown(() {
    UserRepositoryJP().reset();
    UserRepositoryImpl().reset();
  });

  test('UserRepositoryImpl returns the same instance', () {
    expect(UserRepositoryImpl(), same(UserRepositoryImpl()));
    expect(UserRepositoryJP(), same(UserRepositoryJP()));
    expect(UserRepository.instance, same(UserRepositoryJP()));
  });

  test('existing repositories can store and return domain users', () {
    final user = User(
      firstName: 'Test',
      lastName: 'Client',
      email: 'client@example.test',
      birthDateInMillisFromEpoch: DateTime.utc(2000).millisecondsSinceEpoch,
      adress: const Adress(
        street: '1 rue du Test',
        city: 'Paris',
        postalCode: '75001',
        country: 'France',
      ),
    );
    for (final repository in <UserRepository>[
      UserRepositoryJP(),
      UserRepositoryImpl(),
    ]) {
      expect(repository.me(), isA<User>());
      repository.setUser(user);
      expect(repository.me(), same(user));
    }
  });

  testWidgets('the app opens onboarding and home shows the repository user', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final user = UserRepository.instance.me()!;
    await tester.pumpWidget(
      MyApp(preferences: preferences, userRepository: UserRepository.instance),
    );
    await tester.pumpAndSettle();
    expect(find.text('Je suis particulier'), findsOneWidget);

    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/homepage');
    // The offline map keeps loading in the background: do not wait for it.
    await tester.pump();
    await tester.pump();
    expect(find.text('Bienvenue ${user.firstName} !'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
