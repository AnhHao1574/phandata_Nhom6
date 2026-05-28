// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:do_an_nhom6/models/models.dart';
import 'package:do_an_nhom6/theme.dart';
import 'package:do_an_nhom6/data/app_data.dart';
import 'package:do_an_nhom6/screens/result_screen.dart';

class ExamScreen extends StatefulWidget {
  final int maMon;
  final String tenMon;
  final Color subjectColor;

  const ExamScreen({
    super.key,
    required this.maMon,
    required this.tenMon,
    required this.subjectColor,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers =
      {}; // vị trí câu hỏi -> index đáp án chọn (0->3)
  late int _remainingSeconds;
  Timer? _timer;
  final PageController _pageController = PageController();
  bool _submitted = false;

  List<CauHoi> _dsCauHoi = [];
  bool _isLoading = true;

  static const int _totalSeconds = 60 * 60; // 60 phút làm bài

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _totalSeconds;
    _loadDataFromSQLite();
  }

  // HÀM ĐÓN NHẬN DỮ LIỆU TỪ SQLITE LOCAL
  Future<void> _loadDataFromSQLite() async {
    try {
      final List<Map<String, dynamic>> rawData = await AppData.getCauHoiByMon(
        widget.maMon,
      );

      setState(() {
        _dsCauHoi = rawData.map((map) => CauHoi.fromMap(map)).toList();
        _isLoading = false;
        if (_dsCauHoi.isNotEmpty) {
          _startTimer();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi tải database: $e")));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 0) {
        t.cancel();
        _submit();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _submit() {
    if (_submitted) return;
    _timer?.cancel();
    setState(() => _submitted = true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          questions: _dsCauHoi,
          answers: _answers,
          subjectColor: widget.subjectColor,
          tenMon: widget.tenMon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: BackButton(color: widget.subjectColor),
        title: Text(
          widget.tenMon,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            alignment: Alignment.center,
            child: Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                color: _remainingSeconds < 300
                    ? AppTheme.wrong
                    : widget.subjectColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.subjectColor),
              ),
            )
          : _dsCauHoi.isEmpty
          ? const Center(
              child: Text("Môn học này chưa có câu hỏi trong dữ liệu local."),
            )
          : SafeArea(
              child: Column(
                children: [
                  _buildProgressIndicator(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentIndex = i),
                      itemCount: _dsCauHoi.length,
                      itemBuilder: (context, index) =>
                          _buildQuestionPage(_dsCauHoi[index], index),
                    ),
                  ),
                  _buildBottomNav(),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _dsCauHoi.isEmpty
        ? 0.0
        : (_currentIndex + 1) / _dsCauHoi.length;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(widget.subjectColor),
          minHeight: 4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Câu hỏi ${_currentIndex + 1}/${_dsCauHoi.length}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                "Đã làm: ${_answers.length}/${_dsCauHoi.length}",
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionPage(CauHoi q, int qIndex) {
    final options = q.mangTuyChon;
    final prefixLabels = ['A.', 'B.', 'C.', 'D.'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: AppTheme.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Câu ${qIndex + 1}: ${q.noiDung}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(options.length, (i) {
                return _buildOptionRow(
                  qIndex,
                  i,
                  "${prefixLabels[i]} ${options[i]}",
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionRow(int qIdx, int optIdx, String text) {
    final isSelected = _answers[qIdx] == optIdx;
    return GestureDetector(
      onTap: () => setState(() => _answers[qIdx] = optIdx),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.subjectColor.withAlpha(20)
              : AppTheme.bgLight.withAlpha(130),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? widget.subjectColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? widget.subjectColor
                      : Colors.grey.shade400,
                  width: isSelected ? 6 : 1.5,
                ),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isFirst = _currentIndex == 0;
    final isLast = _dsCauHoi.isEmpty || _currentIndex == _dsCauHoi.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBtn(
            icon: Icons.chevron_left,
            label: 'Câu trước',
            color: widget.subjectColor,
            onTap: isFirst
                ? null
                : () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
          ),
          ElevatedButton(
            onPressed: _showSubmitConfirmation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Nộp bài',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          _NavBtn(
            icon: Icons.chevron_right,
            label: 'Câu tiếp',
            color: widget.subjectColor,
            isRight: true,
            onTap: isLast
                ? null
                : () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nộp bài thi?'),
        content: Text(
          'Bạn đã làm được ${_answers.length}/${_dsCauHoi.length} câu. Bạn có chắc chắn muốn nộp bài không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Làm tiếp'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submit();
            },
            child: const Text(
              'Nộp bài',
              style: TextStyle(
                color: AppTheme.wrong,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool isRight;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final finalColor = enabled ? color : Colors.grey.shade300;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: isRight
            ? [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: finalColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 14, color: finalColor),
              ]
            : [
                Icon(icon, size: 14, color: finalColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: finalColor,
                  ),
                ),
              ],
      ),
    );
  }
}
