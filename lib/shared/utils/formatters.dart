import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _dateShort = DateFormat('EEE, MMM d');
  static final _dateWithYear = DateFormat('MMM d, yyyy');
  static final _time = DateFormat('HH:mm');

  static String dateShort(DateTime date) => _dateShort.format(date);
  static String dateWithYear(DateTime date) => _dateWithYear.format(date);
  static String time(DateTime date) => _time.format(date);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s';
    return '${s}s';
  }

  static String stopwatch(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  static String volume(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}t';
    return '${kg.toStringAsFixed(0)} kg';
  }

  static String rpe(double value) => value.toStringAsFixed(1);

  static String exerciseCount(int n) => n == 1 ? '1 exercise' : '$n exercises';
  static String setCount(int n) => n == 1 ? '1 set' : '$n sets';
}
