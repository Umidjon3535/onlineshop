import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'notifications_sheet.dart';

const _sorts = ['Ommabop', 'Arzonidan', 'Qimmatidan'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promoController = PageController(viewportFraction: 0.9);
  final _scroll = ScrollController();
  String _category = allCategory;
  String _query = '';
  int _sort = 0;
  int _promoIndex = 0;

  @override
  void dispose() {
    _promoController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<Product> _filter(List<Product> all) {
    final q = _query.trim().toLowerCase();
    final items = all.where((p) {
      final byCategory = _category == allCategory || p.category == _category;
      final byQuery = q.isEmpty || '${p.brand} ${p.name} ${p.category}'.toLowerCase().contains(q);
      return byCategory && byQuery;
    }).toList();
    switch (_sort) {
      case 0:
        items.sort((a, b) => (b.reviews * b.rating).compareTo(a.reviews * a.rating));
      case 1:
        items.sort((a, b) => a.price.compareTo(b.price));
      case 2:
        items.sort((a, b) => b.price.compareTo(a.price));
    }
    return items;
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'Xayrli tun';
    if (h < 12) return 'Xayrli tong';
    if (h < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final items = _filter(shop.catalog);
    final firstName = shop.user?.name.split(' ').first;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                    ),
                    child: const Text('B', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          firstName == null ? 'Bugun nima xarid qilamiz?' : '$firstName, nima xarid qilamiz?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Badge(
                    smallSize: 9,
                    isLabelVisible: shop.hasUnread,
                    backgroundColor: AppColors.accent,
                    child: CircleIconButton(
                      icon: Icons.notifications_none_rounded,
                      size: 46,
                      tooltip: 'Bildirishnomalar',
                      onTap: () => showNotifications(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Mahsulot yoki brend qidirish',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: 'Saralash: ${_sorts[_sort].toLowerCase()}',
                    child: Material(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() => _sort = (_sort + 1) % _sorts.length);
                          showToast(context, 'Saralash: ${_sorts[_sort].toLowerCase()}', icon: Icons.tune_rounded);
                        },
                        child: const SizedBox(width: 54, height: 54, child: Icon(Icons.tune_rounded, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_query.isEmpty) SliverToBoxAdapter(child: _promos(shop)),
          SliverToBoxAdapter(child: _categories()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _query.isNotEmpty
                          ? 'Qidiruv natijalari'
                          : _category == allCategory
                              ? 'Ommabop mahsulotlar'
                              : _category,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${items.length} ta${_sort == 0 ? '' : ' · ${_sorts[_sort].toLowerCase()}'}',
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Hech narsa topilmadi',
                subtitle: "Boshqa so'z bilan qidirib ko'ring yoki toifani o'zgartiring.",
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                gridDelegate: productGridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, i) => ProductCard(product: items[i], heroPrefix: 'home'),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _promos(ShopState shop) {
    final banners = [for (final b in promoBanners) if (shop.byId(b.productId) != null) b];
    if (banners.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _promoController,
            itemCount: banners.length,
            onPageChanged: (i) => setState(() => _promoIndex = i),
            itemBuilder: (context, i) => _promoCard(banners[i], shop.byId(banners[i].productId)!),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _promoIndex ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _promoIndex ? AppColors.ink : AppColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _promoCard(PromoBanner b, Product p) {
    return GestureDetector(
      onTap: () => setState(() => _category = b.category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(colors: b.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -34,
              top: -34,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            Positioned(
              right: 14,
              top: 14,
              bottom: 14,
              width: 118,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), borderRadius: BorderRadius.circular(20)),
                child: ProductImage(p.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 148, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(b.tag, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 10),
                  Text(b.title,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.2, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Xarid qilish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categories() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final c = categories[i];
          final selected = c.name == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = c.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(c.icon, size: 18, color: selected ? Colors.white : AppColors.ink),
                  const SizedBox(width: 8),
                  Text(c.name, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.ink)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
