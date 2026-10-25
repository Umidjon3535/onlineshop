import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../admin/admin_login.dart';
import '../admin/admin_shell.dart';
import '../data/catalog.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'addresses_screen.dart';
import 'auth_card.dart';
import 'help_screen.dart';
import 'orders_screen.dart';
import 'payments_screen.dart';
import 'promos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _openAdmin(BuildContext context) {
    final shop = context.read<ShopState>();
    _push(context, shop.isAdmin ? const AdminShell() : const AdminLoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final u = shop.user;

    final common = [
      MenuTile(icon: Icons.language_rounded, title: 'Til', value: "O'zbekcha", onTap: () => _showLanguages(context)),
      MenuTile(icon: Icons.help_outline_rounded, title: 'Yordam markazi', onTap: () => _push(context, const HelpScreen())),
      MenuTile(icon: Icons.admin_panel_settings_outlined, title: 'Admin panel', onTap: () => _openAdmin(context)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: u == null
            ? [
                const AuthCard(),
                const SizedBox(height: 14),
                MenuGroup(children: [
                  MenuTile(icon: Icons.local_offer_outlined, title: 'Promokodlar', onTap: () => _push(context, const PromosScreen())),
                  ...common,
                ]),
              ]
            : [
                _ProfileCard(shop: shop),
                const SizedBox(height: 16),
                MenuGroup(children: [
                  MenuTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Buyurtmalarim',
                    value: shop.myOrders.isEmpty ? null : '${shop.myOrders.length} ta',
                    onTap: () => _push(context, const OrdersScreen()),
                  ),
                  MenuTile(
                    icon: Icons.place_outlined,
                    title: 'Manzillarim',
                    value: u.addresses.isEmpty ? null : '${u.addresses.length} ta',
                    onTap: () => _push(context, const AddressesScreen()),
                  ),
                  MenuTile(
                    icon: Icons.credit_card_outlined,
                    title: "To'lov usullari",
                    value: payMethods[u.pay.clamp(0, payMethods.length - 1)].$2,
                    onTap: () => _push(context, const PaymentsScreen()),
                  ),
                  MenuTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Promokodlar',
                    value: shop.appliedPromo,
                    onTap: () => _push(context, const PromosScreen()),
                  ),
                ]),
                const SizedBox(height: 14),
                MenuGroup(children: [
                  MenuTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Bildirishnomalar',
                    trailing: Switch(
                      value: shop.notifications,
                      activeTrackColor: AppColors.accent,
                      onChanged: shop.setNotifications,
                    ),
                  ),
                  ...common,
                ]),
                const SizedBox(height: 14),
                MenuGroup(children: [
                  MenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Hisobdan chiqish',
                    color: AppColors.danger,
                    onTap: () async {
                      if (await confirmDialog(context,
                          title: 'Hisobdan chiqasizmi?',
                          message: 'Buyurtmalar va manzillaringiz saqlanib qoladi. Qayta kirish uchun telefon raqamingiz kifoya.',
                          confirm: 'Chiqish',
                          danger: true)) {
                        shop.logout();
                      }
                    },
                  ),
                ]),
              ],
      ),
    );
  }

  void _showLanguages(BuildContext context) {
    const langs = [("O'zbekcha", 'Lotin yozuvi'), ('Ўзбекча', 'Кирилл ёзуви'), ('Русский', 'Русский язык'), ('English', 'English')];
    showSheet(
      context,
      title: 'Ilova tili',
      child: Builder(
        builder: (ctx) => Column(
          children: [
            for (var i = 0; i < langs.length; i++) ...[
              SelectTile(
                title: langs[i].$1,
                subtitle: langs[i].$2,
                selected: i == 0,
                trailing: i == 0 ? null : const Pill('Tez orada', color: AppColors.muted),
                onTap: () {
                  if (i == 0) {
                    Navigator.pop(ctx);
                  } else {
                    showToast(context, '${langs[i].$1} tili tez orada qo\'shiladi', icon: Icons.language_rounded);
                  }
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.shop});

  final ShopState shop;

  @override
  Widget build(BuildContext context) {
    final u = shop.user!;
    final orders = shop.myOrders;
    final bonus = orders.where((o) => !o.isCancelled).fold(0, (s, o) => s + o.total) ~/ 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(colors: [AppColors.ink, Color(0xFF3A3D4A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                ),
                child: Text(initials(u.name), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      [fullPhone(u.phone), if (u.email.isNotEmpty) u.email].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Ma'lumotlarni tahrirlash",
                onPressed: () => _editProfile(context),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.1)),
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _stat('${orders.length}', 'Buyurtmalar', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
              _stat('${shop.favoriteProducts.length}', 'Sevimlilar', () => shop.setTab(1)),
              _stat(group3(bonus), 'Bonus ball',
                  () => showToast(context, "Har bir buyurtma summasining 1% i bonus ball bo'lib yoziladi", icon: Icons.stars_rounded)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showSheet(context, title: "Shaxsiy ma'lumotlar", child: const _EditProfileForm());
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  String? _error;

  @override
  void initState() {
    super.initState();
    final u = context.read<ShopState>().user!;
    _name = TextEditingController(text: u.name);
    _email = TextEditingController(text: u.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.length < 2) return setState(() => _error = 'Ism va familiyangizni kiriting.');
    if (email.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      return setState(() => _error = "Email manzil noto'g'ri yozilgan.");
    }
    context.read<ShopState>().updateProfile(name: name, email: email);
    showToast(context, "Ma'lumotlar saqlandi", icon: Icons.person_rounded);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final u = context.read<ShopState>().user!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Ism va familiya')),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email (ixtiyoriy)'),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: false,
          controller: TextEditingController(text: fullPhone(u.phone)),
          decoration: const InputDecoration(labelText: 'Telefon raqam'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Saqlash', onPressed: _save),
      ],
    );
  }
}
