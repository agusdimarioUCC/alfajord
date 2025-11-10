class UserStatsModel {
  const UserStatsModel({
    required this.totalReseñas,
    required this.totalAlfajoresDistintos,
    required this.promedioPuntuacionDada,
  });

  final int totalReseñas;
  final int totalAlfajoresDistintos;
  final double promedioPuntuacionDada;

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalReseñas: (json['totalReseñas'] as num?)?.toInt() ?? 0,
      totalAlfajoresDistintos: (json['totalAlfajoresDistintos'] as num?)?.toInt() ?? 0,
      promedioPuntuacionDada:
          (json['promedioPuntuacionDada'] as num?)?.toDouble() ?? 0,
    );
  }
}
