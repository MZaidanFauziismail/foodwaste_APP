import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../listing/listing_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.onOpenMenu});

  final VoidCallback? onOpenMenu;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final search = TextEditingController();
  bool mapMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => doSearch());
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> doSearch() async {
    final provider = context.read<ListingProvider>();
    final user = context.read<AuthProvider>().user;
    provider.query = search.text.trim();
    await provider.fetch(lat: user?.latitude, lng: user?.longitude, radius: 50);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 168,
        titleSpacing: 28,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Search', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 18),
          TextField(
            controller: search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => doSearch(),
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search_rounded), hintText: 'What are you looking for?', suffixIcon: IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {})),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _TabButton(text: 'List', selected: !mapMode, onTap: () => setState(() => mapMode = false))),
            Expanded(child: _TabButton(text: 'Map', selected: mapMode, onTap: () => setState(() => mapMode = true))),
          ]),
        ]),
        actions: [IconButton(onPressed: widget.onOpenMenu, icon: const Icon(Icons.menu_rounded, size: 34)), const SizedBox(width: 12)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
            child: Row(children: [
              _Filter(label: 'Type (${provider.listings.length})', onTap: _openType),
              const SizedBox(width: 12),
              _Filter(label: 'Sort by', onTap: doSearch),
            ]),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : mapMode
                    ? _MapView(listings: provider.listings)
                    : provider.listings.isEmpty
                        ? const EmptyState(icon: Icons.search_rounded, title: 'There is nothing to show right now', subtitle: 'Try increasing your location range')
                        : RefreshIndicator(
                            onRefresh: doSearch,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(28, 8, 28, 120),
                              itemBuilder: (context, i) => ListingCard(compact: true, listing: provider.listings[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: provider.listings[i].id)))),
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemCount: provider.listings.length,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _openType() async {
    final provider = context.read<ListingProvider>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _TypeTile(value: 'all', title: 'All', subtitle: 'Everything around you'),
          _TypeTile(value: 'free', title: 'Free', subtitle: 'Give away free food/non-food'),
          _TypeTile(value: 'sell', title: 'Sell', subtitle: 'Sell non-food items'),
          _TypeTile(value: 'lend', title: 'Lend', subtitle: 'Lend your things locally'),
          _TypeTile(value: 'wanted', title: 'Wanted', subtitle: 'Ask for something'),
          _TypeTile(value: 'forum', title: 'Forum', subtitle: 'Share relevant topics'),
        ]),
      ),
    );
    if (selected != null) {
      provider.type = selected;
      doSearch();
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(children: [
      Text(text, style: const TextStyle(fontSize: 20, color: AppColors.ink, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      AnimatedContainer(duration: const Duration(milliseconds: 180), height: 5, width: 120, decoration: BoxDecoration(color: selected ? AppColors.purple : Colors.transparent, borderRadius: BorderRadius.circular(999))),
    ]),
  );
}

class _Filter extends StatelessWidget {
  const _Filter({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ActionChip(label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)), avatar: const Icon(Icons.keyboard_arrow_down_rounded), onPressed: onTap, backgroundColor: const Color(0xFFF7F5FA), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide.none));
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.value, required this.title, required this.subtitle});
  final String value;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
    leading: CircleAvatar(backgroundColor: AppColors.lavender, child: Icon(value == 'sell' ? Icons.local_offer_rounded : value == 'lend' ? Icons.handshake_rounded : value == 'wanted' ? Icons.campaign_rounded : Icons.eco_rounded, color: AppColors.purple)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    subtitle: Text(subtitle),
    onTap: () => Navigator.pop(context, value),
  );
}

class _MapView extends StatelessWidget {
  const _MapView({required this.listings});
  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    final geoListings = listings.where((x) => x.latitude != null && x.longitude != null).toList();
    final first = geoListings.isEmpty ? null : geoListings.first;
    final center = first == null ? const LatLng(-6.2, 106.8) : LatLng(first.latitude!, first.longitude!);
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 10),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.ecoshare.app'),
        MarkerLayer(
          markers: listings.where((x) => x.latitude != null && x.longitude != null).map((x) => Marker(
            point: LatLng(x.latitude!, x.longitude!),
            width: 54,
            height: 54,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: x.id))),
              child: Container(decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white), child: const Icon(Icons.home_rounded, color: AppColors.purple, size: 34)),
            ),
          )).toList(),
        ),
      ],
    );
  }
}

