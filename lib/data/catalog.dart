import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme.dart';

class Category {
  const Category(this.name, this.icon);

  final String name;
  final IconData icon;
}

const allCategory = 'Hammasi';

const categories = [
  Category(allCategory, Icons.grid_view_rounded),
  Category('Elektronika', Icons.headphones_rounded),
  Category('Poyabzal', Icons.directions_run_rounded),
  Category('Kiyim', Icons.checkroom_rounded),
  Category('Aksessuar', Icons.watch_rounded),
  Category("Go'zallik", Icons.spa_rounded),
  Category('Uy uchun', Icons.chair_rounded),
];

final productCategories = [for (final c in categories.skip(1)) c.name];

const _tiles = {
  'Elektronika': Color(0xFFE8EEF6),
  'Poyabzal': Color(0xFFF6ECE5),
  'Kiyim': Color(0xFFEDF0F5),
  'Aksessuar': Color(0xFFF3EDE4),
  "Go'zallik": Color(0xFFF7EAEF),
  'Uy uchun': Color(0xFFEAF1EA),
};

Color tileColor(String category) => _tiles[category] ?? const Color(0xFFECEFF3);

class PromoBanner {
  const PromoBanner(this.tag, this.title, this.colors, this.productId, this.category);

  final String tag;
  final String title;
  final List<Color> colors;
  final String productId;
  final String category;
}

const promoBanners = [
  PromoBanner('Kuzgi chegirmalar', 'Krossovkalarga −20% gacha', [Color(0xFFFF6B35), Color(0xFFFF9F43)], '88', 'Poyabzal'),
  PromoBanner('Apple haftaligi', "Gadjetlar 12 oyga bo'lib", [Color(0xFF14151A), Color(0xFF3A3D4A)], '101', 'Elektronika'),
  PromoBanner('Original atirlar', 'Chanel, Dior va Gucci', [Color(0xFF1F7A5A), Color(0xFF3BB27F)], '7', "Go'zallik"),
];

const payMethods = <(IconData, String)>[
  (Icons.credit_card_rounded, 'Click'),
  (Icons.account_balance_wallet_outlined, 'Payme'),
  (Icons.phone_iphone_rounded, 'Uzum Bank'),
  (Icons.schedule_rounded, "Muddatli to'lov, 12 oy"),
  (Icons.payments_outlined, 'Naqd pul (yetkazganda)'),
];

const orderStatuses = ['Qabul qilindi', "Yig'ilmoqda", "Yo'lda", 'Yetkazildi', 'Bekor qilindi'];

Color statusColor(int status) => switch (status) {
      0 || 1 => AppColors.accent,
      2 => AppColors.info,
      3 => AppColors.success,
      _ => AppColors.danger,
    };

const regions = [
  'Toshkent sh.', 'Toshkent viloyati', 'Andijon', 'Buxoro', "Farg'ona", 'Jizzax', 'Xorazm',
  'Namangan', 'Navoiy', 'Qashqadaryo', "Qoraqalpog'iston", 'Samarqand', 'Sirdaryo', 'Surxondaryo',
];

const addressKinds = <(String, IconData)>[
  ('Uy', Icons.home_rounded),
  ('Ish', Icons.work_rounded),
  ('Boshqa', Icons.place_rounded),
];

IconData addressIcon(String kind) {
  for (final k in addressKinds) {
    if (k.$1 == kind) return k.$2;
  }
  return Icons.place_rounded;
}

