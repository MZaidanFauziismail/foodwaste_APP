import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    final api = ApiClient();
    api.setToken(context.read<AuthProvider>().token);
    try {
      final result = await api.get('/impact');
      setState(() { data = Map<String, dynamic>.from(result); loading = false; });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final impact = data?['impact'] ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.menu_rounded, size: 34))]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 120),
              children: [
                Center(child: Column(children: [
                  const CircleAvatar(radius: 72, backgroundColor: AppColors.lavender, child: Icon(Icons.eco_rounded, size: 72, color: AppColors.purple)),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'EcoShare user', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  Text(user?.email ?? '', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () {}, child: const Text('Add a profile photo', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline))),
                ])),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: AppColors.peach, borderRadius: BorderRadius.circular(22)),
                  child: const Text('EcoShare users with real profile photos are more likely to be successful with requesting and giving away.', style: TextStyle(fontSize: 15, height: 1.45, fontWeight: FontWeight.w700, color: AppColors.ink)),
                ),
                const SizedBox(height: 22),
                OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: AppColors.purple, side: const BorderSide(color: AppColors.purple), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), child: const Text('View public profile', style: TextStyle(fontWeight: FontWeight.w900))),
                const SizedBox(height: 30),
                const Text('My Impact', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.ink)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _Impact(icon: Icons.diversity_3_rounded, value: '${impact['people_shared_with'] ?? 0}', label: 'People shared with'),
                    _Impact(icon: Icons.dinner_dining_rounded, value: '${impact['meals_saved'] ?? 0}', label: 'Meals saved'),
                    _Impact(icon: Icons.water_drop_rounded, value: '${impact['water_not_wasted_liters'] ?? 0}', label: 'Water not wasted (L)'),
                    _Impact(icon: Icons.workspace_premium_rounded, value: '${(data?['badges'] as List?)?.length ?? 0}', label: 'Badges'),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite_rounded), label: const Text('Share your impact now')),
              ],
            ),
    );
  }
}

class _Impact extends StatelessWidget {
  const _Impact({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF7F5FA), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: AppColors.purple),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.ink)),
      Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
    ]),
  );
}
