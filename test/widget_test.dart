import 'package:flutter_test/flutter_test.dart';
import 'package:online_shop/data/catalog.dart';
import 'package:online_shop/models/models.dart';
import 'package:online_shop/state/shop_state.dart';
import 'package:online_shop/utils/format.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ShopState> freshState() async {
  SharedPreferences.setMockInitialValues({});
  return ShopState(await SharedPreferences.getInstance());
}

void main() {
  test('formatlash', () {
    expect(formatPrice(1250000), "1 250 000 so'm");
    expect(formatPrice(900), "900 so'm");
    expect(formatPhone('901234567'), '90 123 45 67');
    expect(monthly(1200000), 100000);
    expect(initials('Aziz Karimov'), 'AK');
  });

  test('katalog to\'liq', () {
    final products = seedProducts();
    expect(products.length, 31);
    expect(products.map((p) => p.id).toSet().length, 31);
    for (final p in products) {
      expect(p.images, isNotEmpty, reason: p.id);
      expect(productCategories, contains(p.category), reason: p.id);
    }
  });

  test('savat, promokod va yetkazish', () async {
    final shop = await freshState();
    final tee = shop.byId('83')!; // 289 000
    shop.addToCart(tee, opt: 1);
    shop.addToCart(tee, opt: 1);
    expect(shop.cart.length, 1);
    shop.setQty(shop.cart.first, 1);
    expect(shop.cartCount, 1);
    expect(shop.totals.delivery, 25000);

    expect(shop.applyPromo('yo\'q'), isNotNull);
    expect(shop.applyPromo('bozor10'), isNull);
    expect(shop.totals.discount, 28900);

    final phone = shop.byId('123')!;
    shop.addToCart(phone, opt: 1); // 7 490 000 + 1 100 000
    expect(shop.totals.delivery, 0);
    expect(shop.subtotal, 289000 + 8590000);
  });

  test("ro'yxatdan o'tish, buyurtma va admin", () async {
    final shop = await freshState();
    shop.register(name: 'Aziz Karimov', phone: '901234567');
    shop.addAddress(Address(id: 'a1', kind: 'Uy', region: 'Toshkent sh.', text: "Amir Temur ko'chasi, 108"));
    final watch = shop.byId('94')!;
    final stock = watch.stock;
    shop.addToCart(watch);
    final order = shop.placeOrder(address: shop.user!.addresses.first, pay: 0);

    expect(shop.cart, isEmpty);
    expect(shop.myOrders.single.no, order.no);
    expect(watch.stock, stock - 1);

    expect(shop.adminLogin('xato'), isFalse);
    expect(shop.adminLogin('admin123'), isTrue);
    shop.setOrderStatus(order, Order.cancelled);
    expect(watch.stock, stock);
    expect(shop.revenue, 0);

    final n = shop.addSampleOrders();
    expect(shop.orders.length, n + 1);
  });
}
