import 'package:flutter/material.dart';
import 'package:do_an_nhom6/theme.dart';
import 'package:do_an_nhom6/data/app_data.dart';
import 'package:do_an_nhom6/screens/subject_screen.dart';

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> dsMonHoc = [];

  @override
  void initState() {
    super.initState();
    loadMonHoc();
  }

  void loadMonHoc() {
    // Lấy trực tiếp danh sách tĩnh từ AppData (Đã xếp Sử lên trước Toán)
    final data = AppData.getStaticMonHoc();
    setState(() {
      dsMonHoc = data;
    });
  }

  // Lấy icon key tương ứng theo tên môn
  String getIconKey(String tenMon) {
    switch (tenMon.toLowerCase()) {
      case 'toán':
        return 'math';
      case 'vật lý':
        return 'physics';
      case 'hóa học':
        return 'chem';
      case 'tiếng anh':
        return 'english';
      case 'sinh học':
        return 'bio';
      case 'địa lý':
        return 'geo';
      case 'lịch sử':
        return 'history';
      case 'gdcd':
        return 'civic';
      case 'ngữ văn':
        return 'lit';
      default:
        return 'sgk';
    }
  }

  // Chỉ định chính xác vị trí màu trong AppTheme để không bị lộn xộn màu sắc
  int getColorIndex(String tenMon) {
    switch (tenMon.toLowerCase()) {
      case 'toán':
        return 0; // Màu xanh dương (Toán)
      case 'lịch sử':
        return 6; // Màu cam đậm (Lịch sử)
      default:
        return 9;
    }
  }
  // Trong _HomeScreenState của bạn:

  Future<void> xuLyXoaVaCapNhatUI() async {
    // 1. Chạy lệnh xóa dữ liệu trùng dưới SQLite
    int soDongDaXoa = await AppData.xoaCauHoiTrungLapp();

    if (soDongDaXoa > 0) {
      // 2. Nếu có dữ liệu bị xóa, gọi lại hàm load để lấy danh sách mới sạch sẽ
      // Đối với danh sách môn học tĩnh (Static), nếu bạn muốn cập nhật lại
      // thì gọi loadMonHoc() hoặc loadCauHoi() tùy theo màn hình bạn đang đứng.
      loadMonHoc();

      // 3. Hiển thị thông báo nhỏ cho người dùng biết
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Đã dọn dẹp $soDongDaXoa câu hỏi trùng lặp!'),
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('👍 Dữ liệu đã sạch sẽ, không có câu trùng.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        title: const Text('Ôn thi THPT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: GridView.builder(
            itemCount: dsMonHoc.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final mon = dsMonHoc[index];

              return _SubjectCard(
                maMon: mon['MaMon'],
                tenMon: mon['TenMon'],
                moTa: mon['MoTa'] ?? '',
                iconKey: getIconKey(mon['TenMon']),
                colorIndex: getColorIndex(
                  mon['TenMon'],
                ), // Lấy màu chuẩn theo môn
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUBJECT CARD (Giữ nguyên hiệu ứng ScaleTransition tuyệt đẹp của bạn)
// ============================================================

class _SubjectCard extends StatefulWidget {
  final int maMon;
  final String tenMon;
  final String moTa;
  final String iconKey;
  final int colorIndex;

  const _SubjectCard({
    required this.maMon,
    required this.tenMon,
    required this.moTa,
    required this.iconKey,
    required this.colorIndex,
  });

  @override
  State<_SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<_SubjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SubjectScreen(maMon: widget.maMon, tenMon: widget.tenMon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.subjectColors[widget.colorIndex];

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          _onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SubjectIcon(iconKey: widget.iconKey),
              const SizedBox(height: 12),
              Text(
                widget.tenMon,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.moTa,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SUBJECT ICON
// ============================================================

class _SubjectIcon extends StatelessWidget {
  final String iconKey;
  const _SubjectIcon({required this.iconKey});

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> icons = {
      'math': Icons.functions,
      'physics': Icons.bolt,
      'chem': Icons.science,
      'english': Icons.language,
      'bio': Icons.biotech,
      'geo': Icons.public,
      'history': Icons.history_edu,
      'civic': Icons.balance,
      'lit': Icons.menu_book,
      'sgk': Icons.library_books,
    };

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icons[iconKey] ?? Icons.book, color: Colors.white, size: 30),
    );
  }
}
