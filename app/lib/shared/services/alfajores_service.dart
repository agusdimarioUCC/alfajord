import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alfajor_model.dart';
import 'api_client.dart';

class AlfajoresService {
  AlfajoresService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AlfajorModel>> getAlfajores({String? query}) async {
    final response = await _apiClient.get(
      'alfajores',
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    ) as Map<String, dynamic>;

    final data = response['data'] as List<dynamic>? ?? [];
    return data.map((item) => AlfajorModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AlfajorModel> getAlfajor(String id) async {
    final response = await _apiClient.get('alfajores/$id') as Map<String, dynamic>;
    final data = response['data'] as Map<String, dynamic>? ?? {};
    return AlfajorModel.fromJson(data);
  }

  Future<AlfajorModel> createAlfajor(AlfajorModel alfajor) async {
    final response = await _apiClient.post(
      'alfajores',
      data: {
        'nombre': alfajor.nombre,
        'marca': alfajor.marca,
        'pais': alfajor.pais,
        'tipo': alfajor.tipo,
        'cobertura': alfajor.cobertura,
        'descripcion': alfajor.descripcion,
        'imagen': alfajor.imagen,
      },
    ) as Map<String, dynamic>;

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return AlfajorModel.fromJson(data);
  }
}

final alfajoresServiceProvider = Provider<AlfajoresService>((ref) {
  final client = ref.watch(apiClientProvider);
  return AlfajoresService(client);
});
