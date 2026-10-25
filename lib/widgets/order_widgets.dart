import 'package:flutter/material.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'common.dart';

/// To'rt bosqichli kuzatuv chizig'i. Bekor qilingan buyurtmada qizil yozuv chiqadi.
class OrderTrack extends StatelessWidget {
  const OrderTrack(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20),
            SizedBox(width: 8),
            Text('Buyurtma bekor qilingan', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            for (var k = 0; k < 4; k++) ...[
              if (k > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: k <= order.status ? AppColors.accent : AppColors.surface2,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var k = 0; k < 4; k++) ...[
              if (k > 0) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  orderStatuses[k],
                  style: TextStyle(
                    fontSize: 11,
                    color: k == order.status ? AppColors.ink : AppColors.muted,
                    fontWeight: k == order.status ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Ro'yxatdagi buyurtma kartasi.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap, this.showCustomer = false});

  final Order order;
  final VoidCallback onTap;
  final bool showCustomer;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buyurtma #${o.no}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(
                          showCustomer
                              ? '${o.customer} · ${formatDate(o.created)}'
                              : '${formatDate(o.created)} · ${o.count} ta mahsulot',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(o.status),
                ],
              ),
              const SizedBox(height: 12),
              OrderTrack(o),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final it in o.items.take(4)) ...[
                    ImageTile(image: it.image, category: it.category, size: 48, radius: 12, padding: 5),
                    const SizedBox(width: 8),
                  ],
                  if (o.items.length > 4)
                    Text('+${o.items.length - 4}', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(formatPrice(o.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Buyurtma tarkibi, summalar, manzil va to'lov usuli.
class OrderDetails extends StatelessWidget {
  const OrderDetails(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Mahsulotlar'),
        Panel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < o.items.length; i++) ...[
                if (i > 0) const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      ImageTile(image: o.items[i].image, category: o.items[i].category, size: 56, radius: 14, padding: 6),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.items[i].name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              [if (o.items[i].option.isNotEmpty) o.items[i].option, '${o.items[i].qty} dona × ${formatPrice(o.items[i].price)}']
                                  .join(' · '),
                              style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(formatPrice(o.items[i].total), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SectionTitle("To'lov"),
        Panel(
          child: Column(
            children: [
              SummaryRow('Mahsulotlar', formatPrice(o.subtotal)),
              if (o.discount > 0) SummaryRow('Chegirma (${o.promo ?? ''})', '−${formatPrice(o.discount)}', valueColor: AppColors.success),
              SummaryRow('Yetkazib berish', o.delivery == 0 ? 'Bepul' : formatPrice(o.delivery)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
              SummaryRow('Jami', formatPrice(o.total), bold: true),
            ],
          ),
        ),
        const SectionTitle('Yetkazib berish'),
        Panel(
          child: Column(
            children: [
              _InfoRow(icon: Icons.place_rounded, label: 'Manzil', value: o.address),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.credit_card_rounded, label: "To'lov usuli", value: o.payment),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.schedule_rounded, label: "So'nggi o'zgarish", value: formatDate(o.updated)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
