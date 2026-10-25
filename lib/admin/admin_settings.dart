import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        SectionTitle(
          'Promokodlar',
          trailing: TextButton.icon(
            onPressed: () => _editPromo(context, null),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Yangi'),
          ),
        ),
        MenuGroup(
          children: [
            if (shop.promos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Promokod yo'q. «Yangi» tugmasi bilan qo'shing.", style: TextStyle(color: AppColors.muted)),
              ),
            for (final c in shop.promos)
              InkWell(
                onTap: () => _editPromo(context, c),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                        child: c.kind == PromoKind.shipping
                            ? const Icon(Icons.local_shipping_outlined, color: AppColors.accent, size: 20)
                            : Text(c.badge, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.code, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                            const SizedBox(height: 2),
                            Text(c.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Switch(value: c.active, activeTrackColor: AppColors.accent, onChanged: (v) => shop.setPromoActive(c, v)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SectionTitle('Yetkazib berish'),
        _DeliveryForm(fee: shop.settings.deliveryFee, freeFrom: shop.settings.freeFrom),
        const SectionTitle('Xavfsizlik'),
        MenuGroup(
          children: [
            MenuTile(icon: Icons.lock_outline_rounded, title: "Admin parolini o'zgartirish", onTap: () => _changePassword(context)),
          ],
        ),
        const SectionTitle("Ma'lumotlar"),
        MenuGroup(
          children: [
            MenuTile(
              icon: Icons.auto_awesome_outlined,
              title: "Namuna buyurtmalar qo'shish",
              onTap: () {
                final n = shop.addSampleOrders();
                showToast(context, "$n ta namuna buyurtma qo'shildi", icon: Icons.receipt_long_rounded);
              },
            ),
            MenuTile(
              icon: Icons.restart_alt_rounded,
              title: 'Hammasini boshlang\'ich holatga qaytarish',
              color: AppColors.danger,
              onTap: () async {
                if (await confirmDialog(context,
                    title: "Ma'lumotlarni tiklaysizmi?",
                    message:
                        "Barcha buyurtmalar, mijozlar va siz qo'shgan mahsulotlar o'chiriladi. Katalog, promokodlar va admin paroli (admin123) boshlang'ich holatga qaytadi.",
                    confirm: 'Tiklash',
                    danger: true)) {
                  shop.resetAll();
                  if (context.mounted) Navigator.popUntil(context, (r) => r.isFirst);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _editPromo(BuildContext context, PromoCode? code) {
    showSheet(context, title: code == null ? 'Yangi promokod' : 'Promokodni tahrirlash', child: _PromoForm(code: code));
  }

  void _changePassword(BuildContext context) {
    showSheet(context, title: "Admin parolini o'zgartirish", child: const _PasswordForm());
  }
}

class _DeliveryForm extends StatefulWidget {
  const _DeliveryForm({required this.fee, required this.freeFrom});

  final int fee;
  final int freeFrom;

  @override
  State<_DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends State<_DeliveryForm> {
  late final _fee = TextEditingController(text: '${widget.fee}');
  late final _free = TextEditingController(text: '${widget.freeFrom}');

  @override
  void dispose() {
    _fee.dispose();
    _free.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _fee,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: "Yetkazib berish narxi, so'm"),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _free,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: "Bepul yetkazish, so'mdan boshlab"),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () {
              final fee = int.tryParse(_fee.text);
              final free = int.tryParse(_free.text);
              if (fee == null || free == null) {
                showToast(context, 'Ikkala summani ham kiriting', icon: Icons.error_outline_rounded);
                return;
              }
              context.read<ShopState>().updateSettings(deliveryFee: fee, freeFrom: free);
              FocusScope.of(context).unfocus();
              showToast(context, 'Saqlandi: ${formatPrice(fee)}, ${formatPrice(free)} dan bepul', icon: Icons.local_shipping_outlined);
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }
}

class _PromoForm extends StatefulWidget {
  const _PromoForm({this.code});

  final PromoCode? code;

  @override
  State<_PromoForm> createState() => _PromoFormState();
}

class _PromoFormState extends State<_PromoForm> {
  late final _code = TextEditingController(text: widget.code?.code ?? '');
  late final _title = TextEditingController(text: widget.code?.title ?? '');
  late final _value = TextEditingController(text: widget.code == null ? '' : '${widget.code!.value}');
  late final _min = TextEditingController(text: widget.code == null ? '' : '${widget.code!.min}');
  late PromoKind _kind = widget.code?.kind ?? PromoKind.percent;
  String? _error;

  @override
  void dispose() {
    for (final c in [_code, _title, _value, _min]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final shop = context.read<ShopState>();
    final code = _code.text.trim().toUpperCase();
    final value = int.tryParse(_value.text) ?? 0;
    String? error;
    if (!RegExp(r'^[A-Z0-9]{3,16}$').hasMatch(code)) {
      error = "Kod 3–16 ta lotin harfi yoki raqamdan iborat bo'lsin.";
    } else if (code != widget.code?.code && shop.promoByCode(code) != null) {
      error = 'Bunday promokod allaqachon bor.';
    } else if (_kind != PromoKind.shipping && value <= 0) {
      error = 'Chegirma qiymatini kiriting.';
    } else if (_kind == PromoKind.percent && value > 90) {
      error = "Foiz 90 dan oshmasin.";
    } else if (_title.text.trim().isEmpty) {
      error = 'Xaridorga ko\'rinadigan tavsifni yozing.';
    }
    if (error != null) return setState(() => _error = error);

    shop.savePromo(
      PromoCode(
        code: code,
        kind: _kind,
        value: _kind == PromoKind.shipping ? 0 : value,
        min: int.tryParse(_min.text) ?? 0,
        title: _title.text.trim(),
        active: widget.code?.active ?? true,
      ),
      previousCode: widget.code?.code,
    );
    showToast(context, '$code saqlandi', icon: Icons.local_offer_outlined);
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final c = widget.code!;
    if (!await confirmDialog(context, title: "${c.code} o'chirilsinmi?", message: 'Bu promokod endi ishlamaydi.', confirm: "O'chirish", danger: true)) {
      return;
    }
    if (!mounted) return;
    context.read<ShopState>().deletePromo(c);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _code,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Kod', hintText: 'BAHOR20'),
        ),
        const SizedBox(height: 12),
        SegmentedButton<PromoKind>(
          segments: const [
            ButtonSegment(value: PromoKind.percent, label: Text('Foiz')),
            ButtonSegment(value: PromoKind.fixed, label: Text('Summa')),
            ButtonSegment(value: PromoKind.shipping, label: Text('Yetkazish')),
          ],
          selected: {_kind},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _kind = s.first),
        ),
        const SizedBox(height: 12),
        if (_kind != PromoKind.shipping) ...[
          TextField(
            controller: _value,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: _kind == PromoKind.percent ? 'Chegirma, %' : "Chegirma, so'm"),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _min,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: "Eng kam xarid, so'm (ixtiyoriy)"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Xaridorga ko\'rinadigan tavsif', hintText: 'Bahorgi kolleksiyaga 20% chegirma'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Saqlash', onPressed: _save),
        if (widget.code != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: _delete,
            child: const Text("Promokodni o'chirish", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }
}

class _PasswordForm extends StatefulWidget {
  const _PasswordForm();

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();
  String? _error;

  @override
  void dispose() {
    for (final c in [_current, _next, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final shop = context.read<ShopState>();
    String? error;
    if (_current.text != shop.settings.adminPassword) {
      error = "Joriy parol noto'g'ri.";
    } else if (_next.text.length < 6) {
      error = "Yangi parol kamida 6 ta belgidan iborat bo'lsin.";
    } else if (_next.text != _repeat.text) {
      error = 'Yangi parollar bir xil emas.';
    }
    if (error != null) return setState(() => _error = error);
    shop.updateSettings(adminPassword: _next.text);
    showToast(context, "Parol o'zgartirildi", icon: Icons.lock_rounded);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _current, obscureText: true, decoration: const InputDecoration(labelText: 'Joriy parol')),
        const SizedBox(height: 12),
        TextField(controller: _next, obscureText: true, decoration: const InputDecoration(labelText: 'Yangi parol')),
        const SizedBox(height: 12),
        TextField(controller: _repeat, obscureText: true, decoration: const InputDecoration(labelText: 'Yangi parolni takrorlang')),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: "Parolni o'zgartirish", onPressed: _save),
      ],
    );
  }
}
