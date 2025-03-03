import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';


class RecordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pendiente")),
      body: Center(child: Text("Vista de Pendiente")),
    );
  }
}
