import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/app_theme.dart';
import '../../models/listing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../add/add_listing_screen.dart';
import '../listing/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool loading = true;
  String filter = 'all';
  List<Listing> listings = [];

  ApiClient _api() {
    final api = ApiClient();
    api.setToken(context.read<AuthProvider>().token);
    return api;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    try {
      final data = await _api().get('/my-listings');
      setState(() {
        listings = (data['listings'] as List).map((x) => Listing.fromJson(Map<String, dynamic>.from(x))).toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  List<Listing> get filtered {
    if (filter == 'all') return listings;
    return listings.where((x) => x.type == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      _Chip(label: 'All', value: 'all', filter: filter, onTap: setFilter),
                      _Chip(label: 'Free', value: 'free', filter: filter, onTap: setFilter),
                      _Chip(label: 'Sell', value: 'sell', filter: filter, onTap: setFilter),
                      _Chip(label: 'Lend', value: 'lend', filter: filter, onTap: setFilter),
                      _Chip(label: 'Wanted', value: 'wanted', filter: filter, onTap: setFilter),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  if (data.isEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 120),
                        const EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'Oops! There’s nothing here',
                          subtitle: 'As soon as you start to add listings, they will appear here.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: openAdd, child: const Text('Add listing')),
                      ],
                    )
                  else
                    ...data.map((x) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: ListingCard(
                            compact: true,
                            listing: x,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: x.id))),
                          ),
                        )),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        onPressed: openAdd,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void setFilter(String value) => setState(() => filter = value);

  Future<void> openAdd() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddListingScreen()));
    load();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value, required this.filter, required this.onTap});
  final String label;
  final String value;
  final String filter;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => onTap(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : const Color(0xFFF0EEF3),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.ink, fontWeight: FontWeight.w900, fontSize: 17)),
        ),
      ),
    );
  }
}
