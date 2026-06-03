import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing, required this.onTap, this.compact = false});

  final Listing listing;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tagColor = listing.type == 'lend' ? const Color(0xFFFFEEF5) : AppColors.mint;
    final tagText = listing.type == 'lend' ? const Color(0xFFD93E75) : const Color(0xFF19764C);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: compact ? _Horizontal(listing: listing, tagColor: tagColor, tagText: tagText) : _Vertical(listing: listing, tagColor: tagColor, tagText: tagText),
      ),
    );
  }
}

class _Vertical extends StatelessWidget {
  const _Vertical({required this.listing, required this.tagColor, required this.tagText});
  final Listing listing;
  final Color tagColor;
  final Color tagText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(aspectRatio: 1.35, child: _Image(url: listing.imageUrl, category: listing.category)),
            Positioned(top: 10, left: 10, child: _Tag(text: listing.typeLabel, color: tagColor, textColor: tagText)),
            if (listing.distanceKm != null) Positioned(bottom: 10, right: 10, child: _Distance(km: listing.distanceKm!)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.ink)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Avatar(name: listing.ownerName ?? '?'),
                  const SizedBox(width: 8),
                  Expanded(child: Text(listing.ownerName ?? 'EcoShare user', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Horizontal extends StatelessWidget {
  const _Horizontal({required this.listing, required this.tagColor, required this.tagText});
  final Listing listing;
  final Color tagColor;
  final Color tagText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 132, height: 118, child: _Image(url: listing.imageUrl, category: listing.category)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tag(text: listing.typeLabel, color: tagColor, textColor: tagText),
                const SizedBox(height: 8),
                Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ink)),
                const SizedBox(height: 7),
                Row(children: [
                  _Avatar(name: listing.ownerName ?? '?'),
                  const SizedBox(width: 8),
                  Expanded(child: Text(listing.ownerName ?? 'EcoShare user', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
                ]),
                if (listing.distanceKm != null) ...[
                  const SizedBox(height: 6),
                  Text('${listing.distanceKm!.toStringAsFixed(1)} km', style: const TextStyle(color: AppColors.purple, fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.url, required this.category});
  final String? url;
  final String category;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: category == 'food' ? AppColors.mint : AppColors.lavender,
        child: Icon(category == 'food' ? Icons.restaurant_rounded : Icons.inventory_2_rounded, size: 42, color: AppColors.purple),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(color: AppColors.lavender, child: const Center(child: CircularProgressIndicator(strokeWidth: 2)));
      },
      errorBuilder: (_, __, ___) => Container(color: AppColors.lavender, child: const Icon(Icons.broken_image_rounded, color: AppColors.purple)),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color, required this.textColor});
  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}

class _Distance extends StatelessWidget {
  const _Distance({required this.km});
  final double km;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.purple),
        Text('${km.toStringAsFixed(1)}km', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted)),
      ]),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: AppColors.pink,
      child: Text(name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.purple)),
    );
  }
}
