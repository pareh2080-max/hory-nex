import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _money = NumberFormat.currency(
      locale: 'fr_FR', symbol: 'HTG ', decimalDigits: 2);
  static final _dateFr = DateFormat('dd/MM/yyyy');
  static final _dateHeure = DateFormat('dd/MM/yyyy HH:mm');

  static String money(num value) => _money.format(value);

  static String date(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    return d == null ? iso : _dateFr.format(d);
  }

  static String dateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    return d == null ? iso : _dateHeure.format(d);
  }
}
