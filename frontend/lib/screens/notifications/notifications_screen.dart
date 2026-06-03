import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  List<dynamic> items = [];

  ApiClient _api() {
    final api = ApiClient();
    api.setToken(context.read<AuthProvider>().token);
    return api;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load(markRead: true));
  }

  Future<void> load({bool markRead = false}) async {
    try {
      final data = await _api().get('/notifications');
      if (!mounted) return;
      setState(() {
        items = data['notifications'] ?? [];
        loading = false;
      });
      if (markRead) await _api().patch('/notifications/read');
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [IconButton(onPressed: () => load(markRead: true), icon: const Icon(Icons.refresh_rounded))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications yet.',
                  subtitle: 'Requests and chat updates will appear here.',
                )
              : RefreshIndicator(
                  onRefresh: () => load(markRead: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = Map<String, dynamic>.from(items[i]);
                      final unread = n['is_read'] == false;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: unread ? AppColors.lavender : const Color(0xFFF8F7FA),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: unread ? AppColors.purple.withOpacity(.18) : Colors.transparent),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: unread ? AppColors.purple : Colors.white,
                              child: Icon(_icon(n['type']), color: unread ? Colors.white : AppColors.purple),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n['title'] ?? 'Notification', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.ink)),
                                  const SizedBox(height: 5),
                                  Text(n['body'] ?? '', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, height: 1.35)),
                                  if (n['listing_title'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text(n['listing_title'], style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _icon(dynamic type) {
    switch (type) {
      case 'request':
        return Icons.volunteer_activism_rounded;
      case 'message':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }
}
