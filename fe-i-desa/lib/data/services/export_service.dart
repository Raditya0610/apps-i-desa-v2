import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'file_saver/file_saver.dart';
import '../models/dashboard.dart';

class ExportService {
  /// Export villagers data to Excel format
  static Future<String?> exportToExcel(List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data Penduduk'];
      // Remove the default 'Sheet1' created by the excel package so that
      // 'Data Penduduk' is the first (and only) visible sheet.
      excel.delete('Sheet1');

      // Add headers
      final headers = [
        'NIK',
        'Nama Lengkap',
        'Jenis Kelamin',
        'Tempat Lahir',
        'Tanggal Lahir',
        'Umur',
        'Agama',
        'Pendidikan',
        'Pekerjaan',
        'Status Perkawinan',
        'Status Hubungan',
        'Kewarganegaraan',
        'Nama Ayah',
        'Nama Ibu',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Add data rows
      for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final villager = data[rowIndex];
        final rowData = [
          villager['nik'] ?? '',
          villager['name'] ?? villager['nama_lengkap'] ?? '',
          villager['jenis_kelamin'] ?? '',
          villager['tempat_lahir'] ?? '',
          villager['tanggal_lahir'] ?? '',
          villager['age']?.toString() ?? '',
          villager['agama'] ?? '',
          villager['pendidikan'] ?? '',
          villager['pekerjaan'] ?? '',
          villager['status_perkawinan'] ?? '',
          villager['status_hubungan'] ?? '',
          villager['kewarganegaraan'] ?? '',
          villager['nama_ayah'] ?? '',
          villager['nama_ibu'] ?? '',
        ];

        for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex + 1,
            ),
          );
          cell.value = TextCellValue(rowData[colIndex]);
        }
      }

      // Auto-fit columns
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        return saveBytesFile(fileBytes, 'data_penduduk_$timestamp.xlsx');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Export villagers data to CSV format
  static Future<String?> exportToCsv(List<Map<String, dynamic>> data) async {
    try {
      final List<List<dynamic>> rows = [];
      rows.add([
        'NIK', 'Nama Lengkap', 'Jenis Kelamin', 'Tempat Lahir',
        'Tanggal Lahir', 'Umur', 'Agama', 'Pendidikan', 'Pekerjaan',
        'Status Perkawinan', 'Status Hubungan', 'Kewarganegaraan',
        'Nama Ayah', 'Nama Ibu',
      ]);
      for (final v in data) {
        rows.add([
          v['nik'] ?? '', v['name'] ?? v['nama_lengkap'] ?? '',
          v['jenis_kelamin'] ?? '', v['tempat_lahir'] ?? '',
          v['tanggal_lahir'] ?? '', v['age']?.toString() ?? '',
          v['agama'] ?? '', v['pendidikan'] ?? '', v['pekerjaan'] ?? '',
          v['status_perkawinan'] ?? '', v['status_hubungan'] ?? '',
          v['kewarganegaraan'] ?? '', v['nama_ayah'] ?? '', v['nama_ibu'] ?? '',
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      return saveStringFile(csv, 'data_penduduk_$timestamp.csv');
    } catch (e) {
      return null;
    }
  }

  /// Export family cards data to Excel format
  static Future<String?> exportFamilyCardsToExcel(
      List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data Kartu Keluarga'];
      // Remove the default 'Sheet1' created by the excel package so that
      // 'Data Kartu Keluarga' is the first (and only) visible sheet.
      excel.delete('Sheet1');

      // Add headers
      final headers = [
        'No KK',
        'Kepala Keluarga',
        'Alamat',
        'Jumlah Anggota',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.green,
          fontColorHex: ExcelColor.white,
        );
      }

      // Add data rows
      for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
        final familyCard = data[rowIndex];
        final rowData = [
          familyCard['nik'] ?? '',
          familyCard['nama_lengkap'] ?? '',
          familyCard['alamat'] ?? '',
          familyCard['jumlah_anggota']?.toString() ?? '0',
        ];

        for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex + 1,
            ),
          );
          cell.value = TextCellValue(rowData[colIndex]);
        }
      }

      sheet.setColumnWidth(0, 25);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 30);
      sheet.setColumnWidth(3, 18);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        return saveBytesFile(fileBytes, 'data_kartu_keluarga_$timestamp.xlsx');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Export family cards data to CSV format
  static Future<String?> exportFamilyCardsToCsv(
      List<Map<String, dynamic>> data) async {
    try {
      final List<List<dynamic>> rows = [];
      rows.add(['No KK', 'Kepala Keluarga', 'Jumlah Anggota']);
      for (final fc in data) {
        rows.add([
          fc['nik'] ?? '',
          fc['nama_lengkap'] ?? '',
          fc['jumlah_anggota']?.toString() ?? '0',
        ]);
      }
      final csv = const ListToCsvConverter().convert(rows);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      return saveStringFile(csv, 'data_kartu_keluarga_$timestamp.csv');
    } catch (e) {
      return null;
    }
  }

  /// Label/value rows for the dashboard summary report, shared by the Excel
  /// and CSV exporters so the two formats can never drift apart.
  static List<List<dynamic>> _dashboardSummaryRows(Dashboard dashboard) {
    final generatedAt = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final rows = <List<dynamic>>[
      ['Ringkasan Kondisi Demografi Desa', ''],
      ['Dibuat pada', generatedAt],
      ['', ''],
      ['Total Kartu Keluarga', dashboard.totalKeluarga],
      ['Total Penduduk', dashboard.totalPenduduk],
      ['Rata-rata Anggota per Keluarga', dashboard.rerataKeluarga.toStringAsFixed(1)],
      ['Laki-laki', '${dashboard.lakiLaki} (${dashboard.genderRatioMale.toStringAsFixed(1)}%)'],
      ['Perempuan', '${dashboard.perempuan} (${dashboard.genderRatioFemale.toStringAsFixed(1)}%)'],
      ['Kepala Keluarga', dashboard.kepalaKeluarga],
      ['Rata-rata Umur', '${dashboard.rerataUmur.toStringAsFixed(1)} tahun'],
      ['Jumlah RT', dashboard.rt],
      ['Jumlah RW', dashboard.rw],
      ['Jumlah Kelurahan/Desa', dashboard.kelurahan],
      ['Jumlah Kecamatan', dashboard.kecamatan],
    ];

    if (dashboard.pendidikanBreakdown.isNotEmpty) {
      rows.add(['', '']);
      rows.add(['Breakdown Pendidikan Terakhir', 'Jumlah']);
      for (final item in dashboard.pendidikanBreakdown) {
        rows.add([item.label, item.total]);
      }
    }

    if (dashboard.pekerjaanBreakdown.isNotEmpty) {
      rows.add(['', '']);
      rows.add(['Breakdown Pekerjaan', 'Jumlah']);
      for (final item in dashboard.pekerjaanBreakdown) {
        rows.add([item.label, item.total]);
      }
    }

    return rows;
  }

  /// Export the dashboard's own report summary (totals, gender/age averages,
  /// pendidikan/pekerjaan breakdowns) to Excel — not a per-resident listing,
  /// which is what the dashboard page itself shows.
  static Future<String?> exportDashboardSummaryToExcel(Dashboard dashboard) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Ringkasan Dashboard'];
      excel.delete('Sheet1');

      final boldStyle = CellStyle(bold: true);
      final rows = _dashboardSummaryRows(dashboard);
      for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        for (var colIndex = 0; colIndex < row.length; colIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
          );
          final value = row[colIndex];
          cell.value = value is int
              ? IntCellValue(value)
              : TextCellValue(value.toString());
          // Bold the title row and each section's header row (value column
          // is blank on the title row, a label on breakdown header rows).
          if (rowIndex == 0 || row[1] == 'Jumlah') {
            cell.cellStyle = boldStyle;
          }
        }
      }

      sheet.setColumnWidth(0, 32);
      sheet.setColumnWidth(1, 20);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileBytes = excel.encode();
      if (fileBytes != null) {
        return saveBytesFile(fileBytes, 'ringkasan_dashboard_$timestamp.xlsx');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Export the dashboard's own report summary to CSV — see
  /// [exportDashboardSummaryToExcel].
  static Future<String?> exportDashboardSummaryToCsv(Dashboard dashboard) async {
    try {
      final rows = _dashboardSummaryRows(dashboard);
      final csv = const ListToCsvConverter().convert(rows);
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      return saveStringFile(csv, 'ringkasan_dashboard_$timestamp.csv');
    } catch (e) {
      return null;
    }
  }
}
