import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../core/location_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController(text: 'Jalan Jalur Sutera Barat');
  final lat = TextEditingController(text: '-6.2219000');
  final lng = TextEditingController(text: '106.6479000');
  final price = TextEditingController();
  final imageUrl = TextEditingController();
  String type = 'free';
  String category = 'food';
  bool saving = false;
  Map<String, dynamic>? ml;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => useCurrentLocation());
  }

  Future<void> useCurrentLocation() async {
    final loc = await LocationService().current();
    if (!mounted || loc == null) return;
    setState(() {
      lat.text = loc.latitude.toStringAsFixed(7);
      lng.text = loc.longitude.toStringAsFixed(7);
      location.text = loc.isFallback ? 'Jalan Jalur Sutera Barat' : 'Near your location';
    });
    await context.read<AuthProvider>().updateLocation(loc.latitude, loc.longitude);
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    location.dispose();
    lat.dispose();
    lng.dispose();
    price.dispose();
    imageUrl.dispose();
    super.dispose();
  }

  Future<void> aiCheck() async {
    try {
      final result = await context.read<ListingProvider>().predict(title.text, description.text, category, type);
      setState(() => ml = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> submit() async {
    if (title.text.trim().isEmpty || location.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul dan lokasi wajib diisi.')));
      return;
    }
    setState(() => saving = true);
    try {
      await context.read<ListingProvider>().create(
        title: title.text.trim(),
        description: description.text.trim(),
        type: type,
        category: category,
        locationText: location.text.trim(),
        latitude: lat.text.trim(),
        longitude: lng.text.trim(),
        price: price.text.trim(),
        imageUrl: imageUrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing berhasil dibuat.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  bool get _hasPreview => imageUrl.text.trim().startsWith('http://') || imageUrl.text.trim().startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Add')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
        children: [
          const Text('What can I add?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 18),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _Choice(label: 'Free', selected: type == 'free', icon: Icons.eco_rounded, onTap: () => setState(() => type = 'free')),
            _Choice(label: 'Sell', selected: type == 'sell', icon: Icons.local_offer_rounded, onTap: () => setState(() => type = 'sell')),
            _Choice(label: 'Lend', selected: type == 'lend', icon: Icons.handshake_rounded, onTap: () => setState(() => type = 'lend')),
            _Choice(label: 'Wanted', selected: type == 'wanted', icon: Icons.campaign_rounded, onTap: () => setState(() => type = 'wanted')),
            _Choice(label: 'Forum', selected: type == 'forum', icon: Icons.forum_rounded, onTap: () => setState(() => type = 'forum')),
          ]),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _BigToggle(text: 'Food', selected: category == 'food', onTap: () => setState(() => category = 'food'))),
            const SizedBox(width: 12),
            Expanded(child: _BigToggle(text: 'Non-food', selected: category == 'non_food', onTap: () => setState(() => category = 'non_food'))),
          ]),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 170,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.purple.withOpacity(.15)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _hasPreview
                ? Image.network(
                    imageUrl.text.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImagePlaceholder(text: 'Image URL tidak bisa dimuat'),
                  )
                : const _ImagePlaceholder(text: 'Optional image URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: imageUrl,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.image_rounded), hintText: 'Image URL opsional, contoh https://...jpg'),
          ),
          const SizedBox(height: 16),
          TextField(controller: title, decoration: const InputDecoration(hintText: 'Title, e.g. Roti tawar sealed')),
          const SizedBox(height: 12),
          TextField(controller: description, minLines: 3, maxLines: 5, decoration: const InputDecoration(hintText: 'Description, condition, pickup rules...')),
          if (type == 'sell') ...[
            const SizedBox(height: 12),
            TextField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Price')),
          ],
          const SizedBox(height: 12),
          TextField(controller: location, decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined), hintText: 'Location text')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: lat, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Latitude'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: lng, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Longitude'))),
          ]),
          if (user?.latitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: useCurrentLocation,
                icon: const Icon(Icons.my_location_rounded),
                label: const Text('Use my current location'),
              ),
            ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              side: const BorderSide(color: AppColors.purple),
              foregroundColor: AppColors.purple,
            ),
            onPressed: aiCheck,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('AI check listing', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
          if (ml != null) _MlPreview(ml: ml!),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(onPressed: saving ? null : submit, child: saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Publish listing')),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded, size: 42, color: AppColors.purple.withOpacity(.85)),
          const SizedBox(height: 8),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.purple)),
        ],
      );
}

class _Choice extends StatelessWidget {
  const _Choice({required this.label, required this.selected, required this.icon, required this.onTap});
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: selected ? Colors.white : AppColors.ink)),
        avatar: Icon(icon, color: selected ? Colors.white : AppColors.purple, size: 18),
        selectedColor: AppColors.purple,
        backgroundColor: const Color(0xFFF7F5FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide.none),
      );
}

class _BigToggle extends StatelessWidget {
  const _BigToggle({required this.text, required this.selected, required this.onTap});
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: selected ? AppColors.purple : AppColors.lavender, borderRadius: BorderRadius.circular(22)),
          child: Center(child: Text(text, style: TextStyle(color: selected ? Colors.white : AppColors.purple, fontSize: 18, fontWeight: FontWeight.w900))),
        ),
      );
}

class _MlPreview extends StatelessWidget {
  const _MlPreview({required this.ml});
  final Map<String, dynamic> ml;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AI result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink)),
          const SizedBox(height: 8),
          Text('Predicted: ${ml['predicted_category'] ?? '-'}'),
          Text('Safety: ${ml['safety_score'] ?? '-'} • Freshness: ${ml['freshness_score'] ?? '-'}'),
          Text('Impact: ${ml['impact_meals'] ?? 0} meals • ${ml['impact_water_liters'] ?? 0}L water saved'),
          if (ml['notes'] is List)
            ...List.from(ml['notes']).map((x) => Padding(padding: const EdgeInsets.only(top: 6), child: Text('• $x', style: const TextStyle(color: AppColors.muted)))),
        ]),
      );
}
