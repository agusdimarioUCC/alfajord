import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/alfajores/alfajor_detail_screen.dart';
import 'features/alfajores/alfajores_list_screen.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reviews/review_form_screen.dart';
import 'shared/routes.dart';

void main() {
  runApp(const ProviderScope(child: AlfajordApp()));
}

class AlfajordApp extends ConsumerWidget {
  const AlfajordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Alfajord',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
        brightness: Brightness.light,
      ),
      initialRoute: AppRoutes.loading,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.loading:
        return MaterialPageRoute(builder: (_) => const _AuthLoaderScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const AlfajoresListScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.review:
        final args = settings.arguments;
        if (args is ReviewFormArgs) {
          return MaterialPageRoute(builder: (_) => ReviewFormScreen(args: args));
        }
        return _errorRoute('Faltan datos para la reseña.');
    }

    final name = settings.name ?? '';
    if (name.startsWith('${AppRoutes.alfajorBase}/')) {
      final id = name.replaceFirst('${AppRoutes.alfajorBase}/', '');
      return MaterialPageRoute(
        builder: (_) => AlfajorDetailScreen(alfajorId: id),
      );
    }

    return _errorRoute('Ruta no encontrada');
  }

  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

class _AuthLoaderScreen extends ConsumerStatefulWidget {
  const _AuthLoaderScreen();

  @override
  ConsumerState<_AuthLoaderScreen> createState() => _AuthLoaderScreenState();
}

class _AuthLoaderScreenState extends ConsumerState<_AuthLoaderScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(ref.read(authProvider)));
    ref.listen<AuthState>(authProvider, (previous, next) {
      _navigate(next);
    });
  }

  void _navigate(AuthState state) {
    if (_navigated || state.isLoading) return;
    _navigated = true;
    final route = state.isAuthenticated ? AppRoutes.home : AppRoutes.login;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
