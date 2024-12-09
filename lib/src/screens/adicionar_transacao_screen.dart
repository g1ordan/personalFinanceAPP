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
  bool _isLoading = false;

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
      setState(() => _dataSelecionada = data);
    }
  }

  bool _validarCampos() {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um nome para a transação'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    try {
      final valor = double.parse(_valorController.text.replaceAll(',', '.'));
      if (valor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O valor deve ser maior que zero'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<bool> _mostrarConfirmacao(String acao) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Confirmar $acao'),
            content: Text('Deseja realmente $acao esta transação?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(acao, style: const TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) return;

    final acao = widget.transacao != null ? 'atualizar' : 'adicionar';
    final confirmado = await _mostrarConfirmacao(acao);

    if (confirmado) {
      setState(() => _isLoading = true);

      // Navigate immediately after confirmation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      try {
        final valor = double.parse(_valorController.text.replaceAll(',', '.'));
        final transacao = Transacao(
          id: widget.transacao?.id ?? '',
          descricao: _nomeController.text.trim(),
          valor: _tipoTransacao == TipoTransacao.despesa ? -valor : valor,
          data: _dataSelecionada,
          usuarioId: FirebaseAuth.instance.currentUser!.uid,
        );

        if (widget.transacao != null) {
          await _transacaoService.atualizarTransacao(transacao.id, transacao);
        } else {
          await _transacaoService.adicionarTransacao(transacao);
        }

        setState(() => _isLoading = false);
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deletarTransacao() async {
    final confirmado = await _mostrarConfirmacao('excluir');

    if (confirmado) {
      setState(() => _isLoading = true);

      // Navigate immediately after confirmation
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      try {
        await _transacaoService.deletarTransacao(widget.transacao!.id);
        setState(() => _isLoading = false);
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.transacao == null ? 'Nova Transação' : 'Editar Transação'),
        actions: widget.transacao != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _isLoading ? null : _deletarTransacao,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                        setState(() => _tipoTransacao = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Digite um nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        border: OutlineInputBorder(),
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Digite um valor';
                        if (double.tryParse(value!.replaceAll(',', '.')) ==
                            null) {
                          return 'Valor inválido';
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
                      items: _categorias.map((categoria) {
                        return DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _categoriaSelecionada = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _selecionarData,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        'Data: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _salvarTransacao,
                      child: Text(
                        widget.transacao == null ? 'Adicionar' : 'Atualizar',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}
