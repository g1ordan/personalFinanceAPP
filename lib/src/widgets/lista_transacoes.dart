import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:financas_pessoais/src/models/transacao.dart';
import 'package:financas_pessoais/src/services/transacao_service.dart';
import 'package:financas_pessoais/src/screens/adicionar_transacao_screen.dart';
import 'package:financas_pessoais/src/screens/home_screen.dart';
import 'package:intl/intl.dart';

class ListaTransacoes extends StatelessWidget {
  final TransacaoService _transacaoService = TransacaoService();

  ListaTransacoes({super.key});

  Future<bool> _confirmarExclusao(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text('Deseja realmente excluir esta transação?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Excluir',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final usuarioId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Transacao>>(
      stream: _transacaoService.getTransacoes(usuarioId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar transações'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transacoes = snapshot.data ?? [];

        if (transacoes.isEmpty) {
          return const Center(child: Text('Nenhuma transação encontrada'));
        }

        return ListView.builder(
          itemCount: transacoes.length,
          itemBuilder: (context, index) {
            final transacao = transacoes[index];
            return Dismissible(
              key: Key(transacao.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) => _confirmarExclusao(context),
              onDismissed: (direction) async {
                await _transacaoService.deletarTransacao(transacao.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transação excluída')),
                  );
                }
              },
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdicionarTransacaoScreen(
                        transacao: transacao,
                        onSave: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  );
                },
                leading: Icon(
                  transacao.valor < 0 ? Icons.remove_circle : Icons.add_circle,
                  color: transacao.valor < 0 ? Colors.red : Colors.green,
                ),
                title: Text(transacao.descricao),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(transacao.data)),
                trailing: Text(
                  'R\$ ${transacao.valor.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    color: transacao.valor < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
