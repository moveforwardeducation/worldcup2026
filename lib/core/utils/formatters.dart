import 'package:intl/intl.dart';

final NumberFormat _kNum = NumberFormat.decimalPattern();

String formatNumber(num value) => _kNum.format(value);
