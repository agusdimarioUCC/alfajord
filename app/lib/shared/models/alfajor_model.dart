class AlfajorModel {
  const AlfajorModel({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.pais,
    required this.tipo,
    required this.cobertura,
    this.descripcion,
    this.imagen,
    required this.promedioPuntuacion,
    required this.totalReseñas,
  });

  final String id;
  final String nombre;
  final String marca;
  final String pais;
  final String tipo;
  final String cobertura;
  final String? descripcion;
  final String? imagen;
  final double promedioPuntuacion;
  final int totalReseñas;

  factory AlfajorModel.fromJson(Map<String, dynamic> json) {
    return AlfajorModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      marca: json['marca'] as String? ?? '',
      pais: json['pais'] as String? ?? '',
      tipo: json['tipo'] as String? ?? '',
      cobertura: json['cobertura'] as String? ?? '',
      descripcion: json['descripcion'] as String?,
      imagen: json['imagen'] as String?,
      promedioPuntuacion: (json['promedioPuntuacion'] as num?)?.toDouble() ?? 0,
      totalReseñas: (json['totalReseñas'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'marca': marca,
        'pais': pais,
        'tipo': tipo,
        'cobertura': cobertura,
        'descripcion': descripcion,
        'imagen': imagen,
        'promedioPuntuacion': promedioPuntuacion,
        'totalReseñas': totalReseñas,
      };
}
