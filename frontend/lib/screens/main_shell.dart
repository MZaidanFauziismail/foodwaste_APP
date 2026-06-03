import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'add/add_listing_screen.dart';
import 'community/community_screen.dart';
import 'home/home_screen.dart';
import 'messages/messages_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final shellKey = GlobalKey<ScaffoldState>();
  int index = 0;

  Future<void> openAdd() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddListingScreen()));
  }

  void openDrawer() => shellKey.currentState?.openDrawer();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final pages = [
      HomeScreen(onOpenMenu: openDrawer),
      SearchScreen(onOpenMenu: openDrawer),
      CommunityScreen(onOpenMenu: openDrawer),
      MessagesScreen(onOpenMenu: openDrawer),
    ];

    return Scaffold(
      key: shellKey,
      drawer: const _AppDrawer(),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: BottomAppBar(
        elevation: 12,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home', selected: index == 0, onTap: () => setState(() => index = 0)),
              _NavItem(icon: Icons.search_rounded, selectedIcon: Icons.search_rounded, label: 'Search', selected: index == 1, onTap: () => setState(() => index = 1)),
              const SizedBox(width: 56),
              _NavItem(icon: Icons.forum_outlined, selectedIcon: Icons.forum_rounded, label: 'Community', selected: index == 2, onTap: () => setState(() => index = 2)),
              _NavItem(icon: Icons.send_outlined, selectedIcon: Icons.send_rounded, label: 'Messages', selected: index == 3, onTap: () => setState(() => index = 3)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: keyboardOpen
          ? null
          : SizedBox(
              width: 78,
              height: 78,
              child: FloatingActionButton(
                elevation: 0,
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                onPressed: openAdd,
                child: const Icon(Icons.add_rounded, size: 36),
              ),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.selectedIcon, required this.label, required this.selected, required this.onTap});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: selected ? AppColors.purple : AppColors.ink, size: 28),
            const SizedBox(height: 3),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? AppColors.purple : AppColors.ink, fontSize: 11, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.76,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(32))),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 36, backgroundColor: AppColors.lavender, child: Icon(Icons.eco_rounded, color: AppColors.purple, size: 36)),
                const SizedBox(width: 14),
                Expanded(child: Text(user?.name ?? 'EcoShare user', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.favorite_rounded), label: const Text('Become a Supporter')),
            const Divider(height: 34),
            _DrawerTile(icon: Icons.home_outlined, label: 'Home', onTap: () => Navigator.pop(context)),
            _DrawerTile(icon: Icons.star_border_rounded, label: 'My Watchlist', onTap: () => _snack(context, 'Watchlist siap dikembangkan untuk versi berikutnya.')),
            _DrawerTile(icon: Icons.list_alt_rounded, label: 'My Listings', onTap: () => _push(context, const MyListingsScreen())),
            _DrawerTile(icon: Icons.public_rounded, label: 'My Impact', onTap: () => _push(context, const ProfileScreen())),
            _DrawerTile(icon: Icons.badge_outlined, label: 'My Badges', onTap: () => _push(context, const ProfileScreen())),
            _DrawerTile(icon: Icons.flag_outlined, label: 'Goals', onTap: () => _snack(context, 'Goals akan aktif setelah kamu menyelesaikan request pertama.')),
            const Divider(height: 34),
            _DrawerTile(icon: Icons.person_outline_rounded, label: 'My Profile', onTap: () => _push(context, const ProfileScreen())),
            _DrawerTile(icon: Icons.logout_rounded, label: 'Logout', onTap: () { Navigator.pop(context); auth.logout(); }),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _snack(BuildContext context, String text) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
