import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review_model.dart';
import 'api_client.dart';

class ReviewsService {
  ReviewsService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ReviewModel>> getReviews(String alfajorId) async {
    final response =
        await _apiClient.get('reviews/alfajor/$alfajorId') as Map<String, dynamic>;
    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((item) => ReviewModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ReviewModel> createReview(
    String alfajorId,
    double puntuacion,
    String? texto,
  ) async {
    final response = await _apiClient.post(
      'reviews',
      data: {
        'alfajorId': alfajorId,
        'puntuacion': puntuacion,
        'texto': texto,
      },
    ) as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return ReviewModel.fromJson(data);
  }

  Future<ReviewModel> updateReview(
    String reviewId,
    double puntuacion,
    String? texto,
  ) async {
    final response = await _apiClient.put(
      'reviews/$reviewId',
      data: {
        'puntuacion': puntuacion,
        'texto': texto,
      },
    ) as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return ReviewModel.fromJson(data);
  }

  Future<void> deleteReview(String reviewId) async {
    await _apiClient.delete('reviews/$reviewId');
  }
}

final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReviewsService(client);
});
