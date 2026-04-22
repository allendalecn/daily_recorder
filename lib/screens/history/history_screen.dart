import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lunar/lunar.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../daily_summary/daily_summary_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _focusedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedMonth = DateTime.now();
    });
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = firstDay.weekday % 7;

    final days = <DateTime>[];
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(month.year, month.month, 0 - i));
    }
    days.sort((a, b) => a.compareTo(b));

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    final remaining = 7 - (days.length % 7);
    if (remaining < 7) {
      for (int i = 1; i <= remaining; i++) {
        days.add(DateTime(month.year, month.month + 1, i));
      }
    }

    return days;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String? _getHolidayName(DateTime day) {
    final solar = Solar.fromYmd(day.year, day.month, day.day);

    // 法定节假日优先
    final holiday = HolidayUtil.getHolidayByYmd(day.year, day.month, day.day);
    if (holiday != null) {
      return holiday.getName();
    }

    // 阳历节日
    final solarFestivals = solar.getFestivals();
    if (solarFestivals.isNotEmpty) {
      return solarFestivals.first;
    }

    // 农历节日
    final lunarFestivals = solar.getLunar().getFestivals();
    if (lunarFestivals.isNotEmpty) {
      return lunarFestivals.first;
    }

    return null;
  }

  bool _isWorkDay(DateTime day) {
    final holiday = HolidayUtil.getHolidayByYmd(day.year, day.month, day.day);
    if (holiday != null) {
      return holiday.isWork();
    }
    final week = Solar.fromYmd(day.year, day.month, day.day).getWeek();
    return week != 0 && week != 6;
  }

  bool _isHoliday(DateTime day) {
    final holiday = HolidayUtil.getHolidayByYmd(day.year, day.month, day.day);
    if (holiday != null) {
      return !holiday.isWork();
    }
    final week = Solar.fromYmd(day.year, day.month, day.day).getWeek();
    return week == 0 || week == 6;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final days = _daysInMonth(_focusedMonth);
    final recordMap = <String, DailyRecord>{};
    for (final r in state.records) {
      recordMap['${r.date.year}-${r.date.month}-${r.date.day}'] = r;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousMonth,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '${_focusedMonth.year}年${_focusedMonth.month}月',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: _nextMonth,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _goToToday,
                      icon: const Icon(Icons.today, size: 18),
                      label: const Text('今天'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _WeekdayLabel('日'),
                      _WeekdayLabel('一'),
                      _WeekdayLabel('二'),
                      _WeekdayLabel('三'),
                      _WeekdayLabel('四'),
                      _WeekdayLabel('五'),
                      _WeekdayLabel('六'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final isCurrentMonth = day.month == _focusedMonth.month;
                      final record = recordMap['${day.year}-${day.month}-${day.day}'];
                      final hasRecord = record != null;
                      final isToday = _sameDay(day, DateTime.now());
                      final holidayName = _getHolidayName(day);
                      final isHoliday = _isHoliday(day);
                      final isWork = !isHoliday && !_isWorkDay(day);

                      return _DayCell(
                        day: day.day,
                        isCurrentMonth: isCurrentMonth,
                        hasRecord: hasRecord,
                        isToday: isToday,
                        recordCount: record?.totalEntryCount ?? 0,
                        holidayName: holidayName,
                        isHoliday: isHoliday,
                        isWork: isWork,
                        onTap: hasRecord
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DailySummaryScreen(dailyRecord: record),
                                  ),
                                )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool hasRecord;
  final bool isToday;
  final int recordCount;
  final String? holidayName;
  final bool isHoliday;
  final bool isWork;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.hasRecord,
    required this.isToday,
    required this.recordCount,
    this.holidayName,
    required this.isHoliday,
    required this.isWork,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? bgColor;
    if (isToday) {
      bgColor = colorScheme.primaryContainer;
    } else if (isHoliday && isCurrentMonth) {
      bgColor = colorScheme.errorContainer.withOpacity(0.3);
    }

    Color textColor;
    if (!isCurrentMonth) {
      textColor = colorScheme.onSurfaceVariant.withOpacity(0.4);
    } else if (isHoliday) {
      textColor = colorScheme.error;
    } else {
      textColor = colorScheme.onSurface;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
            if (holidayName != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  holidayName!,
                  style: TextStyle(
                    fontSize: 9,
                    color: isHoliday ? colorScheme.error : colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else if (hasRecord)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
