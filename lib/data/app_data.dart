import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppData {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'questions.db');

    // Ép buộc xóa file cũ để bảo đảm hệ thống luôn copy file mới nhất từ assets vào máy ảo
    if (await databaseExists(path)) {
      await deleteDatabase(path);
    }

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Sao chép database từ Assets
    ByteData data = await rootBundle.load(
      join("assets", "database", "questions.db"),
    );
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(path).writeAsBytes(bytes, flush: true);
    if (kDebugMode) {
      print("✅ Đã chép file questions.db thành công!");
    }

    return await openDatabase(path, version: 1);
  }

  // ============================================================
  // Đã đảo vị trí: Lịch sử (MaMon: 1) lên trước, Toán (MaMon: 2) ra sau
  // ============================================================
  static List<Map<String, dynamic>> getStaticMonHoc() {
    return [
      {'MaMon': 1, 'TenMon': 'Lịch sử', 'MoTa': 'Ngân hàng câu hỏi Lịch sử'},
      {'MaMon': 2, 'TenMon': 'Toán', 'MoTa': 'Đề thi trắc nghiệm Toán THPT'},
    ];
  }

  // Hàm xóa các câu hỏi trùng lặp nội dung, giữ lại câu có MaCauHoi nhỏ nhất
  static Future<int> xoaCauHoiTrungLapp() async {
    final db = await database;

    // Câu lệnh SQL xóa các dòng trùng lặp dựa trên NoiDung
    int rowsDeleted = await db.rawDelete('''
    DELETE FROM CauHoi 
    WHERE MaCauHoi NOT IN (
      SELECT MIN(MaCauHoi) 
      FROM CauHoi 
      GROUP BY NoiDung, MaMon
    )
  ''');

    if (kDebugMode) {
      print("🔥 Đã xóa $rowsDeleted câu hỏi bị trùng lặp trong SQLite!");
    }
    return rowsDeleted;
  }

  // ============================================================
  // TRUY VẤN CÂU HỎI THEO MÃ MÔN TỪ FILE QUESTIONS.DB THẬT
  // ============================================================
  static Future<List<Map<String, dynamic>>> getCauHoiByMon(int maMon) async {
    final db = await database;
    return await db.query('CauHoi', where: 'MaMon = ?', whereArgs: [maMon]);
  }
}
