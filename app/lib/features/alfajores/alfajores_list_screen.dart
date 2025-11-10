import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/alfajor_model.dart';
import '../../shared/routes.dart';
import '../../shared/services/alfajores_service.dart';
import '../../shared/widgets/rating_stars.dart';

class AlfajoresListScreen extends ConsumerStatefulWidget {
  const AlfajoresListScreen({super.key});

  @override
  ConsumerState<AlfajoresListScreen> createState() => _AlfajoresListScreenState();
}

class _AlfajoresListScreenState extends ConsumerState<AlfajoresListScreen> {
  final _searchController = TextEditingController();
  Future<List<AlfajorModel>>? _future;

  @override
  void initState() {
    super.initState();
    _fetchAlfajores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAlfajores() async {
    final service = ref.read(alfajoresServiceProvider);
    final future = service.getAlfajores(query: _searchController.text.trim());
    setState(() {
      _future = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alfajores'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o marca',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _fetchAlfajores,
                ),
              ),
              onSubmitted: (_) => _fetchAlfajores(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<AlfajorModel>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _future == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text('Sin datos.'));
                  }

                  final data = snapshot.data!;
                  if (data.isEmpty) {
                    return const Center(child: Text('No encontramos resultados.'));
                  }

                  return RefreshIndicator(
                    onRefresh: _fetchAlfajores,
                    child: ListView.separated(
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final alfajor = data[index];
                        return ListTile(
                          title: Text(alfajor.nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${alfajor.marca} • ${alfajor.pais}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  RatingStars(rating: alfajor.promedioPuntuacion),
                                  const SizedBox(width: 8),
                                  Text('(${alfajor.totalReseñas} reseñas)'),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.alfajorDetail(alfajor.id),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
