import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'admin_shell.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _password = TextEditingController();
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final shop = context.read<ShopState>();
    if (!shop.adminLogin(_password.text)) {
      setState(() => _error = "Parol noto'g'ri. Qaytadan urinib ko'ring.");
      return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminShell()));
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = context.watch<ShopState>().settings.adminPassword == 'admin123';
    return Scaffold(
      appBar: AppBar(title: const Text('Admin panel')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Panel(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Do'kon boshqaruvi", textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'Buyurtmalar, mahsulotlar, mijozlar va promokodlarni boshqarish uchun admin parolini kiriting.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.45),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: _hidden,
                  autofocus: true,
                  onSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Parol',
                    errorText: _error,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: _hidden ? "Parolni ko'rsatish" : 'Parolni yashirish',
                      icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _hidden = !_hidden),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Kirish', onPressed: _login),
                if (isDefault) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                    child: const Text(
                      "Standart parol: admin123. Kirgandan keyin uni Sozlamalar bo'limida o'zgartiring.",
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
