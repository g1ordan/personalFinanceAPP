import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:financas_pessoais/src/models/transacao.dart';
import 'package:financas_pessoais/src/services/transacao_service.dart';

class ResumoCard extends StatelessWidget {
  final TransacaoService _transacaoService = TransacaoService();

  ResumoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarioId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Transacao>>(
      stream: _transacaoService.getTransacoes(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Erro ao carregar saldo');
        }

        final transacoes = snapshot.data ?? [];
        final saldo = transacoes.fold<double>(
          0,
          (total, transacao) => total + transacao.valor,
        );

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Saldo Atual',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${saldo.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: saldo >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
