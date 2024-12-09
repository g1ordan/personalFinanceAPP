import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financas_pessoais/src/models/transacao.dart';

class TransacaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarTransacao(Transacao transacao) async {
    await _firestore.collection('transacoes').add(transacao.toMap());
  }

  Future<void> atualizarTransacao(String id, Transacao transacao) async {
    await _firestore.collection('transacoes').doc(id).update(transacao.toMap());
  }

  Future<void> deletarTransacao(String id) async {
    await _firestore.collection('transacoes').doc(id).delete();
  }

  Stream<List<Transacao>> getTransacoes(String usuarioId) {
    return _firestore
        .collection('transacoes')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transacao.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }
}
