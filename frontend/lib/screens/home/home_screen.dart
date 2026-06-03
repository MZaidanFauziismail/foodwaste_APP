import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/location_service.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/pill.dart';
import '../listing/listing_detail_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refresh());
  }

  Future<void> refresh() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ListingProvider>();
    final loc = await LocationService().current();
    if (loc != null) {
      await auth.updateLocation(loc.latitude, loc.longitude);
      await provider.fetch(lat: loc.latitude, lng: loc.longitude, radius: auth.user?.radiusKm ?? 50);
    } else {
      await provider.fetch(radius: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ListingProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 96,
        titleSpacing: 28,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Listings within ${auth.user?.radiusKm ?? 5}km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.muted)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.near_me_rounded, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(child: Text(auth.user?.latitude == null ? 'Jalan Jalur Sutera Barat' : 'Near your location', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.ink))),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ]),
          ],
        ),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none_rounded, size: 30)),
          IconButton(onPressed: widget.onOpenMenu, icon: const Icon(Icons.menu_rounded, size: 34)),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 110),
          children: [
            Row(
              children: [
                Pill(label: 'All', selected: provider.category == 'all', onTap: () { provider.category = 'all'; refresh(); }),
                const SizedBox(width: 10),
                Pill(label: 'Food', selected: provider.category == 'food', onTap: () { provider.category = 'food'; refresh(); }),
                const SizedBox(width: 10),
                Pill(label: 'Non-food', selected: provider.category == 'non_food', onTap: () { provider.category = 'non_food'; refresh(); }),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Get started', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.ink)),
            const SizedBox(height: 14),
            SizedBox(
              height: 154,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _StartCard(emoji: '🍊🖼️📚', text: 'See something\nyou like?'),
                  SizedBox(width: 14),
                  _StartCard(emoji: '👀', text: 'Wait… I can give\nthat away?'),
                  SizedBox(width: 14),
                  _StartCard(emoji: '✨', text: 'Share one thing\ntoday'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _BadgeBanner(title: provider.category == 'food' ? 'Unlock your “Olio Supporter” badge now' : 'Unlock your “First request” badge now'),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(child: Text(provider.category == 'food' ? 'Food' : provider.category == 'non_food' ? 'Non-food' : 'Nearby picks', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.ink))),
                TextButton(onPressed: refresh, child: const Text('All ›', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink))),
              ],
            ),
            if (provider.loading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator()))
            else if (provider.listings.isEmpty) const SizedBox(height: 260, child: EmptyState(icon: Icons.search_rounded, title: 'There is nothing to show right now', subtitle: 'Try increasing your location range or sharing the first item around you.'))
            else _ListingGrid(listings: provider.listings),
            const SizedBox(height: 24),
            const _CategoryShortcuts(),
          ],
        ),
      ),
    );
  }
}

class _ListingGrid extends StatelessWidget {
  const _ListingGrid({required this.listings});
  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listings.length > 4 ? 4 : listings.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .75),
      itemBuilder: (context, i) => ListingCard(
        listing: listings[i],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: listings[i].id))),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFA850), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 21)),
          const Spacer(),
          Text(text, style: const TextStyle(fontSize: 20, height: 1.05, fontWeight: FontWeight.w900, color: AppColors.ink)),
        ],
      ),
    );
  }
}

class _BadgeBanner extends StatelessWidget {
  const _BadgeBanner({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 8))]),
      child: Row(children: [
        Container(width: 58, height: 58, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.peach), child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF6A48))),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.ink))),
        const Icon(Icons.close_rounded, color: AppColors.purple),
      ]),
    );
  }
}

class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: const [
        _Shortcut(text: 'Free food', color: AppColors.mint, icon: Icons.restaurant_rounded),
        _Shortcut(text: 'Free non-food', color: AppColors.lavender, icon: Icons.inventory_2_rounded),
        _Shortcut(text: 'For sale', color: AppColors.pink, icon: Icons.local_offer_rounded),
        _Shortcut(text: 'Borrow', color: AppColors.peach, icon: Icons.handshake_rounded),
        _Shortcut(text: 'Wanted', color: AppColors.yellow, icon: Icons.campaign_rounded),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.text, required this.color, required this.icon});
  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 70) / 2,
      height: 76,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: AppColors.purple.withOpacity(.20)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink)),
      ]),
    );
  }
}
