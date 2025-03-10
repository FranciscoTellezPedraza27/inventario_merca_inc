import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectronicTable extends StatefulWidget {
  const ElectronicTable({Key? key}) : super(key: key);

  @override
  ElectronicTableState createState() => ElectronicTableState();
}

class ElectronicTableState extends State<ElectronicTable> {
  String _searchQuery = "";
  final ScrollController _scrollController =
      ScrollController(); // Controlador para el scroll

  @override
  void initState() {
    super.initState();
    actualizarTimestamp(); // Ejecutar la función al iniciar
  }

  // Función para actualizar los documentos antiguos sin timestamp
  void actualizarTimestamp() async {
    var instance = FirebaseFirestore.instance;
    var docs = await instance.collection('electronicos').get();

    for (var doc in docs.docs) {
      if (!doc.data().containsKey('timestamp')) {
        await instance.collection('electronicos').doc(doc.id).update({
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

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
          stream: FirebaseFirestore.instance
              .collection('electronicos')
              .orderBy('timestamp',
                  descending: false) // Ahora se puede ordenar por timestamp
              .snapshots(),
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

            final ElectronicData = snapshot.data!.docs;

            // Filtrar datos basados en la búsqueda
            final filteredData = ElectronicData.where((document) {
              final data = document.data() as Map<String, dynamic>? ?? {};
              final nombre = data['articulo']?.toString().toLowerCase() ?? "";
              final codigo = data['marca']?.toString().toLowerCase() ?? "";

              return nombre.contains(_searchQuery) ||
                  codigo.contains(_searchQuery);
            }).toList();

            return ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.black54;
                    }
                    if (states.contains(MaterialState.dragged)) {
                      return Colors.black87;
                    }
                    return Colors.black;
                  },
                ),
                thickness: MaterialStateProperty.all(8),
                radius: const Radius.circular(10),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 1200),
                    child: DataTable(
                      columnSpacing: 30,
                      headingRowHeight: 56,
                      dataRowHeight: 50,
                      columns: const [
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Cantidad", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Artículo", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Marca", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Modelo", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Especificaciones", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Número de producto", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Número de serie", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Antigüedad", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Valor Aproximado", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Responsable", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Responsabilidad", textAlign: TextAlign.center)))),
                        DataColumn(label: SizedBox(width: 150, child: Center(child: Text("Ubicación", textAlign: TextAlign.center)))),
                      ],
                      rows: filteredData.map((document) {
                        final data =
                            document.data() as Map<String, dynamic>? ?? {};
                        return DataRow(
                          cells: [
                            DataCell(Center(child: Text('${data['cantidad'] ?? 0}'))),
                            DataCell(Center(child: Text(data['articulo']?.toString() ?? 'N/A'))),
                            DataCell(Center(child:Text(data['marca']?.toString() ?? 'N/A'))),
                            DataCell(Center(child:Text(data['modelo']?.toString() ?? 'N/A'))),
                            DataCell(
  Center(
    child: SizedBox(
      width: 190, // Ajusta el ancho según sea necesario
      child: Text(
        data['especificaciones']?.toString() ?? 'N/A',
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis, // Agrega puntos suspensivos si el texto es muy largo
        maxLines: 2, // Define el número máximo de líneas visibles
      ),
    ),
  ),
),

                            DataCell(Center(child: Text(data['numero_producto']?.toString() ??'N/A'))),
                            DataCell(Center(child: Text(data['numero_serie']?.toString() ??'N/A'))),
                            DataCell(Center(child: Text(data['antiguedad']?.toString() ?? 'N/A'))),
                            DataCell(Center(child: Text("\$${double.tryParse(data['valor_aprox']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}",textAlign: TextAlign.center))),
                            DataCell(Center(child: Text(data['responsable']?.toString() ?? 'N/A'))),
                            DataCell(Center(child: Text(data['responsabilidad']?.toString() ??'N/A'))),
                            DataCell(Center(child: Text(data['ubicacion']?.toString() ?? 'N/A'))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
