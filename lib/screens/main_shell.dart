import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final favCount = shop.favoriteProducts.length;
    final cartCount = shop.cartCount;

    return Scaffold(
      body: IndexedStack(
        index: shop.tab,
        children: const [HomeScreen(), FavoritesScreen(), CartScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: NavigationBar(
          selectedIndex: shop.tab,
          onDestinationSelected: shop.setTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Asosiy',
            ),
            NavigationDestination(
              icon: _badge(favCount, Icons.favorite_border_rounded),
              selectedIcon: _badge(favCount, Icons.favorite_rounded),
              label: 'Sevimlilar',
            ),
            NavigationDestination(
              icon: _badge(cartCount, Icons.shopping_bag_outlined),
              selectedIcon: _badge(cartCount, Icons.shopping_bag_rounded),
              label: 'Savat',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(int count, IconData icon) => Badge(
        isLabelVisible: count > 0,
        backgroundColor: AppColors.accent,
        label: Text('$count'),
        child: Icon(icon),
      );
}
