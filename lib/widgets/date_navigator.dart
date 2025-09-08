import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class DateNavigator extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;

  const DateNavigator({super.key, this.initialDate, this.onDateChanged});

  @override
  State<DateNavigator> createState() => _DateNavigatorState();
}

class _DateNavigatorState extends State<DateNavigator> {
  late DateTime _selectedDate;
  late DateTime _minDate;
  late DateTime _maxDate;

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isWeekend(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  DateTime _mondayOf(DateTime d) {
    final local = _startOfDay(d);
    return local.subtract(Duration(days: local.weekday - DateTime.monday));
  }

  DateTime _fridayOf(DateTime d) {
    final mon = _mondayOf(d);
    return mon.add(const Duration(days: 4));
  }

  DateTime _nextWeekMonday(DateTime d) =>
      _mondayOf(d).add(const Duration(days: 7));

  DateTime _snapToWeekday(DateTime d) {
    if (!_isWeekend(d)) return d;
    // Snap Saturday/Sunday forward to Monday if within range, else back to Friday
    final forward = _startOfDay(d)
        .add(Duration(days: DateTime.monday - d.weekday + 7))
        .subtract(const Duration(days: 7));
    // forward computed is next Monday of the same weekend; simpler:
    final nextMon = _startOfDay(d).add(Duration(days: (8 - d.weekday) % 7));
    if (!nextMon.isAfter(_maxDate)) return nextMon;
    // else snap back to previous Friday
    final prevFri = _startOfDay(d)
        .subtract(Duration(days: (d.weekday - DateTime.friday + 7) % 7));
    if (!prevFri.isBefore(_minDate)) return prevFri;
    // As last resort clamp within bounds
    return d.isBefore(_minDate) ? _minDate : _maxDate;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final thisMonday = _mondayOf(now);
    final nextFriday = _fridayOf(thisMonday.add(const Duration(days: 7)));
    _minDate = thisMonday;
    _maxDate = nextFriday;

    final init = widget.initialDate ?? _startOfDay(now);
    final clamped = init.isBefore(_minDate)
        ? _minDate
        : init.isAfter(_maxDate)
            ? _maxDate
            : init;
    _selectedDate = _snapToWeekday(clamped);
  }

  void _notify() {
    if (widget.onDateChanged != null) {
      widget.onDateChanged!(_selectedDate);
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Abbrechen',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const Text(
                        'Datum auswählen',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context, _selectedDate);
                        },
                        child: const Text(
                          'Fertig',
                          style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Date picker
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: _selectedDate,
                    minimumDate: _minDate,
                    maximumDate: _maxDate,
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime newDate) {
                      // Clamp and snap to weekday within bounds
                      DateTime d = _startOfDay(newDate);
                      if (d.isBefore(_minDate)) d = _minDate;
                      if (d.isAfter(_maxDate)) d = _maxDate;
                      d = _snapToWeekday(d);
                      setState(() => _selectedDate = d);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      final snapped = _snapToWeekday(_startOfDay(picked));
      setState(() {
        _selectedDate = snapped;
      });
      _notify();
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d. MMMM', 'de_DE').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Heute',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Select button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CupertinoColors.activeBlue,
            borderRadius: BorderRadius.circular(8),
            onPressed: _selectDate,
            child: const Text(
              'Ändern',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
