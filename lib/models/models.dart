typedef Json = Map<String, dynamic>;

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
String _str(Object? v, [String fallback = '']) => v is String ? v : fallback;
List<Json> _maps(Object? v) => v is List ? v.whereType<Map>().map((e) => Json.from(e)).toList() : [];

class OptionValue {
  OptionValue(this.label, this.extra);

  String label;

  /// Asosiy narxga qo'shiladigan summa.
  int extra;

  Json toJson() => {'label': label, 'extra': extra};
  factory OptionValue.fromJson(Json j) => OptionValue(_str(j['label']), _int(j['extra']));
}

/// Mahsulot varianti guruhi: xotira, o'lcham, hajm va hokazo.
class OptionGroup {
  OptionGroup(this.name, this.values);

  String name;
  List<OptionValue> values;

  Json toJson() => {'name': name, 'values': [for (final v in values) v.toJson()]};
  factory OptionGroup.fromJson(Json j) =>
      OptionGroup(_str(j['name']), [for (final v in _maps(j['values'])) OptionValue.fromJson(v)]);
}

class Spec {
  Spec(this.key, this.value);

  String key;
  String value;

  Json toJson() => {'key': key, 'value': value};
  factory Spec.fromJson(Json j) => Spec(_str(j['key']), _str(j['value']));
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.images,
    required this.price,
    this.oldPrice,
    this.rating = 0,
    this.reviews = 0,
    this.stock = 0,
    this.warranty = '',
    this.option,
    List<Spec>? specs,
    this.description = '',
    this.active = true,
  }) : specs = specs ?? [];

  String id;
  String name;
  String brand;
  String category;
  List<String> images;
  int price;
  int? oldPrice;
  double rating;
  int reviews;
  int stock;
  String warranty;
  OptionGroup? option;
  List<Spec> specs;
  String description;
  bool active;

  String get cover => images.isEmpty ? '' : images.first;
  String get title => '$brand $name';

  int? get discount {
    final old = oldPrice;
    if (old == null || old <= price) return null;
    return ((old - price) / old * 100).round();
  }

  bool _validOpt(int? opt) => option != null && opt != null && opt >= 0 && opt < option!.values.length;
  int extra(int? opt) => _validOpt(opt) ? option!.values[opt!].extra : 0;
  int unitPrice(int? opt) => price + extra(opt);
  String optionValue(int? opt) => _validOpt(opt) ? option!.values[opt!].label : '';
  String optionLabel(int? opt) => _validOpt(opt) ? '${option!.name}: ${option!.values[opt!].label}' : '';

  Json toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category': category,
        'images': images,
        'price': price,
        'oldPrice': oldPrice,
        'rating': rating,
        'reviews': reviews,
        'stock': stock,
        'warranty': warranty,
        'option': option?.toJson(),
        'specs': [for (final s in specs) s.toJson()],
        'description': description,
        'active': active,
      };

  factory Product.fromJson(Json j) => Product(
        id: _str(j['id']),
        name: _str(j['name']),
        brand: _str(j['brand']),
        category: _str(j['category']),
        images: j['images'] is List ? List<String>.from((j['images'] as List).whereType<String>()) : [],
        price: _int(j['price']),
        oldPrice: j['oldPrice'] is num ? (j['oldPrice'] as num).toInt() : null,
        rating: j['rating'] is num ? (j['rating'] as num).toDouble() : 0,
        reviews: _int(j['reviews']),
        stock: _int(j['stock']),
        warranty: _str(j['warranty']),
        option: j['option'] is Map ? OptionGroup.fromJson(Json.from(j['option'] as Map)) : null,
        specs: [for (final s in _maps(j['specs'])) Spec.fromJson(s)],
        description: _str(j['description']),
        active: j['active'] != false,
      );
}

class CartItem {
  CartItem({required this.productId, this.opt, this.qty = 1});

  final String productId;
  final int? opt;
  int qty;

  Json toJson() => {'productId': productId, 'opt': opt, 'qty': qty};
  factory CartItem.fromJson(Json j) =>
      CartItem(productId: _str(j['productId']), opt: j['opt'] is num ? (j['opt'] as num).toInt() : null, qty: _int(j['qty'], 1));
}

class Address {
  Address({required this.id, required this.kind, required this.region, required this.text});

  final String id;
  final String kind;
  final String region;
  final String text;

  String get full => '$region, $text';

  Json toJson() => {'id': id, 'kind': kind, 'region': region, 'text': text};
  factory Address.fromJson(Json j) =>
      Address(id: _str(j['id']), kind: _str(j['kind'], 'Uy'), region: _str(j['region']), text: _str(j['text']));
}

class AppUser {
  AppUser({
    required this.phone,
    required this.name,
    this.email = '',
    List<Address>? addresses,
    this.addressId,
    this.pay = 0,
    required this.created,
  }) : addresses = addresses ?? [];

  /// 9 xonali raqam, +998 siz: "901234567".
  final String phone;
  String name;
  String email;
  List<Address> addresses;
  String? addressId;
  int pay;
  final DateTime created;

