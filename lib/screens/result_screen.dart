import 'package:do_an_nhom6/models/models.dart';
import 'package:flutter/material.dart';
import "package:do_an_nhom6/theme.dart";

// ============================================================
// RESULT SCREEN — Score & Review
// ============================================================

class ResultScreen extends StatefulWidget {
  final List<CauHoi> questions;
  final String tenMon;
  final Map<int, int> answers;
  final Color subjectColor;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.answers,
    required this.subjectColor,
    required this.tenMon,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  bool _showReview = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ============================================================
  // CONVERT ĐÁP ÁN
  // ============================================================

  int convertAnswer(String dapAn) {
    switch (dapAn) {
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

  // ============================================================
  // TÍNH ĐIỂM
  // ============================================================

  int get _correctCount {
    int c = 0;

    for (final entry in widget.answers.entries) {
      final correct = convertAnswer(widget.questions[entry.key].dapAnDung);

      if (correct == entry.value) {
        c++;
      }
    }

    return c;
  }

  int get _total => widget.questions.length;

  int get _unanswered => _total - widget.answers.length;

  double get _score => _correctCount / _total * 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,

        title: Text(widget.tenMon),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: const Text('Trang chủ'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ====================================================
            // SCORE CARD
            // ====================================================
            ScaleTransition(
              scale: _scaleAnim,

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.subjectColor,
                      widget.subjectColor.withValues(alpha: 0.75),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color: widget.subjectColor.withValues(alpha: 0.35),

                      blurRadius: 20,

                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    const Text(
                      'Kết quả bài thi',

                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _score.toStringAsFixed(2),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),

                    const Text(
                      '/ 10.00',

                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        _StatItem(
                          label: 'Đúng',
                          value: '$_correctCount',
                          color: const Color(0xFFA8F0C6),
                        ),

                        _StatItem(
                          label: 'Sai',
                          value: '${widget.answers.length - _correctCount}',
                          color: const Color(0xFFFFADAD),
                        ),

                        _StatItem(
                          label: 'Bỏ qua',
                          value: '$_unanswered',
                          color: Colors.white38,
                        ),

                        _StatItem(
                          label: 'Tổng',
                          value: '$_total',
                          color: Colors.white54,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ====================================================
            // BUTTON REVIEW
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showReview = !_showReview;
                  });
                },

                icon: Icon(
                  _showReview
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),

                label: Text(
                  _showReview ? 'Ẩn đáp án' : 'Xem đáp án chi tiết',

                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.subjectColor,

                  side: BorderSide(color: widget.subjectColor),

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // ====================================================
            // REVIEW LIST
            // ====================================================
            if (_showReview) ...[
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemCount: widget.questions.length,

                separatorBuilder: (_, _) => const SizedBox(height: 10),

                itemBuilder: (_, i) {
                  return _ReviewTile(
                    question: widget.questions[i],
                    userAnswer: widget.answers[i],
                    color: widget.subjectColor,
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // ====================================================
            // BUTTON HOME
            // ====================================================
            SizedBox(
              width: double.infinity,

              child: FilledButton(
                onPressed: () {
                  Navigator.popUntil(context, (r) => r.isFirst);
                },

                style: FilledButton.styleFrom(
                  backgroundColor: widget.subjectColor,

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  'Về trang chủ',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STAT ITEM
// ============================================================

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,

          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),

        Text(
          label,

          style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
        ),
      ],
    );
  }
}

// ============================================================
// REVIEW TILE
// ============================================================

class _ReviewTile extends StatelessWidget {
  final CauHoi question;
  final int? userAnswer;
  final Color color;

  const _ReviewTile({
    required this.question,
    required this.userAnswer,
    required this.color,
  });

  int get correct {
    switch (question.dapAnDung) {
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

  @override
  Widget build(BuildContext context) {
    final isCorrect = userAnswer == correct;

    final isSkipped = userAnswer == null;

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: isSkipped
              ? Colors.grey.shade200
              : isCorrect
              ? AppTheme.correct.withValues(alpha: 0.3)
              : AppTheme.wrong.withValues(alpha: 0.3),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                decoration: BoxDecoration(
                  color: isSkipped
                      ? Colors.grey.shade100
                      : isCorrect
                      ? AppTheme.correct.withValues(alpha: 0.12)
                      : AppTheme.wrong.withValues(alpha: 0.12),

                  borderRadius: BorderRadius.circular(6),
                ),

                child: Text(
                  'Câu ${question.maCauHoi}',

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,

                    color: isSkipped
                        ? AppTheme.textMuted
                        : isCorrect
                        ? AppTheme.correct
                        : AppTheme.wrong,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              if (!isSkipped)
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,

                  color: isCorrect ? AppTheme.correct : AppTheme.wrong,

                  size: 18,
                )
              else
                const Icon(
                  Icons.remove_circle_outline,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            question.noiDung,

            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textDark,
              height: 1.5,
            ),

            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              if (userAnswer != null) ...[
                Text(
                  'Bạn chọn: ',

                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),

                Text(
                  ['A', 'B', 'C', 'D'][userAnswer!],

                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,

                    color: isCorrect ? AppTheme.correct : AppTheme.wrong,
                  ),
                ),

                const Text(' · ', style: TextStyle(color: AppTheme.textMuted)),
              ],

              Text(
                'Đáp án: ',

                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),

              Text(
                ['A', 'B', 'C', 'D'][correct],

                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.correct,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
