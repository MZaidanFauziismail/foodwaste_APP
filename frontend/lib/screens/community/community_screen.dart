import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
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
      final result = await api.get('/community');
      setState(() { data = Map<String, dynamic>.from(result); loading = false; });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Scaffold(
      appBar: AppBar(title: const Text('Community'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh_rounded)), IconButton(onPressed: widget.onOpenMenu, icon: const Icon(Icons.menu_rounded, size: 34)), const SizedBox(width: 12)]),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.purple, Color(0xFFFF6A88)]), borderRadius: BorderRadius.circular(30)),
                    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Become a Food Waste Hero', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      Text('Share what you do not need. Someone nearby might need it today.', style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: _Stat(label: 'Members', value: '${d?['total_members'] ?? 0}')),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'Available', value: '${d?['available_listings'] ?? 0}')),
                  ]),
                  const SizedBox(height: 28),
                  const Text('Recent activity', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  ...List.from(d?['recent_listings'] ?? []).map((x) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(backgroundColor: AppColors.lavender, child: Icon(Icons.eco_rounded, color: AppColors.purple)),
                    title: Text(x['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900)),
                    subtitle: Text('${x['owner_name'] ?? 'User'} • ${x['category'] ?? ''}'),
                  )),
                ],
              ),
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFFF7F5FA), borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.purple)),
      Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800)),
    ]),
  );
}
