import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    try {
      await context.read<AuthProvider>().register(name.text.trim(), email.text.trim(), password.text);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Join the local sharing loop.', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 24),
          TextField(controller: name, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded), hintText: 'Nama')),
          const SizedBox(height: 14),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Email')),
          const SizedBox(height: 14),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded), hintText: 'Password minimal 6 karakter')),
          const SizedBox(height: 22),
          ElevatedButton(onPressed: loading ? null : submit, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register')),
        ],
      ),
    );
  }
}
