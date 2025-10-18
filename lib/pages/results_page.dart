import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "View Student Results Here 📘",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