const faq = <(String, String)>[
  ('Buyurtma qancha vaqtda yetkaziladi?',
      "Toshkent shahri bo'ylab ertasi kuni, viloyatlarga 2–4 kun ichida yetkaziladi. Buyurtma holatini Profil → Buyurtmalarim bo'limida kuzatasiz."),
  ('Yetkazib berish narxi qancha?',
      "500 000 so'mdan ortiq xaridlarda bepul. Qolgan hollarda 25 000 so'm. BEPUL promokodi bilan har doim bepul."),
  ("Bo'lib to'lash qanday ishlaydi?",
      "Rasmiylashtirishda «Muddatli to'lov, 12 oy» usulini tanlang. Jami summa 12 oyga teng bo'linadi."),
  ('Mahsulotni qaytarsa bo\'ladimi?',
      "Kiyim va poyabzalni 14 kun ichida qaytarish yoki almashtirish mumkin: yorlig'i va qadog'i saqlangan bo'lishi kerak. Ochilgan atir va kosmetika qaytarilmaydi."),
  ('Kafolat bormi?',
      "Elektronika va maishiy texnikaga 1 yil, soatlarga 2 yilgacha kafolat beriladi. Muddat har bir mahsulot sahifasida yozilgan."),
  ('Promokodni qanday ishlataman?',
      "Savat sahifasidagi «Promokod» maydoniga kodni yozing yoki Profil → Promokodlar bo'limidan «Qo'llash» tugmasini bosing."),
];

List<PromoCode> seedPromos() => [
      PromoCode(code: 'BOZOR10', kind: PromoKind.percent, value: 10, title: 'Barcha mahsulotlarga 10% chegirma'),
      PromoCode(code: 'YANGI50', kind: PromoKind.fixed, value: 50000, min: 300000, title: "300 000 so'mdan ortiq xaridga 50 000 so'm chegirma"),
      PromoCode(code: 'BEPUL', kind: PromoKind.shipping, title: 'Istalgan xaridda yetkazib berish bepul'),
    ];

List<String> _imgs(String id, int count) => [for (var k = 1; k <= count; k++) 'assets/products/$id-$k.webp'];

OptionGroup _opt(String name, List<(String, int)> values) =>
    OptionGroup(name, [for (final v in values) OptionValue(v.$1, v.$2)]);

OptionGroup _sizes(String name, List<String> values) => OptionGroup(name, [for (final v in values) OptionValue(v, 0)]);

List<Spec> _specs(List<(String, String)> rows) => [for (final r in rows) Spec(r.$1, r.$2)];

