import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTable extends StatefulWidget {
  const OrderTable({super.key});

  @override
  OrderTableState createState() => OrderTableState();
}

class OrderTableState extends State<OrderTable> {
  String _searchQuery = ""; // Variable para filtrar los resultados

  void updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
          ],
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No hay datos disponibles.'));
            }

            final inventoryData = snapshot.data!.docs;

            // Filtrar datos según la búsqueda
            final filteredData = inventoryData.where((document) {
              final data = document.data() as Map<String, dynamic>;
              final nombre = data['nombre']?.toString().toLowerCase() ?? "";
              final codigo = data['codigo_producto']?.toString().toLowerCase() ?? "";

              return nombre.contains(_searchQuery) || codigo.contains(_searchQuery);
            }).toList();

            return DataTable(
              columns: const [
                DataColumn(label: Text("Código de producto")),
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("Categoría")),
                DataColumn(label: Text("Existencia")),
                DataColumn(label: Text("Existencia Mínima")),
                DataColumn(label: Text("Precio")),
                DataColumn(label: Text("Estatus")),
              ],
              rows: filteredData.map((document) {
                final data = document.data() as Map<String, dynamic>;

                return DataRow(
                  cells: [
                    DataCell(Text(data['codigo_producto']?.toString() ?? 'N/A')),
                    DataCell(Text(data['nombre']?.toString() ?? 'N/A')),
                    DataCell(Text(data['categoria']?.toString() ?? 'N/A')),
                    DataCell(Text(data['existencia']?.toString() ?? '0')),
                    DataCell(Text(data['existencia_minima']?.toString() ?? '0')),
                    DataCell(Text("\$${double.tryParse(data['precio']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}")),
                    DataCell(Text('Disponible')),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
