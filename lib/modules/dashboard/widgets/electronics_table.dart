import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ElectronicTable extends StatefulWidget {
  const ElectronicTable({Key? key}) : super(key: key);

  @override
  ElectronicTableState createState() => ElectronicTableState();
}

class ElectronicTableState extends State<ElectronicTable> {
  String _searchQuery = "";
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final double _actionsColumnWidth = 150.0;

  @override
  void initState() {
    super.initState();
    actualizarTimestamp();
  }

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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.hovered)) return Colors.black54;
            if (states.contains(MaterialState.dragged)) return Colors.black87;
            return Colors.black;
          }),
          thickness: MaterialStateProperty.all(8),
          radius: const Radius.circular(10),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('electronicos').orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return _loadingIndicator();
            if (snapshot.hasError) return _errorWidget(snapshot.error.toString());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _emptyState();

            final filteredData = _filterData(snapshot.data!.docs);

            return Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                notificationPredicate: (_) => true,
                child: SingleChildScrollView(
                  controller: _verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainDataTable(filteredData),
                          Container(
                            width: _actionsColumnWidth,
                            color: Colors.white,
                            child: _buildActionsColumn(filteredData),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

  // Método para construir encabezados uniformes
  DataColumn _buildHeader(String text) {
  return DataColumn(
    label: SizedBox(
      width: 140, // Aumentar ancho para columnas largas
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMainDataTable(List<QueryDocumentSnapshot> filteredData) {
  return DataTable(
    columnSpacing: 30,
    headingRowHeight: 60,
    dataRowHeight: 80,
    columns: [
      _buildHeader("Cantidad"),
      _buildHeader("Artículo"),
      _buildHeader("Marca"),
      _buildHeader("Modelo"),
      _buildHeader("Especificaciones"),
      _buildHeader("N° Producto"),
      _buildHeader("N° Serie"),
      _buildHeader("Antigüedad"),
      _buildHeader("Valor Aprox."),
      _buildHeader("Responsable"),
      _buildHeader("Responsabilidad"),
      _buildHeader("Ubicación"),
      _buildHeader("Imagen"),
    ],
    rows: filteredData.map((document) => _buildDataRow(document)).toList(),
  );
}

  Widget _buildActionsColumn(List<QueryDocumentSnapshot> filteredData) {
    return DataTable(
      columnSpacing: 0,
      headingRowHeight: 60,
      dataRowHeight: 80,
      columns: const [
        DataColumn(
          label: Center(
            child: Text(
              "Acciones",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
      rows: List.generate(filteredData.length, (index) {
        return DataRow(
          cells: [
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Remix.add_large_line, color: Colors.green),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Remix.edit_box_line, color: Color(0xFFF6A000)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Remix.delete_bin_line, color: Color(0xFF971B81)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<QueryDocumentSnapshot> _filterData(List<QueryDocumentSnapshot> docs) {
    return docs.where((document) {
      final data = document.data() as Map<String, dynamic>;
      final nombre = data['articulo']?.toString().toLowerCase() ?? "";
      final codigo = data['marca']?.toString().toLowerCase() ?? "";
      return nombre.contains(_searchQuery) || codigo.contains(_searchQuery);
    }).toList();
  }

  DataRow _buildDataRow(QueryDocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final imageUrl = data['imagen_url']?.toString();
    
    return DataRow(
      cells: [
        _buildDataCell('${data['cantidad'] ?? 0}'),
        _buildDataCell(data['articulo']?.toString()),
        _buildDataCell(data['marca']?.toString()),
        _buildDataCell(data['modelo']?.toString()),
        _buildDataCell(data['especificaciones']?.toString(), isWide: true),
        _buildDataCell(data['numero_producto']?.toString()),
        _buildDataCell(data['numero_serie']?.toString()),
        _buildDataCell(data['antiguedad']?.toString()),
        _buildDataCell("\$${double.tryParse(data['valor_aprox']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}"),
        _buildDataCell(data['responsable']?.toString()),
        _buildDataCell(data['responsabilidad']?.toString()),
        _buildDataCell(data['ubicacion']?.toString()),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: imageUrl != null && imageUrl != 'N/A' 
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error))
                : const Text('N/A')
            ),
          ),
        ),
      ],
    );
  }

  DataCell _buildDataCell(String? text, {bool isWide = false}) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: SizedBox(
            width: isWide ? 190 : null,
            child: Text(
              text ?? 'N/A',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: isWide ? 3 : 2,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadingIndicator() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: CircularProgressIndicator(),
    ),
  );

  Widget _errorWidget(String error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red),
      ),
    ),
  );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        'No hay datos disponibles',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );
}