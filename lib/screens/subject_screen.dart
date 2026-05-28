import 'package:flutter/material.dart';
import '../data/app_data.dart';

class SubjectScreen extends StatefulWidget {
  final int maMon;
  final String tenMon;

  const SubjectScreen({super.key, required this.maMon, required this.tenMon});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  List<Map<String, dynamic>> dsCauHoi = [];

  @override
  void initState() {
    super.initState();
    loadCauHoi();
  }

  // =========================================
  // LOAD CÂU HỎI THEO MÔN
  // =========================================
  Future<void> loadCauHoi() async {
    final data = await AppData.getCauHoiByMon(widget.maMon);

    setState(() {
      dsCauHoi = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tenMon)),

      body: ListView.builder(
        itemCount: dsCauHoi.length,

        itemBuilder: (context, index) {
          final q = dsCauHoi[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Câu hỏi
                  Text(
                    q['NoiDung'],

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Đáp án
                  Text("A. ${q['CauA']}"),
                  Text("B. ${q['CauB']}"),
                  Text("C. ${q['CauC']}"),
                  Text("D. ${q['CauD']}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
