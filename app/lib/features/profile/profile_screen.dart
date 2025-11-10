import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../../shared/models/user_stats_model.dart';
import '../../shared/routes.dart';
import '../../shared/services/profile_service.dart';
import '../../shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<UserStatsModel>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(profileServiceProvider).getMyStats();
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Iniciá sesión para ver tu perfil.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.nombreVisible, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(user.email),
            if (user.bio != null) ...[
              const SizedBox(height: 8),
              Text(user.bio!),
            ],
            const SizedBox(height: 24),
            FutureBuilder<UserStatsModel>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Text('No se pudieron cargar las estadísticas.');
                }

                final stats = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reseñas publicadas: ${stats.totalReseñas}'),
                        const SizedBox(height: 8),
                        Text('Alfajores distintos: ${stats.totalAlfajoresDistintos}'),
                        const SizedBox(height: 8),
                        Text(
                          'Promedio otorgado: ${stats.promedioPuntuacionDada.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Cerrar sesión',
              onPressed: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
