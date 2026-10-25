import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/shop_state.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

/// Ro'yxatdan o'tish va kirish. SMS o'rniga namuna kod ekranda ko'rsatiladi.
class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _register = false;
  bool _agree = false;
  bool _codeStep = false;
  String _sent = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _register = context.read<ShopState>().users.isEmpty;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  String _newCode() => (1000 + Random().nextInt(9000)).toString();

  void _requestCode() {
    final shop = context.read<ShopState>();
    final phone = _phone.text;
    final email = _email.text.trim();
    String? error;
    if (_register && _name.text.trim().length < 2) {
      error = 'Ism va familiyangizni kiriting.';
    } else if (phone.length != 9) {
      error = "Telefon raqamni to'liq kiriting: kod bilan 9 ta raqam.";
    } else if (_register && email.isNotEmpty && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      error = "Email manzil noto'g'ri yozilgan. Masalan: aziz@mail.uz";
    } else if (_register && !_agree) {
      error = 'Davom etish uchun foydalanish shartlariga rozilik bering.';
    } else if (_register && shop.phoneRegistered(phone)) {
      error = "Bu raqam allaqachon ro'yxatdan o'tgan. «Kirish» bo'limidan foydalaning.";
    } else if (!_register && !shop.phoneRegistered(phone)) {
      error = "Bu raqam ro'yxatdan o'tmagan. Avval «Ro'yxatdan o'tish» bo'limida hisob oching.";
    }
    setState(() {
      _error = error;
      if (error == null) {
        _codeStep = true;
        _sent = _newCode();
        _code.clear();
      }
    });
  }

  void _verify() {
    if (_code.text != _sent) {
      setState(() => _error = "Kod noto'g'ri. Yuqoridagi 4 xonali kodni kiriting.");
      return;
    }
    final shop = context.read<ShopState>();
    final phone = _phone.text;
    final checkout = shop.pendingCheckout;
    // Toast shu yerda chiqariladi: kirgandan keyin bu karta ekrandan yo'qoladi.
    final name = _register ? _name.text.trim() : shop.users[phone]!.name;
    showToast(context, _register ? 'Hisob ochildi. Xush kelibsiz, ${name.split(' ').first}!' : 'Xush kelibsiz, ${name.split(' ').first}!',
        icon: Icons.person_rounded);
    if (_register) {
      shop.register(name: name, phone: phone, email: _email.text.trim());
    } else {
      shop.login(phone);
    }
    if (checkout) {
      shop.pendingCheckout = false;
      shop.setTab(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
      child: _codeStep ? _codeView() : _formView(),
    );
  }

  Widget _header(String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
          ),
          child: const Text('B', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.45)),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(
          _register ? "Ro'yxatdan o'tish" : 'Hisobga kirish',
          _register
              ? 'Buyurtmalarni kuzatish, manzillar va bonuslarni saqlash uchun hisob oching.'
              : "Ro'yxatdan o'tgan telefon raqamingizni kiriting.",
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Kirish')),
            ButtonSegment(value: true, label: Text("Ro'yxatdan o'tish")),
          ],
          selected: {_register},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() {
            _register = s.first;
            _error = null;
          }),
        ),
        const SizedBox(height: 16),
        if (_register) ...[
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(labelText: 'Ism va familiya', hintText: 'Masalan, Aziz Karimov'),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
          decoration: const InputDecoration(labelText: 'Telefon raqam', prefixText: '+998 ', hintText: '901234567'),
        ),
        if (_register) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email (ixtiyoriy)', hintText: 'aziz@mail.uz'),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            value: _agree,
            onChanged: (v) => setState(() => _agree = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.accent,
            title: const Text('Foydalanish shartlari va maxfiylik siyosatiga roziman',
                style: TextStyle(fontSize: 13, color: AppColors.muted)),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, height: 1.4)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Kod olish', onPressed: _requestCode),
      ],
    );
  }

  Widget _codeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header('Kodni kiriting', '${fullPhone(_phone.text)} raqamiga 4 xonali tasdiqlash kodi yuborildi.'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(height: 1.45),
              children: [
                const TextSpan(text: 'Namuna rejim: SMS yuborilmaydi. Tasdiqlash kodingiz: '),
                TextSpan(text: _sent, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: 3)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 12),
          decoration: const InputDecoration(hintText: '····'),
          onChanged: (v) {
            if (v.length == 4) _verify();
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
        ],
        const SizedBox(height: 16),
        PrimaryButton(label: 'Tasdiqlash', onPressed: _verify),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() {
                _codeStep = false;
                _error = null;
              }),
              child: const Text("Raqamni o'zgartirish"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _sent = _newCode();
                  _code.clear();
                  _error = null;
                });
                showToast(context, 'Yangi kod yuborildi', icon: Icons.sms_outlined);
              },
              child: const Text('Kodni qayta yuborish'),
            ),
          ],
        ),
      ],
    );
  }
}
