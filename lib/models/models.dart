// models.dart
class MonHoc {
  final int maMon;
  final String tenMon;
  final String? moTa;

  MonHoc({required this.maMon, required this.tenMon, this.moTa});

  factory MonHoc.fromMap(Map<String, dynamic> map) {
    return MonHoc(
      maMon: map['MaMon'],
      tenMon: map['TenMon'],
      moTa: map['MoTa'],
    );
  }
}

class CauHoi {
  final int maCauHoi;
  final int maMon;
  final String noiDung;
  final String cauA;
  final String cauB;
  final String cauC;
  final String cauD;
  final String dapAnDung; // Lưu 'A', 'B', 'C', 'D'

  CauHoi({
    required this.maCauHoi,
    required this.maMon,
    required this.noiDung,
    required this.cauA,
    required this.cauB,
    required this.cauC,
    required this.cauD,
    required this.dapAnDung,
  });

  factory CauHoi.fromMap(Map<String, dynamic> map) {
    return CauHoi(
      maCauHoi: map['MaCauHoi'],
      maMon: map['MaMon'],
      noiDung: map['NoiDung'],
      cauA: map['CauA'] ?? '',
      cauB: map['CauB'] ?? '',
      cauC: map['CauC'] ?? '',
      cauD: map['CauD'] ?? '',
      dapAnDung: map['DapAnDung'] ?? 'A',
    );
  }

  // Tiện ích biến đổi nhanh sang mảng giúp UI Render vòng lặp dễ hơn
  List<String> get mangTuyChon => [cauA, cauB, cauC, cauD];

  // Chuyển chữ cái 'A','B','C','D' thành index 0, 1, 2, 3 phục vụ Logic check đáp án
  int get chiMucDapAnDung {
    switch (dapAnDung.trim().toUpperCase()) {
      case 'A':
        return 0;
      case 'B':
        return 1;
      case 'C':
        return 2;
      case 'D':
        return 3;
      default:
        return 0;
    }
  }
}
