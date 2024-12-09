import 'package:flutter/material.dart';
import 'package:financas_pessoais/src/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print("SplashScreen initialized"); // Debug print
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        print("Navigating to LoginScreen"); // Debug print
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      print("Navigation error: $e"); // Debug print
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building SplashScreen"); // Debug print
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Finanças Pessoais',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
