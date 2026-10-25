/// 1250000 -> "1 250 000"
String group3(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer(negative ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// 1250000 -> "1 250 000 so'm"
String formatPrice(int value) => "${group3(value)} so'm";

/// 12 oyga bo'lib to'lashdagi oylik summa, mingtagacha yaxlitlangan.
int monthly(int total) => (total / 12 / 1000).ceil() * 1000;

/// Grafik yorliqlari uchun qisqa yozuv: 1 250 000 -> "1,3 mln".
String compactPrice(int value) {
  if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1).replaceAll('.', ',')} mln";
  if (value >= 1000) return '${(value / 1000).round()} ming';
  return '$value';
}

/// "901234567" -> "90 123 45 67"
String formatPhone(String digits) {
  final parts = <String>[];
  const cuts = [0, 2, 5, 7, 9];
  for (var i = 0; i < cuts.length - 1; i++) {
    if (digits.length <= cuts[i]) break;
    final end = digits.length < cuts[i + 1] ? digits.length : cuts[i + 1];
    parts.add(digits.substring(cuts[i], end));
  }
  return parts.join(' ');
}

String fullPhone(String digits) => '+998 ${formatPhone(digits)}';

String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime t) => '${_two(t.day)}.${_two(t.month)}.${t.year}, ${_two(t.hour)}:${_two(t.minute)}';

String initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}
