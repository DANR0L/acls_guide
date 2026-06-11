import 'package:go_router/go_router.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/algorithm_screen.dart';
import '../../ui/screens/drugs_screen.dart';
import '../../ui/screens/about_screen.dart';
import '../../ui/screens/pals_calculator_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/algorithm/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AlgorithmScreen(algorithmId: id);
        },
      ),
      GoRoute(
        path: '/drugs',
        builder: (context, state) => const DrugsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/pals',
        builder: (context, state) => const PalsCalculatorScreen(),
      ),
    ],
  );
}
