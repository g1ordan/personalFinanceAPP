class Transacao {
  final String id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String usuarioId;

  Transacao({
    this.id = '',
    required this.descricao,
    required this.valor,
    required this.data,
    required this.usuarioId,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'valor': valor,
      'data': data.toIso8601String(),
      'usuarioId': usuarioId,
    };
  }

  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'] ?? '',
      descricao: map['descricao'] ?? '',
      valor: map['valor']?.toDouble() ?? 0.0,
      data: DateTime.parse(map['data']),
      usuarioId: map['usuarioId'] ?? '',
    );
  }
}
