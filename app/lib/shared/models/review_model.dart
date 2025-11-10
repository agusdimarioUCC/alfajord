class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.alfajorId,
    required this.userId,
    required this.puntuacion,
    this.texto,
    this.fechaConsumo,
    required this.fechaPublicacion,
    this.author,
  });

  final String id;
  final String alfajorId;
  final String userId;
  final double puntuacion;
  final String? texto;
  final DateTime? fechaConsumo;
  final DateTime fechaPublicacion;
  final ReviewAuthor? author;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _readId(json),
      alfajorId: _readId(json['alfajorId']),
      userId: _readId(json['userId']),
      puntuacion: (json['puntuacion'] as num?)?.toDouble() ?? 0,
      texto: json['texto'] as String?,
      fechaConsumo: json['fechaConsumo'] != null
          ? DateTime.tryParse(json['fechaConsumo'] as String)
          : null,
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.tryParse(json['fechaPublicacion'] as String) ?? DateTime.now()
          : DateTime.now(),
      author: ReviewAuthor.fromJson(json['userId'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'alfajorId': alfajorId,
        'userId': userId,
        'puntuacion': puntuacion,
        'texto': texto,
        'fechaConsumo': fechaConsumo?.toIso8601String(),
        'fechaPublicacion': fechaPublicacion.toIso8601String(),
        'user': author?.toJson(),
      };
}

class ReviewAuthor {
  const ReviewAuthor({
    required this.id,
    required this.nombreVisible,
    this.avatarUrl,
  });

  final String id;
  final String nombreVisible;
  final String? avatarUrl;

  factory ReviewAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ReviewAuthor(id: '', nombreVisible: 'Usuario');
    }

    return ReviewAuthor(
      id: _readId(json),
      nombreVisible: json['nombreVisible'] as String? ?? 'Usuario',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombreVisible': nombreVisible,
        'avatarUrl': avatarUrl,
      };
}

String _readId(dynamic source) {
  if (source is Map<String, dynamic>) {
    return source['id'] as String? ?? source['_id'] as String? ?? '';
  }
  if (source is String) {
    return source;
  }
  return '';
}
