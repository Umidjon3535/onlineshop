import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'product_editor.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  String _category = allCategory;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final q = _query.trim().toLowerCase();
    final items = shop.products.where((p) {
      final byCategory = _category == allCategory || p.category == _category;
      final byQuery = q.isEmpty || p.title.toLowerCase().contains(q);
      return byCategory && byQuery;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Mahsulot yoki brend qidirish',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c.name),
                    selected: c.name == _category,
                    showCheckmark: false,
                    labelStyle: TextStyle(color: c.name == _category ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _category = c.name),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
          child: Row(
            children: [
              Text('${items.length} ta mahsulot', style: const TextStyle(color: AppColors.muted)),
              const Spacer(),
              Text('${shop.products.where((p) => !p.active).length} ta yashirin', style: const TextStyle(color: AppColors.muted)),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(icon: Icons.inventory_2_outlined, title: 'Mahsulot topilmadi', subtitle: "Qidiruvni yoki toifani o'zgartiring.")
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductEditor(product: p))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: p.active ? 1 : 0.45,
                                child: ImageTile(image: p.cover, category: p.category, size: 64, radius: 14, padding: 6),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text(formatPrice(p.price), style: const TextStyle(fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Pill(
                                          p.stock == 0 ? 'Tugagan' : '${p.stock} dona',
                                          color: p.stock == 0 ? AppColors.danger : p.stock < 10 ? AppColors.accent : AppColors.success,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(p.category,
                                              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Tooltip(
                                message: p.active ? "Do'konda ko'rinadi" : 'Yashirilgan',
                                child: Switch(
                                  value: p.active,
                                  activeTrackColor: AppColors.accent,
                                  onChanged: (v) {
                                    shop.setProductActive(p, v);
                                    showToast(context, v ? "${p.name} do'konga qaytarildi" : '${p.name} yashirildi',
                                        icon: v ? Icons.visibility_outlined : Icons.visibility_off_outlined);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
