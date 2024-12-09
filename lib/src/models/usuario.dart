class Usuario {
  final String id;
  final String email;
  final String nome;

  Usuario({
    required this.id,
    required this.email,
    required this.nome,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      email: map['email'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'nome': nome,
    };
  }
}
