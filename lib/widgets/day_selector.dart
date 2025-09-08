import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as date_utils;

class DaySelector extends StatelessWidget {
  final List<String> dates;
  final String selectedDate;
  final Function(String) onDateSelect;
  final bool isOpen;
  final VoidCallback onClose;
  final bool compact;

  const DaySelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelect,
    required this.isOpen,
    required this.onClose,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOpen) return const SizedBox.shrink();

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final currentWeek = date_utils.DateUtils.getWeekNumber(today);

    final filtered = dates
        .map(DateTime.parse)
        .where((d) =>
            d.weekday != DateTime.saturday && d.weekday != DateTime.sunday)
        .map((d) {
      final isToday = date_utils.DateUtils.isSameDay(d, today);
      final isTomorrow = date_utils.DateUtils.isSameDay(d, tomorrow);
      final isCurrentWeek =
          date_utils.DateUtils.getWeekNumber(d) == currentWeek;

      return {
        'date': d.toIso8601String().split('T')[0],
        'displayText': isToday
            ? 'Heute'
            : isTomorrow
                ? 'Morgen'
                : isCurrentWeek
                    ? date_utils.DateUtils.getGermanDayOfWeek(d)
                    : '${date_utils.DateUtils.getGermanDayOfWeek(d)}, ${date_utils.DateUtils.formatGermanDate(d)}'
      };
    }).toList();

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: compact ? 200.0 : 300.0,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  'Datum auswählen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final item = filtered[i];
                  final isSel = item['date'] == selectedDate;
                  return InkWell(
                    onTap: () => onDateSelect(item['date']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? Colors.blue.withValues(
                                red: 0, green: 0, blue: 255, alpha: 0.1)
                            : null,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['displayText']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSel ? Colors.blue : Colors.black87,
                                fontWeight:
                                    isSel ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSel)
                            const Icon(
                              Icons.check,
                              color: Colors.blue,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
