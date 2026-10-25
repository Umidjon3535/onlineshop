import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final items = shop.favoriteProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Sevimlilar')),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border_rounded,
              title: "Sevimlilar ro'yxati bo'sh",
              subtitle: "Yoqqan mahsulotdagi yurakcha belgisini bosing, u shu yerda saqlanadi.",
              actionLabel: "Mahsulotlarni ko'rish",
              onAction: () => shop.setTab(0),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate: productGridDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => ProductCard(product: items[i], heroPrefix: 'fav'),
                      childCount: items.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
