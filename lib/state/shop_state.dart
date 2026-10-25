import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/models.dart';

class Totals {
  const Totals({
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.promo,
    required this.promoValid,
  });

  final int subtotal;
  final int discount;
  final int delivery;
  final PromoCode? promo;
  final bool promoValid;

  int get total => subtotal - discount + delivery;
}

/// Butun ilova holati. Hamma ma'lumot telefonda (SharedPreferences) saqlanadi.
class ShopState extends ChangeNotifier {
  ShopState(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  late List<Product> products;
  late Map<String, AppUser> users;
  late List<Order> orders;
  late List<PromoCode> promos;
  late Settings settings;

  final Set<String> favorites = {};
  final List<CartItem> _cart = [];
  String? _phone;
  String? appliedPromo;
  bool notifications = true;
  DateTime notificationsSeen = DateTime.fromMillisecondsSinceEpoch(0);

  int tab = 0;
  bool isAdmin = false;

  /// Mehmon savatdan «Rasmiylashtirish»ni bosganda kirishdan keyin savatga qaytarish uchun.
  bool pendingCheckout = false;

  // Saqlash

  void _load() {
    products = _readList('products', Product.fromJson) ?? seedProducts();
    users = {for (final u in _readList('users', AppUser.fromJson) ?? <AppUser>[]) u.phone: u};
    orders = _readList('orders', Order.fromJson) ?? [];
    promos = _readList('promos', PromoCode.fromJson) ?? seedPromos();
    settings = Settings();
    final rawSettings = _prefs.getString('settings');
    if (rawSettings != null) {
      try {
        settings = Settings.fromJson(Json.from(jsonDecode(rawSettings) as Map));
      } catch (_) {}
    }
    favorites.addAll(_prefs.getStringList('favorites') ?? const []);
    _cart.addAll(_readList('cart', CartItem.fromJson) ?? const []);
    _phone = _prefs.getString('phone');
    if (_phone != null && !users.containsKey(_phone)) _phone = null;
    appliedPromo = _prefs.getString('promo');
    notifications = _prefs.getBool('notifications') ?? true;
    notificationsSeen = DateTime.fromMillisecondsSinceEpoch(_prefs.getInt('notificationsSeen') ?? 0);
  }

  List<T>? _readList<T>(String key, T Function(Json) fromJson) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return [for (final e in jsonDecode(raw) as List) fromJson(Json.from(e as Map))];
    } catch (_) {
      return null;
    }
  }

  void _save() {
    _prefs.setString('products', jsonEncode([for (final p in products) p.toJson()]));
    _prefs.setString('users', jsonEncode([for (final u in users.values) u.toJson()]));
    _prefs.setString('orders', jsonEncode([for (final o in orders) o.toJson()]));
    _prefs.setString('promos', jsonEncode([for (final c in promos) c.toJson()]));
    _prefs.setString('settings', jsonEncode(settings.toJson()));
    _prefs.setStringList('favorites', favorites.toList());
    _prefs.setString('cart', jsonEncode([for (final c in _cart) c.toJson()]));
    final phone = _phone;
    phone == null ? _prefs.remove('phone') : _prefs.setString('phone', phone);
    final promo = appliedPromo;
    promo == null ? _prefs.remove('promo') : _prefs.setString('promo', promo);
    _prefs.setBool('notifications', notifications);
    _prefs.setInt('notificationsSeen', notificationsSeen.millisecondsSinceEpoch);
  }

  void _changed() {
    _save();
    notifyListeners();
  }

  void setTab(int index) {
    tab = index;
    notifyListeners();
  }

  // Katalog

  Product? byId(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Xaridorga ko'rinadigan mahsulotlar (admin yashirganlari chiqmaydi).
  List<Product> get catalog => products.where((p) => p.active).toList();

  // Sevimlilar

  bool isFavorite(String id) => favorites.contains(id);
  List<Product> get favoriteProducts => catalog.where((p) => favorites.contains(p.id)).toList();

  void toggleFavorite(Product p) {
    if (!favorites.remove(p.id)) favorites.add(p.id);
    _changed();
  }

  // Savat

  List<CartItem> get cart => _cart.where((c) => byId(c.productId)?.active ?? false).toList();
  int get cartCount => cart.fold(0, (s, c) => s + c.qty);
  int get subtotal => cart.fold(0, (s, c) => s + byId(c.productId)!.unitPrice(c.opt) * c.qty);

  /// Ombordagi qoldiqdan ko'p qo'shilmaydi. Mahsulot tugagan bo'lsa false qaytaradi.
  bool addToCart(Product p, {int? opt, int qty = 1}) {
    if (p.stock <= 0) return false;
    final i = _cart.indexWhere((c) => c.productId == p.id && c.opt == opt);
    if (i >= 0) {
      _cart[i].qty = min(p.stock, _cart[i].qty + qty);
    } else {
      _cart.add(CartItem(productId: p.id, opt: opt, qty: min(p.stock, qty)));
    }
    _changed();
    return true;
  }

  void setQty(CartItem item, int qty) {
    final p = byId(item.productId);
    if (qty <= 0 || p == null) {
      _cart.remove(item);
    } else {
      item.qty = min(p.stock, qty);
    }
    _changed();
  }

  void removeFromCart(CartItem item) {
    _cart.remove(item);
    _changed();
  }

  void clearCart() {
    _cart.clear();
    _changed();
  }

  // Promokod va hisob-kitob

  PromoCode? promoByCode(String code) {
    for (final c in promos) {
      if (c.code == code) return c;
    }
    return null;
  }

  Totals get totals {
    final sub = subtotal;
    final code = appliedPromo == null ? null : promoByCode(appliedPromo!);
    final promo = code != null && code.active ? code : null;
    var valid = false;
    var discount = 0;
    var freeShipping = false;
    if (promo != null && sub > 0 && sub >= promo.min) {
      valid = true;
      switch (promo.kind) {
        case PromoKind.percent:
          discount = (sub * promo.value / 100).round();
        case PromoKind.fixed:
          discount = min(promo.value, sub);
        case PromoKind.shipping:
          freeShipping = true;
      }
    }
    final free = sub == 0 || sub >= settings.freeFrom || freeShipping;
    return Totals(
      subtotal: sub,
      discount: discount,
      delivery: free ? 0 : settings.deliveryFee,
      promo: promo,
      promoValid: valid,
    );
  }

  /// Xato matnini qaytaradi, muvaffaqiyatli bo'lsa null.
  String? applyPromo(String raw) {
    final code = raw.trim().toUpperCase();
    if (code.isEmpty) return 'Promokodni kiriting';
    final c = promoByCode(code);
    if (c == null || !c.active) return '«$code» promokodi topilmadi';
    appliedPromo = code;
    _changed();
    return null;
  }

  void removePromo() {
    appliedPromo = null;
    _changed();
  }

  // Hisob

  AppUser? get user => _phone == null ? null : users[_phone];
  bool phoneRegistered(String phone) => users.containsKey(phone);

  void register({required String name, required String phone, String email = ''}) {
    users[phone] = AppUser(phone: phone, name: name, email: email, created: DateTime.now());
    _phone = phone;
    _changed();
  }

  void login(String phone) {
    _phone = phone;
    _changed();
  }

  void logout() {
    _phone = null;
    _changed();
  }

  void updateProfile({required String name, required String email}) {
    final u = user;
    if (u == null) return;
    u.name = name;
    u.email = email;
    _changed();
  }

  void addAddress(Address a) {
    final u = user;
    if (u == null) return;
    u.addresses.add(a);
    u.addressId ??= a.id;
    _changed();
  }

  void removeAddress(String id) {
    final u = user;
    if (u == null) return;
    u.addresses.removeWhere((a) => a.id == id);
    if (u.addressId == id) u.addressId = u.addresses.isEmpty ? null : u.addresses.first.id;
    _changed();
  }

  void selectAddress(String id) {
    user?.addressId = id;
    _changed();
  }

  void setDefaultPay(int index) {
    user?.pay = index;
    _changed();
  }

  void setNotifications(bool value) {
    notifications = value;
    _changed();
  }

  // Buyurtmalar

  List<Order> get myOrders => orders.where((o) => o.phone == _phone).toList();

  Order? orderByNo(String no) {
    for (final o in orders) {
      if (o.no == no) return o;
    }
    return null;
  }

  String _newOrderNo() {
    final rnd = Random();
    String no;
    do {
      no = (100000 + rnd.nextInt(900000)).toString();
    } while (orderByNo(no) != null);
    return no;
  }

  Order placeOrder({required Address address, required int pay}) {
    final u = user!;
    final t = totals;
    final items = [
      for (final c in cart)
        if (byId(c.productId) case final p?)
          OrderItem(
            productId: p.id,
            name: p.title,
            option: p.optionValue(c.opt),
            price: p.unitPrice(c.opt),
            qty: c.qty,
            image: p.cover,
            category: p.category,
          ),
    ];
    final order = Order(
      no: _newOrderNo(),
      phone: u.phone,
      customer: u.name,
      created: DateTime.now(),
      items: items,
      subtotal: t.subtotal,
      discount: t.discount,
      promo: t.promoValid ? t.promo!.code : null,
      delivery: t.delivery,
      total: t.total,
      address: '${address.kind}: ${address.full}',
      payment: payMethods[pay].$2,
    );
    _restock(order, -1);
    orders.insert(0, order);
    u.addressId = address.id;
    _cart.clear();
    appliedPromo = null;
    _changed();
    return order;
  }

  /// Xaridor faqat hali yig'ilmagan buyurtmani bekor qila oladi.
  bool cancelMyOrder(Order o) {
    if (o.status != 0) return false;
    setOrderStatus(o, Order.cancelled);
    return true;
  }

  int reorder(Order o) {
    var added = 0;
    for (final it in o.items) {
      final p = byId(it.productId);
      if (p == null || !p.active || p.stock == 0) continue;
      int? opt;
      if (p.option != null) {
        final i = p.option!.values.indexWhere((v) => v.label == it.option);
        opt = i >= 0 ? i : 0;
      }
      if (addToCart(p, opt: opt, qty: it.qty)) added++;
    }
    return added;
  }

  void _restock(Order o, int sign) {
    for (final it in o.items) {
      final p = byId(it.productId);
      if (p != null) p.stock = max(0, p.stock + sign * it.qty);
    }
  }

  // Bildirishnomalar

  DateTime? get latestUpdate {
    final mine = myOrders;
    if (mine.isEmpty) return null;
    return mine.map((o) => o.updated).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  bool get hasUnread {
    if (!notifications) return false;
    final latest = latestUpdate;
    return notificationsSeen.millisecondsSinceEpoch == 0 || (latest != null && latest.isAfter(notificationsSeen));
  }

  void markNotificationsSeen() {
    notificationsSeen = DateTime.now();
    _changed();
  }

  // Admin

  bool adminLogin(String password) {
    isAdmin = password == settings.adminPassword;
    notifyListeners();
    return isAdmin;
  }

  void adminLogout() {
    isAdmin = false;
    notifyListeners();
  }

  String newProductId() => 'u${DateTime.now().millisecondsSinceEpoch}';

  void saveProduct(Product p) {
    final i = products.indexWhere((x) => x.id == p.id);
    if (i >= 0) {
      products[i] = p;
    } else {
      products.insert(0, p);
    }
    _changed();
  }

  void deleteProduct(Product p) {
    products.removeWhere((x) => x.id == p.id);
    favorites.remove(p.id);
    _cart.removeWhere((c) => c.productId == p.id);
    _changed();
  }

  void setProductActive(Product p, bool active) {
    p.active = active;
    _changed();
  }

  /// Bekor qilinganda mahsulotlar omborga qaytadi, qayta tiklanganda yana ayiriladi.
  void setOrderStatus(Order o, int status) {
    if (o.status == status) return;
    if (status == Order.cancelled) _restock(o, 1);
    if (o.isCancelled) _restock(o, -1);
    o.status = status;
    o.updated = DateTime.now();
    _changed();
  }

  void savePromo(PromoCode c, {String? previousCode}) {
    final i = promos.indexWhere((x) => x.code == (previousCode ?? c.code));
    if (i >= 0) {
      promos[i] = c;
    } else {
      promos.add(c);
    }
    if (previousCode != null && appliedPromo == previousCode) appliedPromo = c.code;
    _changed();
  }

  void deletePromo(PromoCode c) {
    promos.removeWhere((x) => x.code == c.code);
    if (appliedPromo == c.code) appliedPromo = null;
    _changed();
  }

  void setPromoActive(PromoCode c, bool active) {
    c.active = active;
    _changed();
  }

  void updateSettings({int? deliveryFee, int? freeFrom, String? adminPassword}) {
    if (deliveryFee != null) settings.deliveryFee = deliveryFee;
    if (freeFrom != null) settings.freeFrom = freeFrom;
    if (adminPassword != null) settings.adminPassword = adminPassword;
    _changed();
  }

  void resetAll() {
    products = seedProducts();
    users.clear();
    orders = [];
    promos = seedPromos();
    settings = Settings();
    favorites.clear();
    _cart.clear();
    _phone = null;
    appliedPromo = null;
    isAdmin = false;
    tab = 0;
    _changed();
  }

  /// Admin panelni sinab ko'rish uchun so'nggi 7 kunga namuna buyurtmalar yaratadi.
  int addSampleOrders() {
    final rnd = Random();
    const customers = [
      ('Dilnoza Rahimova', '935551122', 'Toshkent sh., Chilonzor tumani, Bunyodkor ko\'chasi, 12'),
      ('Javohir Tursunov', '971234455', "Samarqand, Registon ko'chasi, 5-uy"),
      ('Malika Yusupova', '998887766', "Toshkent sh., Yunusobod tumani, Amir Temur ko'chasi, 108"),
      ('Sardor Aliyev', '901112233', "Farg'ona, Mustaqillik ko'chasi, 21"),
    ];
    final now = DateTime.now();
    final pool = catalog;
    if (pool.isEmpty) return 0;
    var created = 0;
    for (var i = 0; i < 10; i++) {
      final c = customers[rnd.nextInt(customers.length)];
      users.putIfAbsent(c.$2, () => AppUser(phone: c.$2, name: c.$1, created: now.subtract(const Duration(days: 9))));
      final items = <OrderItem>[];
      for (var k = 0; k < 1 + rnd.nextInt(3); k++) {
        final p = pool[rnd.nextInt(pool.length)];
        final opt = p.option == null ? null : rnd.nextInt(p.option!.values.length);
        items.add(OrderItem(
          productId: p.id,
          name: p.title,
          option: p.optionValue(opt),
          price: p.unitPrice(opt),
          qty: 1 + rnd.nextInt(2),
          image: p.cover,
          category: p.category,
        ));
      }
      final sub = items.fold(0, (s, it) => s + it.total);
      final delivery = sub >= settings.freeFrom ? 0 : settings.deliveryFee;
      final at = now.subtract(Duration(days: rnd.nextInt(7), hours: rnd.nextInt(10), minutes: rnd.nextInt(60)));
      final age = now.difference(at).inHours;
      final status = age > 72 ? (rnd.nextInt(6) == 0 ? Order.cancelled : 3) : age > 24 ? 2 : rnd.nextInt(2);
      orders.add(Order(
        no: _newOrderNo(),
        phone: c.$2,
        customer: c.$1,
        created: at,
        items: items,
        subtotal: sub,
        discount: 0,
        delivery: delivery,
        total: sub + delivery,
        address: 'Uy: ${c.$3}',
        payment: payMethods[rnd.nextInt(payMethods.length)].$2,
        status: status,
        updated: at,
      ));
      created++;
    }
    orders.sort((a, b) => b.created.compareTo(a.created));
    _changed();
    return created;
  }

  // Statistika

  List<Order> get _validOrders => orders.where((o) => !o.isCancelled).toList();
  int get revenue => _validOrders.fold(0, (s, o) => s + o.total);
  int get newOrdersCount => orders.where((o) => o.status == 0).length;
  int get averageCheck => _validOrders.isEmpty ? 0 : revenue ~/ _validOrders.length;
  List<Product> get lowStock => products.where((p) => p.stock < 10).toList()..sort((a, b) => a.stock.compareTo(b.stock));

  /// So'nggi 7 kun: (kun, tushum), eng eskisidan bugungacha.
  List<(DateTime, int)> revenueByDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final day = today.subtract(Duration(days: i));
          final sum = _validOrders
              .where((o) => o.created.year == day.year && o.created.month == day.month && o.created.day == day.day)
              .fold(0, (s, o) => s + o.total);
          return (day, sum);
        }(),
    ];
  }

  List<Order> ordersOf(String phone) => orders.where((o) => o.phone == phone).toList();
  int spentBy(String phone) => ordersOf(phone).where((o) => !o.isCancelled).fold(0, (s, o) => s + o.total);
}
