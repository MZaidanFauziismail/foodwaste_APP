import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool loading = true;
  List<dynamic> conversations = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      timer = Timer.periodic(const Duration(seconds: 5), (_) => load(silent: true));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> load({bool silent = false}) async {
    final api = ApiClient();
    api.setToken(context.read<AuthProvider>().token);
    try {
      final data = await api.get('/messages/conversations');
      if (!mounted) return;
      setState(() {
        conversations = data['conversations'] ?? [];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      if (!silent) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.tune_rounded)),
          IconButton(onPressed: widget.onOpenMenu, icon: const Icon(Icons.menu_rounded, size: 34)),
          const SizedBox(width: 12),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : conversations.isEmpty
              ? const EmptyState(icon: Icons.mail_outline_rounded, title: 'No messages to show.', subtitle: 'Request a listing from another account to start a real chat.')
              : RefreshIndicator(
                  onRefresh: load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
                    itemCount: conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final c = conversations[i] as Map<String, dynamic>;
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        tileColor: const Color(0xFFF7F5FA),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.lavender,
                          child: Text((c['other_user_name'] ?? '?').toString().substring(0, 1).toUpperCase(), style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900)),
                        ),
                        title: Text(c['other_user_name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('${c['listing_title'] ?? 'Listing'} • ${c['last_message'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(listingId: c['listing_id'], otherUserId: c['other_user_id'], title: c['other_user_name'] ?? 'Chat')));
                          load(silent: true);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
