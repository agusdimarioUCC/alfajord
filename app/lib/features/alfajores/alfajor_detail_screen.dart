import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../../shared/models/alfajor_model.dart';
import '../../shared/models/review_model.dart';
import '../../shared/routes.dart';
import '../../shared/services/alfajores_service.dart';
import '../../shared/services/reviews_service.dart';
import '../../shared/widgets/rating_stars.dart';
import '../reviews/review_form_screen.dart';

class AlfajorDetailScreen extends ConsumerStatefulWidget {
  const AlfajorDetailScreen({super.key, required this.alfajorId});

  final String alfajorId;

  @override
  ConsumerState<AlfajorDetailScreen> createState() => _AlfajorDetailScreenState();
}

class _AlfajorDetailScreenState extends ConsumerState<AlfajorDetailScreen> {
  AlfajorModel? _alfajor;
  List<ReviewModel> _reviews = const [];
  bool _loading = true;
  bool _reviewsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final alfajoresService = ref.read(alfajoresServiceProvider);
    final reviewsService = ref.read(reviewsServiceProvider);

    setState(() {
      _loading = true;
      _reviewsLoading = true;
    });

    try {
      final result = await alfajoresService.getAlfajor(widget.alfajorId);
      final reviews = await reviewsService.getReviews(widget.alfajorId);
      setState(() {
        _alfajor = result;
        _reviews = reviews;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _reviewsLoading = false;
      });
    }
  }

  Future<void> _openReviewForm({ReviewModel? review}) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.review,
      arguments: ReviewFormArgs(
        alfajorId: widget.alfajorId,
        review: review,
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Seguro que querés eliminar esta reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(reviewsServiceProvider).deleteReview(reviewId);
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final canCreate = authState.isAuthenticated;
    final currentUserId = authState.user?.id;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_alfajor == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el alfajor.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del alfajor')),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _openReviewForm(),
              icon: const Icon(Icons.rate_review),
              label: const Text('Reseñar'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              _alfajor!.nombre,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('${_alfajor!.marca} • ${_alfajor!.pais}'),
            const SizedBox(height: 8),
            Text('Tipo: ${_alfajor!.tipo}'),
            Text('Cobertura: ${_alfajor!.cobertura}'),
            const SizedBox(height: 12),
            Row(
              children: [
                RatingStars(rating: _alfajor!.promedioPuntuacion),
                const SizedBox(width: 8),
                Text(
                  '${_alfajor!.promedioPuntuacion.toStringAsFixed(1)} (${_alfajor!.totalReseñas} reseñas)',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_alfajor!.descripcion != null)
              Text(_alfajor!.descripcion!),
            const SizedBox(height: 24),
            Text(
              'Reseñas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (_reviewsLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_reviews.isEmpty) ...[
              const Text('Sé el primero en reseñar este alfajor.'),
            ] else ..._reviews.map(
                (review) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(review.author?.nombreVisible ?? 'Usuario'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingStars(rating: review.puntuacion),
                        if (review.texto != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(review.texto!),
                          ),
                      ],
                    ),
                    trailing: review.userId == currentUserId
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _openReviewForm(review: review);
                              } else if (value == 'delete') {
                                _deleteReview(review.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
