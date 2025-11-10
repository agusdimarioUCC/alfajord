import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_stats_model.dart';
import 'api_client.dart';

class ProfileService {
  ProfileService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserStatsModel> getMyStats() async {
    final response = await _apiClient.get('stats/me') as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return UserStatsModel.fromJson(data);
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileService(client);
});
