import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _text = TextEditingController();
  String _kind = addressKinds.first.$1;
  String _region = regions.first;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _save(ShopState shop) {
    final text = _text.text.trim();
    if (text.length < 5) {
      setState(() => _error = "Ko'cha, uy va xonadon raqamini yozing.");
      return;
    }
    shop.addAddress(Address(id: 'a${DateTime.now().millisecondsSinceEpoch}', kind: _kind, region: _region, text: text));
    _text.clear();
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    showToast(context, 'Manzil saqlandi', icon: Icons.place_rounded);
  }

  Future<void> _pickRegion() async {
    final picked = await showSheet<String>(
      context,
      title: 'Viloyat yoki shahar',
      child: Builder(
        builder: (ctx) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in regions)
              ChoiceChip(
                label: Text(r),
                selected: r == _region,
                showCheckmark: false,
                labelStyle: TextStyle(color: r == _region ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
                backgroundColor: AppColors.surface2,
                onSelected: (_) => Navigator.pop(ctx, r),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _region = picked);
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final u = shop.user;
    if (u == null) return const Scaffold(body: SizedBox.shrink());

    return Scaffold(
      appBar: AppBar(title: const Text('Manzillarim')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (u.addresses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text("Hali manzil qo'shilmagan. Buyurtma berish uchun kamida bitta manzil kerak.",
                  style: TextStyle(color: AppColors.muted, height: 1.45)),
            ),
          for (final a in u.addresses) ...[
            Row(
              children: [
                Expanded(
                  child: SelectTile(
                    icon: addressIcon(a.kind),
                    title: a.kind,
                    subtitle: a.full,
                    selected: a.id == u.defaultAddress?.id,
                    onTap: () {
                      shop.selectAddress(a.id);
                      showToast(context, "Asosiy manzil o'zgartirildi", icon: Icons.place_rounded);
                    },
                  ),
                ),
                IconButton(
                  tooltip: "Manzilni o'chirish",
                  onPressed: () => shop.removeAddress(a.id),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          Panel(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Yangi manzil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final k in addressKinds)
                      ChoiceChip(
                        avatar: Icon(k.$2, size: 18, color: k.$1 == _kind ? Colors.white : AppColors.ink),
                        label: Text(k.$1),
                        selected: k.$1 == _kind,
                        showCheckmark: false,
                        backgroundColor: AppColors.surface2,
                        labelStyle: TextStyle(color: k.$1 == _kind ? Colors.white : AppColors.ink, fontWeight: FontWeight.w700),
                        onSelected: (_) => setState(() => _kind = k.$1),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickRegion,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Viloyat yoki shahar', suffixIcon: Icon(Icons.expand_more_rounded)),
                    child: Text(_region, style: const TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _text,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Ko'cha, uy va xonadon",
                    hintText: "Masalan, Amir Temur ko'chasi, 108-uy, 12-xonadon",
                    errorText: _error,
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Manzilni saqlash', onPressed: () => _save(shop)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
