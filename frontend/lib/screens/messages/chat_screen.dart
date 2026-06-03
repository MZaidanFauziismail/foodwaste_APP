import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.listingId, required this.otherUserId, required this.title});
  final int listingId;
  final int otherUserId;
  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scroll = ScrollController();
  List<dynamic> messages = [];
  bool loading = true;
  bool sending = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      load();
      timer = Timer.periodic(const Duration(seconds: 3), (_) => load(silent: true));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    scroll.dispose();
    super.dispose();
  }

  ApiClient _api() {
    final api = ApiClient();
    api.setToken(context.read<AuthProvider>().token);
    return api;
  }

  Future<void> load({bool silent = false}) async {
    try {
      final data = await _api().get('/messages/${widget.listingId}/${widget.otherUserId}');
      if (!mounted) return;
      final next = data['messages'] ?? [];
      final changed = next.length != messages.length;
      setState(() {
        messages = next;
        loading = false;
      });
      if (changed) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (scroll.hasClients) scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> send() async {
    final body = controller.text.trim();
    if (body.isEmpty || sending) return;
    controller.clear();
    setState(() => sending = true);
    try {
      await _api().post('/messages/${widget.listingId}/${widget.otherUserId}', body: {'body': body});
      await load();
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.watch<AuthProvider>().user?.id;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const Text('Online chat • auto refresh', style: TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: Column(children: [
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
                  ? const Center(child: Text('Belum ada pesan.'))
                  : ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      itemCount: messages.length,
                      itemBuilder: (context, i) {
                        final m = messages[i] as Map<String, dynamic>;
                        final mine = m['sender_id'] == myId;
                        return Align(
                          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
                            decoration: BoxDecoration(
                              color: mine ? AppColors.purple : const Color(0xFFF2F0F5),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: Radius.circular(mine ? 20 : 4),
                                bottomRight: Radius.circular(mine ? 4 : 20),
                              ),
                            ),
                            child: Text(m['body'] ?? '', style: TextStyle(color: mine ? Colors.white : AppColors.ink, height: 1.35, fontWeight: FontWeight.w700)),
                          ),
                        );
                      },
                    ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(children: [
              Expanded(child: TextField(controller: controller, minLines: 1, maxLines: 4, textInputAction: TextInputAction.send, onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'Tulis pesan...'))),
              const SizedBox(width: 10),
              FloatingActionButton.small(onPressed: sending ? null : send, backgroundColor: AppColors.purple, foregroundColor: Colors.white, child: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.arrow_forward_rounded)),
            ]),
          ),
        ),
      ]),
    );
  }
}
