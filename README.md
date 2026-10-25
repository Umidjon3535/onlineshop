# Bozor — online magazin va admin panel (Flutter)

Zamonaviy dizayndagi online do'kon. Android ilovasi xaridor qismi va admin paneldan iborat.

## APK'ni yuklab olish

[**Releases**](../../releases/latest) bo'limidan eng so'nggi `Bozor.apk` faylini telefonga yuklab oling va o'rnating.
Telefon «noma'lum manbadan o'rnatish»ga ruxsat so'rasa, ruxsat bering.

Har safar `main` tarmog'iga o'zgarish yuklanganda GitHub Actions yangi APK yasab, Releases'ga qo'yadi.

## Xaridor uchun

- **Katalog:** 31 ta mahsulot, 6 ta toifa, qidiruv, saralash, aksiya bannerlari
- **Mahsulot sahifasi:** rasmlar galereyasi, variantlar (xotira, o'lcham, hajm) narxi bilan, xususiyatlar jadvali, ombordagi qoldiq, kafolat
- **Savat:** miqdor, promokod, bepul yetkazishgacha qolgan summa, 12 oyga bo'lib to'lash hisobi
- **Ro'yxatdan o'tish va kirish:** telefon raqam va tasdiqlash kodi (namuna rejimda kod ekranda ko'rsatiladi)
- **Rasmiylashtirish:** manzil, to'lov usuli (Click, Payme, Uzum Bank, muddatli to'lov, naqd)
- **Profil:** buyurtmalar va ularning holati, manzillar, to'lov usullari, promokodlar, bildirishnomalar, yordam markazi

## Admin panel

Profil → **Admin panel**. Standart parol: `admin123` (Sozlamalar bo'limida o'zgartiring).

- **Panel:** jami tushum, buyurtmalar, o'rtacha chek, mijozlar, so'nggi 7 kunlik tushum grafigi, kam qolgan mahsulotlar
- **Buyurtmalar:** holat bo'yicha filtr, qidiruv, holatni o'zgartirish (bekor qilinsa mahsulot omborga qaytadi)
- **Mahsulotlar:** qo'shish, tahrirlash, o'chirish, yashirish; galereyadan rasm qo'shish, variantlar va xususiyatlar
- **Mijozlar:** ro'yxat, xarid summasi va buyurtmalari
- **Sozlamalar:** promokodlar, yetkazib berish narxi, admin paroli, namuna buyurtmalar, ma'lumotlarni tiklash

## Muhim

- Hamma ma'lumot **telefonning o'zida** saqlanadi (SharedPreferences). Server yo'q: admin panel va xaridor bitta qurilmada ishlaydi.
  Haqiqiy do'kon uchun backend (masalan, Firebase yoki o'z serveringiz) va SMS xizmati ulanishi kerak.
- To'lov olinmaydi, SMS yuborilmaydi — bu namuna rejim.
- Mahsulot rasmlari: [DummyJSON](https://dummyjson.com) studiya suratlari. Narx va reytinglar taxminiy namuna.

## Kompyuterda ishga tushirish

```
flutter create . --project-name online_shop --org uz.bozor --platforms android
flutter pub get
flutter run
```

## Tuzilma

```
lib/
  main.dart                ilova kirish nuqtasi
  theme.dart               ranglar va mavzu
  models/models.dart       Product, Order, AppUser, PromoCode, Settings ...
  data/catalog.dart        boshlang'ich katalog, toifalar, promokodlar
  state/shop_state.dart    butun mantiq va saqlash
  screens/                 xaridor ekranlari
  admin/                   admin panel ekranlari
  widgets/                 umumiy vidjetlar
assets/products/           mahsulot rasmlari
```
