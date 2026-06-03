import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'agung@example.com');
  final password = TextEditingController(text: 'password123');
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    try {
      await context.read<AuthProvider>().login(email.text.trim(), password.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 28),
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.lavender),
              child: const Icon(Icons.eco_rounded, color: AppColors.purple, size: 42),
            ),
            const SizedBox(height: 26),
            const Text('Share more,\nwaste less.', style: TextStyle(fontSize: 42, height: 1.02, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: AppColors.ink)),
            const SizedBox(height: 12),
            const Text('Ambil, pinjamkan, jual, atau bagikan makanan dan barang yang masih berguna di sekitar kamu.', style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 32),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline_rounded), hintText: 'Email')),
            const SizedBox(height: 14),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                hintText: 'Password',
                suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded), onPressed: () => setState(() => obscure = !obscure)),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: auth.loading ? null : submit,
              child: auth.loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.purple,
                side: const BorderSide(color: AppColors.purple),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Buat akun baru', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
