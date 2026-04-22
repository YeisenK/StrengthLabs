import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/exercise.dart';
import 'package:strengthlabs_beta/features/workouts/domain/entities/workout.dart';

class ExportResult {
  const ExportResult({required this.rowCount, required this.path, required this.shared});
  final int rowCount;
  final String path;
  final bool shared;
}

class ExportService {
  static final _dateFmt = DateFormat('yyyy-MM-dd');
  // ignore: unused_field
  static final _filenameFmt = DateFormat('yyyyMMdd');

  bool get _isDesktop =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  static const _headers = [
    'Date',
    'Workout',
    'Exercise',
    'Muscle Group',
    'Set #',
    'Weight (kg)',
    'Reps',
    'RPE',
    'Volume (kg)',
  ];

  /// Exports [workouts] to a .csv file. On mobile opens the share sheet;
  /// on desktop saves to the user's Downloads folder.
  Future<ExportResult> exportToCsv(List<Workout> workouts) async {
    final rows = _buildRows(workouts);
    final buffer = StringBuffer();

    // Header
    buffer.writeln(_headers.join(','));

    // Data rows
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCsvField).join(','));
    }

    final file = await _writeFile(
      'strengthlabs_export.csv',
      buffer.toString().codeUnits,
    );
    final shared = await _maybeShare(file, 'text/csv');
    return ExportResult(rowCount: rows.length, path: file.path, shared: shared);
  }

  /// Exports [workouts] to a .xlsx file. On mobile opens the share sheet;
  /// on desktop saves to the user's Downloads folder.
  Future<ExportResult> exportToExcel(List<Workout> workouts) async {
    final rows = _buildRows(workouts);
    final excel = Excel.createExcel();

    // Remove the default empty sheet
    excel.delete('Sheet1');

    final sheet = excel['Workouts'];

    // Header row
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#6366F1'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    for (int c = 0; c < _headers.length; c++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = TextCellValue(_headers[c]);
      cell.cellStyle = headerStyle;
    }

    // Data rows
    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      for (int c = 0; c < row.length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1),
        );
        final value = row[c];
        if (value is double) {
          cell.value = DoubleCellValue(value);
        } else if (value is int) {
          cell.value = IntCellValue(value);
        } else {
          cell.value = TextCellValue(value.toString());
        }
      }
    }

    // Column widths
    final widths = [12, 22, 26, 14, 6, 12, 6, 6, 12];
    for (int c = 0; c < widths.length; c++) {
      sheet.setColumnWidth(c, widths[c].toDouble());
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('Excel encoding failed');

    final file = await _writeFile('strengthlabs_export.xlsx', bytes);
    final shared = await _maybeShare(
      file,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    return ExportResult(rowCount: rows.length, path: file.path, shared: shared);
  }

  // ---------------------------------------------------------------------------

  /// Builds one row per set across all [workouts], sorted by date desc.
  List<List<dynamic>> _buildRows(List<Workout> workouts) {
    final rows = <List<dynamic>>[];
    final sorted = [...workouts]..sort((a, b) => b.date.compareTo(a.date));

    for (final workout in sorted) {
      final dateStr = _dateFmt.format(workout.date);
      for (final we in workout.exercises) {
        for (int i = 0; i < we.sets.length; i++) {
          final s = we.sets[i];
          rows.add([
            dateStr,
            workout.name,
            we.exercise.name,
            we.exercise.muscleGroup.label,
            i + 1,
            s.weight,
            s.reps,
            s.rpe ?? '',
            s.volume,
          ]);
        }
      }
    }
    return rows;
  }

  String _escapeCsvField(dynamic value) {
    final str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  Future<File> _writeFile(String filename, List<int> bytes) async {
    final dir = await _targetDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// On desktop prefer the user's Downloads folder so the file is visible
  /// outside the app sandbox. Falls back to the app documents dir when
  /// Downloads is unavailable (and always uses docs on mobile).
  Future<Directory> _targetDirectory() async {
    if (_isDesktop) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) return downloads;
    }
    return getApplicationDocumentsDirectory();
  }

  /// Shares the file on mobile. Skips on desktop (returns false) because
  /// share_plus's desktop backends are unreliable — the page shows the
  /// on-disk path to the user instead.
  Future<bool> _maybeShare(File file, String mimeType) async {
    if (_isDesktop) return false;
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      subject: 'StrengthLabs export',
    );
    return true;
  }
}
