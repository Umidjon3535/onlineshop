import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data/catalog.dart';
import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class _Row {
  _Row(String a, String b)
      : first = TextEditingController(text: a),
        second = TextEditingController(text: b);

  final TextEditingController first;
  final TextEditingController second;

  void dispose() {
    first.dispose();
    second.dispose();
  }
}

/// Yangi mahsulot qo'shish ([product] null) yoki mavjudini tahrirlash.
class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, this.product});

  final Product? product;

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _stock;
  late final TextEditingController _warranty;
  late final TextEditingController _description;
  late final TextEditingController _optionName;
  late final List<_Row> _options;
  late final List<_Row> _specs;
  late List<String> _images;
  late String _category;
  late bool _active;
  bool _picking = false;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _brand = TextEditingController(text: p?.brand ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _oldPrice = TextEditingController(text: p?.oldPrice?.toString() ?? '');
    _stock = TextEditingController(text: p == null ? '10' : '${p.stock}');
    _warranty = TextEditingController(text: p?.warranty ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _optionName = TextEditingController(text: p?.option?.name ?? '');
    _options = [for (final v in p?.option?.values ?? <OptionValue>[]) _Row(v.label, v.extra == 0 ? '' : '${v.extra}')];
    _specs = [for (final s in p?.specs ?? <Spec>[]) _Row(s.key, s.value)];
    _images = [...?p?.images];
    _category = p?.category ?? productCategories.first;
    _active = p?.active ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _price, _oldPrice, _stock, _warranty, _description, _optionName]) {
      c.dispose();
    }
    for (final r in [..._options, ..._specs]) {
      r.dispose();
    }
    super.dispose();
  }

  int? _int(String s) => int.tryParse(s.replaceAll(RegExp(r'\s'), ''));

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1400, imageQuality: 85);
      if (file == null) return;
      // Kesh tozalansa ham rasm yo'qolmasligi uchun ilova papkasiga ko'chiriladi.
      final dir = await getApplicationDocumentsDirectory();
      final dot = file.path.lastIndexOf('.');
      final ext = dot >= 0 ? file.path.substring(dot) : '.jpg';
      final saved = await File(file.path).copy('${dir.path}/product_${DateTime.now().millisecondsSinceEpoch}$ext');
      if (mounted) setState(() => _images.add(saved.path));
    } catch (e) {
      if (mounted) showToast(context, "Rasmni ochib bo'lmadi: $e", icon: Icons.error_outline_rounded);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    if (_images.isEmpty) {
      showToast(context, "Kamida bitta rasm qo'shing", icon: Icons.image_outlined);
      return;
    }
    final shop = context.read<ShopState>();
    final old = widget.product;
    final values = [
      for (final r in _options)
        if (r.first.text.trim().isNotEmpty) OptionValue(r.first.text.trim(), _int(r.second.text) ?? 0),
    ];
    final product = Product(
      id: old?.id ?? shop.newProductId(),
      name: _name.text.trim(),
      brand: _brand.text.trim(),
      category: _category,
      images: _images,
      price: _int(_price.text)!,
      oldPrice: _int(_oldPrice.text),
      rating: old?.rating ?? 0,
      reviews: old?.reviews ?? 0,
      stock: _int(_stock.text) ?? 0,
      warranty: _warranty.text.trim(),
      option: values.isEmpty ? null : OptionGroup(_optionName.text.trim().isEmpty ? 'Variant' : _optionName.text.trim(), values),
      specs: [
        for (final r in _specs)
          if (r.first.text.trim().isNotEmpty && r.second.text.trim().isNotEmpty) Spec(r.first.text.trim(), r.second.text.trim()),
      ],
      description: _description.text.trim(),
      active: _active,
    );
    shop.saveProduct(product);
    showToast(context, _isNew ? "${product.name} qo'shildi" : "O'zgarishlar saqlandi", icon: Icons.inventory_2_rounded);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final p = widget.product!;
    if (!await confirmDialog(context,
        title: "Mahsulotni o'chirasizmi?",
        message: "${p.title} katalogdan, savatlardan va sevimlilardan o'chiriladi. Eski buyurtmalarda saqlanib qoladi.",
        confirm: "O'chirish",
        danger: true)) {
      return;
    }
    if (!mounted) return;
    context.read<ShopState>().deleteProduct(p);
    showToast(context, "${p.name} o'chirildi", icon: Icons.delete_outline_rounded);
    Navigator.pop(context);
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? "Bu maydonni to'ldiring" : null;

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Yangi mahsulot' : 'Mahsulotni tahrirlash'),
        actions: [
          if (!_isNew)
            IconButton(tooltip: "O'chirish", onPressed: _delete, icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger)),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SectionTitle('Rasmlar'),
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < _images.length; i++) ...[
                    _ImageThumb(
                      path: _images[i],
                      category: _category,
                      isCover: i == 0,
                      onCover: () => setState(() => _images.insert(0, _images.removeAt(i))),
                      onRemove: () => setState(() => _images.removeAt(i)),
                    ),
                    const SizedBox(width: 10),
                  ],
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _picking ? null : _pickImage,
                    child: Container(
                      width: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: _picking
                          ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent),
                                SizedBox(height: 4),
                                Text('Galereyadan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text("Birinchi rasm muqova bo'ladi. Boshqasini muqova qilish uchun ustiga bosing.",
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
            const SectionTitle("Asosiy ma'lumotlar"),
            TextFormField(controller: _name, validator: _required, decoration: const InputDecoration(labelText: 'Nomi')),
            const SizedBox(height: 12),
            TextFormField(controller: _brand, validator: _required, decoration: const InputDecoration(labelText: 'Brend')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in productCategories)
                  ChoiceChip(
                    label: Text(c),
                    selected: c == _category,
                    showCheckmark: false,
                    labelStyle: TextStyle(color: c == _category ? Colors.white : AppColors.ink, fontWeight: FontWeight.w600),
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SectionTitle('Narx va ombor'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: (v) => (_int(v ?? '') ?? 0) <= 0 ? 'Narxni kiriting' : null,
                    decoration: const InputDecoration(labelText: "Narx, so'm"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _oldPrice,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: (v) {
                      final old = _int(v ?? '');
                      final price = _int(_price.text) ?? 0;
                      return old != null && old <= price ? 'Narxdan katta bo\'lsin' : null;
                    },
                    decoration: const InputDecoration(labelText: 'Eski narx (ixtiyoriy)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    validator: (v) => _int(v ?? '') == null ? 'Sonini kiriting' : null,
                    decoration: const InputDecoration(labelText: 'Omborda, dona'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(controller: _warranty, decoration: const InputDecoration(labelText: 'Kafolat', hintText: '1 yil kafolat')),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.accent,
              title: const Text("Do'konda ko'rsatish", style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("O'chirilsa, xaridorlar bu mahsulotni ko'rmaydi"),
            ),
            const SectionTitle('Tavsif'),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Mahsulot haqida qisqacha', alignLabelWithHint: true),
            ),
            SectionTitle(
              'Variantlar',
              trailing: TextButton.icon(
                onPressed: () => setState(() => _options.add(_Row('', ''))),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Qo'shish"),
              ),
            ),
            if (_options.isNotEmpty) ...[
              TextField(controller: _optionName, decoration: const InputDecoration(labelText: 'Guruh nomi', hintText: "Xotira, O'lcham, Hajmi")),
              const SizedBox(height: 10),
            ] else
              const Text("Masalan, xotira hajmi yoki o'lchamlar. Qo'shimcha narx bo'sh qolsa, narx o'zgarmaydi.",
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            for (var i = 0; i < _options.length; i++)
              _PairRow(
                row: _options[i],
                firstLabel: 'Variant',
                secondLabel: "+ so'm",
                numericSecond: true,
                onRemove: () => setState(() => _options.removeAt(i).dispose()),
              ),
            SectionTitle(
              'Xususiyatlari',
              trailing: TextButton.icon(
                onPressed: () => setState(() => _specs.add(_Row('', ''))),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Qo'shish"),
              ),
            ),
            if (_specs.isEmpty)
              const Text('Masalan: Ekran — 6,1″ OLED, Material — Tabiiy charm.', style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            for (var i = 0; i < _specs.length; i++)
              _PairRow(
                row: _specs[i],
                firstLabel: 'Nomi',
                secondLabel: 'Qiymati',
                onRemove: () => setState(() => _specs.removeAt(i).dispose()),
              ),
            const SizedBox(height: 24),
            PrimaryButton(label: _isNew ? "Mahsulotni qo'shish" : 'Saqlash', icon: Icons.check_rounded, onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.path, required this.category, required this.isCover, required this.onCover, required this.onRemove});

  final String path;
  final String category;
  final bool isCover;
  final VoidCallback onCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCover,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isCover ? AppColors.ink : Colors.transparent, width: 2),
            ),
            child: ImageTile(image: path, category: category, size: 92, radius: 16, padding: 8),
          ),
          if (isCover) const Positioned(left: 6, bottom: 6, child: Pill('Muqova', color: AppColors.ink)),
          Positioned(
            right: 2,
            top: 2,
            child: CircleIconButton(icon: Icons.close_rounded, size: 26, tooltip: "Rasmni olib tashlash", onTap: onRemove),
          ),
        ],
      ),
    );
  }
}

class _PairRow extends StatelessWidget {
  const _PairRow({
    required this.row,
    required this.firstLabel,
    required this.secondLabel,
    required this.onRemove,
    this.numericSecond = false,
  });

  final _Row row;
  final String firstLabel;
  final String secondLabel;
  final VoidCallback onRemove;
  final bool numericSecond;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(flex: 5, child: TextField(controller: row.first, decoration: InputDecoration(labelText: firstLabel))),
          const SizedBox(width: 8),
          Expanded(
            flex: numericSecond ? 4 : 6,
            child: TextField(
              controller: row.second,
              keyboardType: numericSecond ? TextInputType.number : TextInputType.text,
              inputFormatters: numericSecond ? [FilteringTextInputFormatter.digitsOnly] : null,
              decoration: InputDecoration(labelText: secondLabel),
            ),
          ),
          IconButton(tooltip: 'Olib tashlash', onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.muted)),
        ],
      ),
    );
  }
}