  Address? get defaultAddress {
    for (final a in addresses) {
      if (a.id == addressId) return a;
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  Json toJson() => {
        'phone': phone,
        'name': name,
        'email': email,
        'addresses': [for (final a in addresses) a.toJson()],
        'addressId': addressId,
        'pay': pay,
        'created': created.millisecondsSinceEpoch,
      };

  factory AppUser.fromJson(Json j) => AppUser(
        phone: _str(j['phone']),
        name: _str(j['name']),
        email: _str(j['email']),
        addresses: [for (final a in _maps(j['addresses'])) Address.fromJson(a)],
        addressId: j['addressId'] as String?,
        pay: _int(j['pay']),
        created: DateTime.fromMillisecondsSinceEpoch(_int(j['created'])),
      );
}

class OrderItem {
  OrderItem({
    required this.productId,
    required this.name,
    required this.option,
    required this.price,
    required this.qty,
    required this.image,
    required this.category,
  });

  final String productId;
  final String name;
  final String option;
  final int price;
  final int qty;
  final String image;
  final String category;

  int get total => price * qty;

  Json toJson() => {
        'productId': productId,
        'name': name,
        'option': option,
        'price': price,
        'qty': qty,
        'image': image,
        'category': category,
      };

  factory OrderItem.fromJson(Json j) => OrderItem(
        productId: _str(j['productId']),
        name: _str(j['name']),
        option: _str(j['option']),
        price: _int(j['price']),
        qty: _int(j['qty'], 1),
        image: _str(j['image']),
        category: _str(j['category']),
      );
}

/// Buyurtma holatlari: 0 qabul qilindi, 1 yig'ilmoqda, 2 yo'lda, 3 yetkazildi, 4 bekor qilindi.
class Order {
  Order({
    required this.no,
    required this.phone,
    required this.customer,
    required this.created,
    required this.items,
    required this.subtotal,
    required this.discount,
    this.promo,
    required this.delivery,
    required this.total,
    required this.address,
    required this.payment,
    this.status = 0,
    DateTime? updated,
  }) : updated = updated ?? created;

  final String no;
  final String phone;
  final String customer;
  final DateTime created;
  final List<OrderItem> items;
  final int subtotal;
  final int discount;
  final String? promo;
  final int delivery;
  final int total;
  final String address;
  final String payment;
  int status;
  DateTime updated;

  static const cancelled = 4;
  bool get isCancelled => status == cancelled;
  int get count => items.fold(0, (s, i) => s + i.qty);

  Json toJson() => {
        'no': no,
        'phone': phone,
        'customer': customer,
        'created': created.millisecondsSinceEpoch,
        'items': [for (final i in items) i.toJson()],
        'subtotal': subtotal,
        'discount': discount,
        'promo': promo,
        'delivery': delivery,
        'total': total,
        'address': address,
        'payment': payment,
        'status': status,
        'updated': updated.millisecondsSinceEpoch,
      };

  factory Order.fromJson(Json j) => Order(
        no: _str(j['no']),
        phone: _str(j['phone']),
        customer: _str(j['customer']),
        created: DateTime.fromMillisecondsSinceEpoch(_int(j['created'])),
        items: [for (final i in _maps(j['items'])) OrderItem.fromJson(i)],
        subtotal: _int(j['subtotal']),
        discount: _int(j['discount']),
        promo: j['promo'] as String?,
        delivery: _int(j['delivery']),
        total: _int(j['total']),
        address: _str(j['address']),
        payment: _str(j['payment']),
        status: _int(j['status']),
        updated: DateTime.fromMillisecondsSinceEpoch(_int(j['updated'])),
      );
}

enum PromoKind { percent, fixed, shipping }

class PromoCode {
  PromoCode({
    required this.code,
    required this.kind,
    this.value = 0,
    this.min = 0,
    required this.title,
    this.active = true,
  });

  String code;
  PromoKind kind;
  int value;
  int min;
  String title;
  bool active;

  String get badge => switch (kind) {
        PromoKind.percent => '−$value%',
        PromoKind.fixed => value >= 1000 ? '−${value ~/ 1000}K' : '−$value',
        PromoKind.shipping => '0',
      };

  Json toJson() => {'code': code, 'kind': kind.name, 'value': value, 'min': min, 'title': title, 'active': active};

  factory PromoCode.fromJson(Json j) => PromoCode(
        code: _str(j['code']),
        kind: PromoKind.values.firstWhere((k) => k.name == j['kind'], orElse: () => PromoKind.percent),
        value: _int(j['value']),
        min: _int(j['min']),
        title: _str(j['title']),
        active: j['active'] != false,
      );
}

class Settings {
  Settings({this.deliveryFee = 25000, this.freeFrom = 500000, this.adminPassword = 'admin123'});

  int deliveryFee;
  int freeFrom;
  String adminPassword;

  Json toJson() => {'deliveryFee': deliveryFee, 'freeFrom': freeFrom, 'adminPassword': adminPassword};
  factory Settings.fromJson(Json j) => Settings(
        deliveryFee: _int(j['deliveryFee'], 25000),
        freeFrom: _int(j['freeFrom'], 500000),
        adminPassword: _str(j['adminPassword'], 'admin123'),
      );
}
