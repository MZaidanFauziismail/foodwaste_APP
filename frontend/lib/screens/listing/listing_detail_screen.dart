import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/listing.dart';
import '../../providers/listing_provider.dart';
import '../messages/chat_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final int listingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Listing? listing;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final provider = context.read<ListingProvider>();
    final matches = provider.listings.where((x) => x.id == widget.listingId);
    final cached = matches.isEmpty ? null : matches.first;
    if (cached != null) {
      setState(() { listing = cached; loading = false; });
      return;
    }
    try {
      final item = await provider.detail(widget.listingId);
      setState(() { listing = item; loading = false; });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  Future<void> request() async {
    final item = listing;
    if (item == null) return;
    final controller = TextEditingController(text: 'Hi, aku tertarik sama ${item.title}. Masih available?');
    final msg = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 22, right: 22, top: 22, bottom: MediaQuery.viewInsetsOf(context).bottom + 22),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Send request', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(controller: controller, minLines: 3, maxLines: 5, decoration: const InputDecoration(hintText: 'Tulis pesan request...')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Request now')),
        ]),
      ),
    );
    if (msg == null || msg.trim().isEmpty) return;
    try {
      await context.read<ListingProvider>().requestListing(item, msg);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request terkirim. Chat sudah dibuat.')));
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(listingId: item.id, otherUserId: item.userId, title: item.ownerName ?? 'Owner')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = listing;
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : item == null
              ? const Center(child: Text('Listing tidak ditemukan.'))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 330,
                      pinned: true,
                      backgroundColor: Colors.white,
                      flexibleSpace: FlexibleSpaceBar(background: _HeroImage(item: item)),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            _Tag(text: item.typeLabel),
                            const SizedBox(width: 8),
                            _Tag(text: item.categoryLabel, light: true),
                            const Spacer(),
                            if (item.distanceKm != null) Text('${item.distanceKm!.toStringAsFixed(1)} km', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900)),
                          ]),
                          const SizedBox(height: 16),
                          Text(item.title, style: const TextStyle(fontSize: 32, height: 1.05, fontWeight: FontWeight.w900, color: AppColors.ink)),
                          const SizedBox(height: 10),
                          Text('by ${item.ownerName ?? 'EcoShare user'} • ${item.locationText}', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 24),
                          Text(item.description ?? 'Tidak ada deskripsi.', style: const TextStyle(fontSize: 16, height: 1.55, color: AppColors.ink)),
                          const SizedBox(height: 22),
                          _AiBox(item: item),
                        ]),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: item == null ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: ElevatedButton.icon(
            onPressed: item.isMine ? null : request,
            icon: const Icon(Icons.send_rounded),
            label: Text(item.isMine ? 'Ini listing kamu' : 'Request / Chat owner'),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.item});
  final Listing item;

  @override
  Widget build(BuildContext context) {
    if (item.imageUrl == null) {
      return Container(color: item.category == 'food' ? AppColors.mint : AppColors.lavender, child: Icon(item.category == 'food' ? Icons.restaurant_rounded : Icons.inventory_2_rounded, size: 90, color: AppColors.purple));
    }
    return Image.network(
      item.imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_rounded, size: 54, color: AppColors.purple)),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.light = false});
  final String text;
  final bool light;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: light ? AppColors.lavender : AppColors.purple, borderRadius: BorderRadius.circular(999)),
    child: Text(text, style: TextStyle(color: light ? AppColors.purple : Colors.white, fontWeight: FontWeight.w900)),
  );
}

class _AiBox extends StatelessWidget {
  const _AiBox({required this.item});
  final Listing item;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.auto_awesome_rounded, color: AppColors.purple), SizedBox(width: 8), Text('AI listing check', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.ink))]),
      const SizedBox(height: 12),
      Text('Kategori: ${item.predictedCategory ?? item.categoryLabel}', style: const TextStyle(fontWeight: FontWeight.w800)),
      if (item.category == 'food') Text('Safety ${item.safetyScore?.toStringAsFixed(0) ?? '-'} • Freshness ${item.freshnessScore?.toStringAsFixed(0) ?? '-'} • ${item.impactMeals.toStringAsFixed(0)} meals saved', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
      if (item.aiNotes != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(item.aiNotes!, style: const TextStyle(color: AppColors.muted))),
    ]),
  );
}