/// Boshlang'ich katalog. Rasmlar: DummyJSON (dummyjson.com) studiya suratlari.
List<Product> seedProducts() => [
      Product(
        id: '123', name: 'iPhone 13 Pro', brand: 'Apple', category: 'Elektronika', images: _imgs('123', 3),
        price: 7490000, oldPrice: 8290000, rating: 4.8, reviews: 1240, stock: 56, warranty: '1 yil kafolat',
        option: _opt('Xotira', [('128 GB', 0), ('256 GB', 1100000), ('512 GB', 2600000)]),
        specs: _specs([
          ('Ekran', '6,1″ Super Retina XDR, 120 Hz'), ('Protsessor', 'A15 Bionic'), ('Kamera', '12 + 12 + 12 MP, 3× optik zum'),
          ('Batareya', '3095 mAh, 20 W tez quvvatlash'), ('Rang', 'Sierra Blue'), ('SIM', 'nanoSIM + eSIM'),
        ]),
        description: "ProMotion ekrani, uch kamerali tizimi va A15 Bionic protsessori bo'lgan smartfon. Tungi rejim, makro suratga olish va ProRAW formatini qo'llab-quvvatlaydi.",
      ),
      Product(
        id: '133', name: 'Galaxy S10', brand: 'Samsung', category: 'Elektronika', images: _imgs('133', 3),
        price: 3190000, oldPrice: 3690000, rating: 4.5, reviews: 860, stock: 19, warranty: '1 yil kafolat',
        option: _opt('Xotira', [('128 GB', 0), ('512 GB', 700000)]),
        specs: _specs([
          ('Ekran', '6,1″ Dynamic AMOLED, 3040 × 1440'), ('Protsessor', 'Exynos 9820'), ('Kamera', '12 + 12 + 16 MP'),
          ('Batareya', '3400 mAh, simsiz quvvatlash'), ('Barmoq izi', 'Ekran ostida, ultratovushli'),
        ]),
        description: "Chekkalari egilgan Dynamic AMOLED ekranli flagman. Uch kamera oddiy, keng burchakli va teleobyektiv suratlarni beradi.",
      ),
      Product(
        id: '78', name: 'MacBook Pro 14″ M1 Pro', brand: 'Apple', category: 'Elektronika', images: _imgs('78', 3),
        price: 21900000, oldPrice: 24500000, rating: 4.9, reviews: 412, stock: 24, warranty: '1 yil kafolat',
        option: _opt('Konfiguratsiya', [('16 GB / 512 GB', 0), ('16 GB / 1 TB', 2900000)]),
        specs: _specs([
          ('Protsessor', 'Apple M1 Pro, 8 yadroli CPU'), ('Ekran', '14,2″ Liquid Retina XDR, 120 Hz'), ('Batareya', '17 soatgacha video'),
          ('Portlar', '3 × Thunderbolt 4, HDMI, SDXC, MagSafe 3'), ("Og'irligi", '1,6 kg'), ('Rang', 'Space Grey'),
        ]),
        description: "Dizayn, montaj va dasturlash uchun professional noutbuk. Mini-LED ekran yuqori yorqinlik va chuqur qora rang beradi.",
      ),
      Product(
        id: '80', name: 'MateBook X Pro', brand: 'Huawei', category: 'Elektronika', images: _imgs('80', 3),
        price: 16400000, rating: 4.7, reviews: 205, stock: 75, warranty: '1 yil kafolat',
        specs: _specs([
          ('Ekran', '13,9″ 3K sensorli, 3000 × 2000'), ('Protsessor', 'Intel Core i7'), ('Xotira', '16 GB RAM / 1 TB SSD'),
          ('Batareya', '11 soatgacha'), ("Og'irligi", '1,33 kg'),
        ]),
        description: "Ramkasi deyarli yo'q sensorli ekranli yupqa metall noutbuk. Safar va ofis uchun qulay.",
      ),
      Product(
        id: '160', name: 'Galaxy Tab S8+', brand: 'Samsung', category: 'Elektronika', images: _imgs('160', 3),
        price: 8900000, oldPrice: 10200000, rating: 4.7, reviews: 318, stock: 62, warranty: '1 yil kafolat',
        option: _opt('Xotira', [('128 GB', 0), ('256 GB', 900000)]),
        specs: _specs([
          ('Ekran', '12,4″ Super AMOLED, 120 Hz'), ('Protsessor', 'Snapdragon 8 Gen 1'), ('S Pen', "To'plamda"),
          ('Batareya', '10 090 mAh, 45 W'), ('Kamera', '13 + 6 MP'),
        ]),
        description: "Katta AMOLED ekranli planshet: film ko'rish, chizish va hujjatlar bilan ishlash uchun. S Pen qalami to'plamda keladi.",
      ),
      Product(
        id: '101', name: 'AirPods Max', brand: 'Apple', category: 'Elektronika', images: _imgs('101', 1),
        price: 6990000, rating: 4.7, reviews: 590, stock: 59, warranty: '1 yil kafolat',
        specs: _specs([
          ('Shovqinni bostirish', 'Faol (ANC) va shaffof rejim'), ('Fazoviy ovoz', 'Bosh harakatini kuzatish bilan'),
          ('Batareya', '20 soatgacha'), ('Ulanish', 'Bluetooth 5.0, Lightning'), ("Og'irligi", '385 g'),
        ]),
        description: "Alyumin quloqchinlari va to'qilgan bosh kamarli to'liq o'lchamli quloqchinlar. Tashqi shovqinni bostiradi.",
      ),
      Product(
        id: '100', name: 'AirPods (2-avlod)', brand: 'Apple', category: 'Elektronika', images: _imgs('100', 3),
        price: 1690000, oldPrice: 1990000, rating: 4.6, reviews: 2310, stock: 67, warranty: '1 yil kafolat',
        specs: _specs([
          ('Chip', 'Apple H1'), ('Batareya', "5 soat, g'ilof bilan 24 soat"), ('Boshqaruv', 'Ikki marta bosish'), ('Ulanish', 'Bluetooth 5.0'),
        ]),
        description: "G'ilofni ochishingiz bilan iPhone'ga ulanadigan simsiz quloqchinlar. Quloqdan olsangiz, musiqa avtomatik to'xtaydi.",
      ),
      Product(
        id: '103', name: 'HomePod mini', brand: 'Apple', category: 'Elektronika', images: _imgs('103', 1),
        price: 1390000, rating: 4.6, reviews: 274, stock: 27, warranty: '1 yil kafolat',
        specs: _specs([
          ('Ovoz', '360° ovoz'), ('Chip', 'Apple S5'), ('Aqlli uy', 'Matter, Thread'), ('Ulanish', 'Wi-Fi, Bluetooth 5.0'), ('Quvvat', 'USB-C, 20 W'),
        ]),
        description: "Ixcham aqlli kolonka xonani 360° ovoz bilan to'ldiradi. Siri orqali musiqa va aqlli uy qurilmalarini boshqarasiz.",
      ),
      Product(
        id: '88', name: 'Air Jordan 1 Mid «Chicago»', brand: 'Nike', category: 'Poyabzal', images: _imgs('88', 3),
        price: 1890000, oldPrice: 2290000, rating: 4.9, reviews: 640, stock: 7, warranty: '14 kun almashtirish',
        option: _sizes("O'lcham (EU)", ['40', '41', '42', '43', '44', '45']),
        specs: _specs([('Ustki qismi', 'Tabiiy charm'), ('Taglik', 'Rezina, Air yostiqchasi'), ('Turi', 'Baland krossovka'), ('Rang', 'Qizil / oq / qora')]),
        description: "Basketbol tarixidagi eng mashhur krossovkalardan biri, klassik «Chicago» ranglarida. Air yostiqchasi har qadamni yumshatadi.",
      ),
      Product(
        id: '90', name: 'Future Rider Play On', brand: 'Puma', category: 'Poyabzal', images: _imgs('90', 3),
        price: 990000, oldPrice: 1190000, rating: 4.6, reviews: 388, stock: 90, warranty: '14 kun almashtirish',
        option: _sizes("O'lcham (EU)", ['39', '40', '41', '42', '43', '44']),
        specs: _specs([('Ustki qismi', 'Neylon va zamsh'), ('Taglik', "EVA ko'pik, rezina"), ('Turi', 'Kundalik krossovka')]),
        description: "80-yillar yugurish krossovkalari uslubidagi yengil model. Ko'pikli taglik kun bo'yi yurganda ham qulay.",
      ),
      Product(
        id: '91', name: 'Out Of Office', brand: 'Off-White', category: 'Poyabzal', images: _imgs('91', 3),
        price: 4690000, rating: 4.8, reviews: 96, stock: 17, warranty: '14 kun almashtirish',
        option: _sizes("O'lcham (EU)", ['40', '41', '42', '43', '44', '45']),
        specs: _specs([('Ustki qismi', 'Charm'), ('Taglik', 'Rezina, ikki rangli'), ('Turi', 'Past krossovka'), ('Rang', 'Oq / qizil')]),
        description: "Yon tomonida brendning mashhur o'q belgisi tushirilgan past krossovka. Ko'cha uslubining asosiy buyumi.",
      ),
      Product(
        id: '186', name: 'Poshnali tufli', brand: 'Calvin Klein', category: 'Poyabzal', images: _imgs('186', 3),
        price: 1290000, rating: 4.7, reviews: 152, stock: 93, warranty: '14 kun almashtirish',
        option: _sizes("O'lcham (EU)", ['36', '37', '38', '39', '40']),
        specs: _specs([('Ustki qismi', 'Tabiiy charm'), ('Poshna balandligi', '8 sm'), ('Kimlar uchun', 'Ayollar')]),
        description: "Rasmiy tadbirlar va ofis uchun nafis tufli. Barqaror poshna va yumshoq ichki qatlam oyoqni charchatmaydi.",
      ),
      Product(
        id: '189', name: 'Qizil lak tufli', brand: 'Fashion Express', category: 'Poyabzal', images: _imgs('189', 3),
        price: 549000, oldPrice: 690000, rating: 4.5, reviews: 211, stock: 7, warranty: '14 kun almashtirish',
        option: _sizes("O'lcham (EU)", ['36', '37', '38', '39', '40']),
        specs: _specs([('Ustki qismi', 'Lak ekocharm'), ('Poshna balandligi', '7 sm'), ('Kimlar uchun', 'Ayollar')]),
        description: "Yorqin qizil rangdagi klassik «lodochka» tufli. Bayram va kechki ko'ylaklar bilan juda mos tushadi.",
      ),
      Product(
        id: '83', name: "Katakli ko'ylak", brand: 'Fashion Trends', category: 'Kiyim', images: _imgs('83', 3),
        price: 289000, oldPrice: 359000, rating: 4.5, reviews: 734, stock: 38, warranty: '14 kun qaytarish',
        option: _sizes("O'lcham", ['S', 'M', 'L', 'XL', 'XXL']),
        specs: _specs([('Tarkibi', '100% paxta'), ('Bichimi', 'Regular fit'), ('Parvarishi', '30 °C da yuvish')]),
        description: "Ko'k-qora katakli uzun yengli erkaklar ko'ylagi. Paxta mato nafas oladi va kun bo'yi qulay.",
      ),
      Product(
        id: '85', name: "Erkaklar flanel ko'ylagi", brand: 'Classic Wear', category: 'Kiyim', images: _imgs('85', 3),
        price: 329000, rating: 4.4, reviews: 402, stock: 82, warranty: '14 kun qaytarish',
        option: _sizes("O'lcham", ['S', 'M', 'L', 'XL']),
        specs: _specs([('Tarkibi', '70% paxta, 30% poliester'), ('Bichimi', 'Slim fit'), ('Mavsum', 'Kuz va qish')]),
        description: "Issiq va yumshoq flanel matodan tikilgan ko'ylak. Alohida ham, futbolka ustidan ham kiyiladi.",
      ),
      Product(
        id: '177', name: "Gulli kechki ko'ylak", brand: 'Bozor Collection', category: 'Kiyim', images: _imgs('177', 3),
        price: 1490000, oldPrice: 1890000, rating: 4.8, reviews: 128, stock: 25, warranty: '14 kun qaytarish',
        option: _sizes("O'lcham", ['XS', 'S', 'M', 'L']),
        specs: _specs([('Material', "Atlas va to'r"), ('Uzunligi', 'Maksi'), ('Yelka', 'Ochiq yelkali')]),
        description: "Qora fonda yirik atirgullar tushirilgan uzun kechki ko'ylak. Bayram va to'ylar uchun mos.",
      ),
      Product(
        id: '181', name: "Trikotaj ko'ylak", brand: 'Marni', category: 'Kiyim', images: _imgs('181', 3),
        price: 9800000, rating: 4.7, reviews: 41, stock: 6, warranty: '14 kun qaytarish',
        option: _sizes("O'lcham", ['XS', 'S', 'M', 'L']),
        specs: _specs([('Material', 'Jun aralashmasi'), ('Rangi', 'Bordo, pushti va oq yenglar'), ('Uzunligi', 'Midi')]),
        description: "Har xil rangdagi yenglari bilan ajralib turadigan trikotaj ko'ylak, Italiya modasining rang bloklari uslubida.",
      ),
      Product(
        id: '94', name: 'Master Collection', brand: 'Longines', category: 'Aksessuar', images: _imgs('94', 3),
        price: 31500000, rating: 4.9, reviews: 63, stock: 4, warranty: '2 yil xalqaro kafolat',
        specs: _specs([
          ('Mexanizm', 'Avtomatik, L888'), ('Korpus', "40 mm, zanglamaydigan po'lat"), ('Oyna', 'Safir'),
          ('Suvga chidamlilik', '30 m'), ('Quvvat zaxirasi', '72 soat'),
        ]),
        description: "Shveytsariya soatsozligining klassik namunasi. Avtomatik mexanizm qo'l harakatidan quvvat oladi.",
      ),
      Product(
        id: '106', name: 'Watch Series 4, Gold', brand: 'Apple', category: 'Aksessuar', images: _imgs('106', 3),
        price: 2490000, oldPrice: 2990000, rating: 4.5, reviews: 980, stock: 33, warranty: '1 yil kafolat',
        option: _opt('Korpus', [('40 mm', 0), ('44 mm', 300000)]),
        specs: _specs([('Ekran', 'LTPO OLED Retina'), ('Sensorlar', 'EKG, yurak urishi, yiqilishni aniqlash'), ('Suvga chidamlilik', '50 m'), ('Batareya', '18 soatgacha')]),
        description: "Sog'liq va mashg'ulotlarni kuzatadigan aqlli soat. Telefondagi bildirishnomalarni bilagingizda ko'rasiz.",
      ),
      Product(
        id: '154', name: "Qora quyosh ko'zoynagi", brand: 'Fashion Shades', category: 'Aksessuar', images: _imgs('154', 3),
        price: 349000, rating: 4.6, reviews: 287, stock: 60, warranty: '14 kun qaytarish',
        specs: _specs([('Linza', 'Polarizatsiyalangan, UV400'), ('Ramka', 'Atsetat'), ('Kimlar uchun', 'Uniseks')]),
        description: "Klassik shakldagi qora ko'zoynak. Polarizatsiyalangan linzalar quyosh nuri va yaltirashni kamaytiradi.",
      ),
      Product(
        id: '173', name: 'Charm ayollar sumkasi', brand: 'Heshe', category: 'Aksessuar', images: _imgs('173', 3),
        price: 1690000, oldPrice: 1990000, rating: 4.8, reviews: 176, stock: 12, warranty: '6 oy kafolat',
        specs: _specs([('Material', 'Tabiiy charm'), ("O'lchami", '29 × 21 × 7 sm'), ("Bo'limlar", "3 ta, zamokli cho'ntak")]),
        description: "Kundalik foydalanish uchun ixcham charm sumka. Uzun kamar bilan yelkada ham, qo'lda ham olib yuriladi.",
      ),
      Product(
        id: '174', name: 'Saffiano charm sumka', brand: 'Prada', category: 'Aksessuar', images: _imgs('174', 3),
        price: 26900000, rating: 4.9, reviews: 38, stock: 3, warranty: '2 yil kafolat',
        specs: _specs([('Material', 'Saffiano charm'), ('Furnitura', 'Metall logotip'), ("To'plamda", "Chang qopqog'i va sertifikat")]),
        description: "Brendning tanilgan Saffiano charmidan tikilgan sumka. Charm tirnalish va namlikka chidamli.",
      ),
      Product(
        id: '175', name: 'Oq ayollar ryukzagi', brand: 'Urban Chic', category: 'Aksessuar', images: _imgs('175', 3),
        price: 459000, oldPrice: 590000, rating: 4.5, reviews: 341, stock: 39, warranty: '14 kun qaytarish',
        specs: _specs([('Material', 'Ekocharm'), ('Hajmi', '12 l'), ('Yopilishi', "Qopqoq va bog'ich")]),
        description: "Shahar uchun yengil va zamonaviy ryukzak. Universitet va sayr uchun qulay.",
      ),
      Product(
        id: '7', name: 'Coco Noir', brand: 'Chanel', category: "Go'zallik", images: _imgs('7', 3),
        price: 2290000, rating: 4.9, reviews: 512, stock: 58, warranty: 'Original mahsulot',
        option: _opt('Hajmi', [('50 ml', 0), ('100 ml', 950000)]),
        specs: _specs([('Turi', 'Eau de Parfum'), ('Notalari', 'Greypfrut, atirgul, pachuli, vanil'), ('Kimlar uchun', 'Ayollar')]),
        description: "Sirli va nafis kechki atir. Boshida sitrus yangiligi, oxirida iliq pachuli va vanil hidi qoladi.",
      ),
      Product(
        id: '8', name: "J'adore", brand: 'Dior', category: "Go'zallik", images: _imgs('8', 3),
        price: 1790000, oldPrice: 2090000, rating: 4.8, reviews: 744, stock: 98, warranty: 'Original mahsulot',
        option: _opt('Hajmi', [('50 ml', 0), ('100 ml', 790000)]),
        specs: _specs([('Turi', 'Eau de Parfum'), ('Notalari', 'Ilang-ilang, Damashq atirguli, yasmin'), ('Kimlar uchun', 'Ayollar')]),
        description: "Dior'ning eng mashhur gulli atirlaridan biri. Kunduzgi va kechki tadbirlarga birdek mos.",
      ),
      Product(
        id: '6', name: 'CK One', brand: 'Calvin Klein', category: "Go'zallik", images: _imgs('6', 3),
        price: 690000, rating: 4.6, reviews: 1102, stock: 29, warranty: 'Original mahsulot',
        option: _opt('Hajmi', [('100 ml', 0), ('200 ml', 320000)]),
        specs: _specs([('Turi', 'Eau de Toilette'), ('Notalari', 'Bergamot, yashil choy, mushk'), ('Kimlar uchun', 'Uniseks')]),
        description: "90-yillardan beri sevimli toza va yangi hid. Ayollar ham, erkaklar ham kiyadi.",
      ),
      Product(
        id: '10', name: 'Bloom', brand: 'Gucci', category: "Go'zallik", images: _imgs('10', 3),
        price: 1590000, oldPrice: 1890000, rating: 4.7, reviews: 367, stock: 91, warranty: 'Original mahsulot',
        option: _opt('Hajmi', [('50 ml', 0), ('100 ml', 650000)]),
        specs: _specs([('Turi', 'Eau de Parfum'), ('Notalari', 'Tuberoza, yasmin, Rangoon gulzori'), ('Kimlar uchun', 'Ayollar')]),
        description: "Gullagan bog' hidini eslatuvchi boy gulli atir. Pushti flakon sovg'a uchun ham chiroyli.",
      ),
      Product(
        id: '119', name: 'Ultra Moisture dush geli', brand: 'Olay', category: "Go'zallik", images: _imgs('119', 3),
        price: 119000, oldPrice: 149000, rating: 4.7, reviews: 1460, stock: 34, warranty: 'Yaroqlilik: 3 yil',
        specs: _specs([('Hajmi', '700 ml'), ('Tarkibi', "Shi yog'i, B3 vitamini"), ('Teri turi', 'Quruq va oddiy')]),
        description: "Shi yog'li namlantiruvchi dush geli. Terini quritmaydi, yumshoq va silliq qoldiradi.",
      ),
      Product(
        id: '51', name: 'Statsionar blender 1,5 l', brand: 'HomeChef', category: 'Uy uchun', images: _imgs('51', 3),
        price: 589000, oldPrice: 749000, rating: 4.7, reviews: 523, stock: 9, warranty: '1 yil kafolat',
        specs: _specs([('Quvvati', '600 W'), ('Idish hajmi', '1,5 l'), ('Tezliklar', '2 + impuls rejimi'), ('Pichoqlar', "Zanglamaydigan po'lat")]),
        description: "Smuzi, kokteyl, pyure va muz maydalash uchun blender. Idishdagi o'lchov shkalasi retseptni aniq bajarishga yordam beradi.",
      ),
      Product(
        id: '66', name: "Mikroto'lqinli pech 20 l", brand: 'HomeChef', category: 'Uy uchun', images: _imgs('66', 3),
        price: 1090000, rating: 4.8, reviews: 690, stock: 59, warranty: '1 yil kafolat',
        specs: _specs([('Hajmi', '20 l'), ('Quvvati', '700 W'), ('Boshqaruv', 'Mexanik'), ('Taymer', '30 daqiqagacha')]),
        description: "Ovqat isitish va muzlatilgan mahsulotlarni eritish uchun oddiy va ishonchli pech.",
      ),
      Product(
        id: '47', name: "«Palma» stol chirog'i", brand: 'Decora', category: 'Uy uchun', images: _imgs('47', 1),
        price: 489000, rating: 4.6, reviews: 84, stock: 9, warranty: '6 oy kafolat',
        specs: _specs([('Abajur', "Mato, to'q sariq"), ('Lampochka', 'E27, 60 W gacha'), ('Balandligi', '64 sm')]),
        description: "Palma daraxti shaklidagi dekorativ chiroq. Yotoqxona yoki mehmonxonaga iliq, yumshoq yorug'lik beradi.",
      ),
    ];
