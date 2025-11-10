import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/review_model.dart';
import '../../shared/services/reviews_service.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/rating_stars.dart';

class ReviewFormArgs {
  const ReviewFormArgs({required this.alfajorId, this.review});

  final String alfajorId;
  final ReviewModel? review;
}

class ReviewFormScreen extends ConsumerStatefulWidget {
  const ReviewFormScreen({super.key, required this.args});

  final ReviewFormArgs args;

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen> {
  late double _rating;
  late TextEditingController _textController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.args.review?.puntuacion ?? 3;
    _textController = TextEditingController(text: widget.args.review?.texto ?? '');
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_rating < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccioná una puntuación.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final reviewsService = ref.read(reviewsServiceProvider);

    try {
      if (widget.args.review == null) {
        await reviewsService.createReview(
          widget.args.alfajorId,
          _rating,
          _textController.text.trim().isEmpty ? null : _textController.text.trim(),
        );
      } else {
        await reviewsService.updateReview(
          widget.args.review!.id,
          _rating,
          _textController.text.trim().isEmpty ? null : _textController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.args.review != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar reseña' : 'Nueva reseña')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Puntuación'),
            RatingStars(
              rating: _rating,
              onRatingSelected: (value) => setState(() => _rating = value),
              size: 30,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: isEditing ? 'Guardar cambios' : 'Publicar reseña',
              isLoading: _submitting,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
