import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import 'admin_dashboard.dart';
import 'admin_orders.dart';
import 'admin_products.dart';
import 'admin_settings.dart';
import 'admin_users.dart';
import 'product_editor.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _tab = 0;

  static const _titles = ['Boshqaruv paneli', 'Buyurtmalar', 'Mahsulotlar', 'Mijozlar', 'Sozlamalar'];

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final newOrders = shop.newOrdersCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          IconButton(
            tooltip: 'Admin paneldan chiqish',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              shop.adminLogout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          AdminDashboard(onOpenTab: (i) => setState(() => _tab = i)),
          const AdminOrders(),
          const AdminProducts(),
          const AdminUsers(),
          const AdminSettings(),
        ],
      ),
      floatingActionButton: _tab == 2
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductEditor())),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Mahsulot', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          : null,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: [
            const NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Panel'),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: newOrders > 0,
                backgroundColor: AppColors.accent,
                label: Text('$newOrders'),
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: newOrders > 0,
                backgroundColor: AppColors.accent,
                label: Text('$newOrders'),
                child: const Icon(Icons.receipt_long_rounded),
              ),
              label: 'Buyurtmalar',
            ),
            const NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2_rounded), label: 'Mahsulotlar'),
            const NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'Mijozlar'),
            const NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Sozlamalar'),
          ],
        ),
      ),
    );
  }
}
