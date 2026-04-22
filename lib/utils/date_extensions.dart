import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String get shortFormatted => DateFormat('yyyy/MM/dd').format(this);

  String get weekdayFormatted => DateFormat('EEEE, MMMd', 'zh_CN').format(this);

  String get timeFormatted => DateFormat('HH:mm').format(this);
}
