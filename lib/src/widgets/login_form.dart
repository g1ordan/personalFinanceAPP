import 'package:flutter/material.dart';

class LoginFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController senhaController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onLogin;

  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.senhaController,
    required this.formKey,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Digite seu email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: senhaController,
            decoration: const InputDecoration(
              labelText: 'Senha',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Digite sua senha' : null,
          ),
        ],
      ),
    );
  }
}
