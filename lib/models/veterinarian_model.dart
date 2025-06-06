class Veterinario {
  final String? id;
  final String nombre;
  final String especialidad;
  final String telefono;
  final String email;
  

  Veterinario({
    this.id,
    required this.nombre,
    required this.especialidad,
    required this.telefono,
    required this.email,
  });

  factory Veterinario.fromJson(Map<String, dynamic> json) {
    return Veterinario(
      id: json['id']?.toString() ?? json['_id'],
      nombre: json['nombre'],
      especialidad: json['especialidad'],
      telefono: json['telefono'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'especialidad': especialidad,
      'telefono': telefono,
      'email': email,
    };
  }
}
