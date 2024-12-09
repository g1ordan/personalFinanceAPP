import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:financas_pessoais/src/models/transacao.dart';
import 'package:financas_pessoais/src/services/transacao_service.dart';
import 'package:financas_pessoais/src/screens/home_screen.dart';

enum TipoTransacao { despesa, receita }

class AdicionarTransacaoScreen extends StatefulWidget {
  final Transacao? transacao;
  final VoidCallback? onSave;

  const AdicionarTransacaoScreen({
    super.key,
    this.transacao,
    this.onSave,
  });

  @override
  State<AdicionarTransacaoScreen> createState() =>
      _AdicionarTransacaoScreenState();
}

class _AdicionarTransacaoScreenState extends State<AdicionarTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _transacaoService = TransacaoService();
  String _categoriaSelecionada = 'Alimentação';
  TipoTransacao _tipoTransacao = TipoTransacao.despesa;
  DateTime _dataSelecionada = DateTime.now();

  final List<String> _categorias = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Educação',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      _nomeController.text = widget.transacao!.descricao;
      _valorController.text = widget.transacao!.valor.abs().toString();
      _tipoTransacao = widget.transacao!.valor < 0
          ? TipoTransacao.despesa
          : TipoTransacao.receita;
      _dataSelecionada = widget.transacao!.data;
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _salvarTransacao() async {
    if (_formKey.currentState!.validate()) {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));
      final transacao = Transacao(
        id: widget.transacao?.id ?? '',
        descricao: _nomeController.text,
        valor: _tipoTransacao == TipoTransacao.despesa ? -valor : valor,
        data: _dataSelecionada,
        usuarioId: FirebaseAuth.instance.currentUser!.uid,
      );

      if (widget.transacao != null) {
        await _transacaoService.atualizarTransacao(transacao.id, transacao);
      } else {
        await _transacaoService.adicionarTransacao(transacao);
      }

      if (mounted) {
        widget.onSave?.call();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deletarTransacao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await _transacaoService.deletarTransacao(widget.transacao!.id);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.transacao == null ? 'Nova Transação' : 'Menu Transação'),
        actions: widget.transacao != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deletarTransacao,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SegmentedButton<TipoTransacao>(
                segments: const [
                  ButtonSegment(
                    value: TipoTransacao.despesa,
                    label: Text('Despesa'),
                  ),
                  ButtonSegment(
                    value: TipoTransacao.receita,
                    label: Text('Receita'),
                  ),
                ],
                selected: {_tipoTransacao},
                onSelectionChanged: (Set<TipoTransacao> newSelection) {
                  setState(() {
                    _tipoTransacao = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Por favor, insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categoriaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _categoriaSelecionada = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _selecionarData,
                child: Text(
                  'Data: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _salvarTransacao,
                child: Text(widget.transacao == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
