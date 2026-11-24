import 'package:esme26/domain/models/models.dart';
import 'package:esme26/domain/repositories/kyc_repository.dart';
import 'package:esme26/domain/repositories/region_map_repository.dart';
import 'package:esme26/domain/repositories/user_repository.dart';
import 'package:esme26/ui/pages/create_work_request_page.dart';
import 'package:esme26/ui/pages/customer_work_requests_page.dart';
import 'package:esme26/ui/pages/home_page.dart';
import 'package:esme26/ui/pages/onboarding_page.dart';
import 'package:esme26/ui/pages/work_request_board_page.dart';
import 'package:esme26/ui/pages/work_request_details_page.dart';
import 'package:esme26/ui/widgets/app_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter({
  required ValueNotifier<bool> darkMode,
  required VoidCallback onToggleDarkMode,
  KycRepository? kycRepository,
  UserRepository? userRepository,
  RegionMapRepository? regionMapRepository,
}) {
  // Pushed above the shell so that their app bar shows a back button.
  GoRoute page(
    String path,
    String title,
    Widget Function(GoRouterState state) builder,
  ) => GoRoute(
    path: path,
    builder: (context, state) => AppShell(
      title: title,
      darkMode: darkMode,
      onToggleDarkMode: onToggleDarkMode,
      child: builder(state),
    ),
  );

  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          title: state.uri.path == '/homepage'
              ? 'Accueil'
              : 'Faisons connaissance',
          darkMode: darkMode,
          onToggleDarkMode: onToggleDarkMode,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => OnboardingPage(
              kycRepository: kycRepository,
              userRepository: userRepository,
            ),
          ),
          GoRoute(
            path: '/homepage',
            builder: (context, state) {
              if (state.extra case (
                role: UserRole role,
                firstName: String firstName,
              )) {
                return HomePage(
                  role: role,
                  firstName: firstName,
                  regionMapRepository: regionMapRepository,
                  userRepository: userRepository,
                );
              }

              if (userRepository?.me() case final User user) {
                return HomePage(
                  role: user.roles.contains(UserRole.artisan)
                      ? UserRole.artisan
                      : UserRole.customer,
                  firstName: user.firstName,
                  regionMapRepository: regionMapRepository,
                  userRepository: userRepository,
                );
              }

              return HomePage(
                role: UserRole.customer,
                firstName: 'John Doe',
                regionMapRepository: regionMapRepository,
                userRepository: userRepository,
              );
            },
          ),
        ],
      ),
      page(
        '/requests',
        'Demandes de projet',
        (state) => const WorkRequestBoardPage(),
      ),
      page(
        '/my-requests',
        'Mes demandes',
        (state) => CustomerWorkRequestsPage(userRepository: userRepository),
      ),
      // Declared before '/requests/:id' so that "new" is not read as an id.
      page(
        '/requests/new',
        'Nouvelle demande',
        (state) => CreateWorkRequestPage(userRepository: userRepository),
      ),
      page(
        '/requests/:id',
        'Demande de projet',
        (state) => WorkRequestDetailsPage(
          requestId: state.pathParameters['id']!,
          userRepository: userRepository,
        ),
      ),
    ],
  );
}
