import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'file_saver/file_saver.dart';

class ExportService {
  /// Export villagers data to Excel format
  static Future<String?> exportToExcel(List<Map<String, dynamic>> data) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Data Penduduk'];

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
      final fileBytes = excel.save();
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

      // Add headers
      final headers = [
        'No KK',
        'Kepala Keluarga',
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
      sheet.setColumnWidth(2, 18);

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileBytes = excel.save();
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
}
