import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:financas_pessoais/src/app.dart';
import 'package:financas_pessoais/firebase_options.dart'; // Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Starting app initialization"); // Debug print

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized"); // Debug print

  runApp(const FinancasApp());
}
