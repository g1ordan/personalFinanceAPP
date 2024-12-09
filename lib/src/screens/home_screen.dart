import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:financas_pessoais/src/widgets/resumo_card.dart';
import 'package:financas_pessoais/src/widgets/lista_transacoes.dart';
import 'package:financas_pessoais/src/screens/adicionar_transacao_screen.dart';
import 'package:financas_pessoais/src/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            const Text('Finanças Pessoais'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ResumoCard(),
          Expanded(
            child: ListaTransacoes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdicionarTransacaoScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
