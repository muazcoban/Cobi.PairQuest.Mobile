import 'package:go_router/go_router.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/levels/levels_screen.dart';
import '../../presentation/screens/game/game_screen.dart';

/// Application router configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelsScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final levelStr = state.uri.queryParameters['level'] ?? '5';
        final mode = state.uri.queryParameters['mode'] ?? 'classic';
        final level = int.tryParse(levelStr) ?? 5;
        
        return GameScreen(
          level: level,
          mode: mode,
        );
      },
    ),
  ],
);
