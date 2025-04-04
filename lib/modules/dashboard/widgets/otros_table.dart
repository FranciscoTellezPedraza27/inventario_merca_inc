import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventario_merca_inc/modules/dashboard/actions/delete_otros.dart';
import 'package:inventario_merca_inc/modules/dashboard/actions/edit_otros.dart';
import 'package:inventario_merca_inc/modules/dashboard/actions/view_products.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OtrosTable extends StatefulWidget {
  const OtrosTable({Key? key}) : super(key: key);

  @override
  OtrosTableState createState() => OtrosTableState();
}

class OtrosTableState extends State<OtrosTable> {
  String _searchQuery = "";
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final double _actionsColumnWidth = 190.0;
  final ScrollController _dummyHorizontalController = ScrollController();

  @override
void initState() {
  super.initState(); // Faltaba la 'S' mayúscula
  actualizarTimeStamp();
  _setupScrollSync();
}

  void _setupScrollSync() {
    _horizontalScrollController.addListener(() {
      if (_dummyHorizontalController.hasClients &&
          _dummyHorizontalController.offset != _horizontalScrollController.offset){
        _dummyHorizontalController.jumpTo(_horizontalScrollController.offset);
      }
    });

    _dummyHorizontalController.addListener(() {
      if (_horizontalScrollController.hasClients &&
          _horizontalScrollController.offset != _dummyHorizontalController.offset) {
        _horizontalScrollController.jumpTo(_dummyHorizontalController.offset);
      }
    });
  }

  //Función para actualizar los docuemntos
  void actualizarTimeStamp() async {
    var instance = FirebaseFirestore.instance;
    var docs = await instance.collection('otros').get();
    
    for (var doc in docs.docs) {
      if (!doc.data().containsKey('timestamp')) {
        await instance.collection('otros').doc(doc.id).update({
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
  void dispose () {
    _dummyHorizontalController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  // Remover esta línea: final ScrollController _dummyHorizontalController = ScrollController();
  final totalColumnsWidth = (140.0 * 12) + 190.0 + (30.0 * 12);

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
          stream: FirebaseFirestore.instance.collection('otros').orderBy('timestamp').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return _loadingIndicator();
            if (snapshot.hasError) return _errorWidget(snapshot.error.toString());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _emptyState();

            final filteredData = _filterData(snapshot.data!.docs);

            return Stack(
              children: [
                Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              margin: EdgeInsets.only(right: _actionsColumnWidth),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: totalColumnsWidth,
                                  maxWidth: totalColumnsWidth,
                                ),
                                child: _buildMainDataTable(filteredData),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: _actionsColumnWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(-4, 0),
                                    blurRadius: 8,
                                    spreadRadius: 2
                                  )
                                ],
                              ),
                              child: _buildActionsColumn(filteredData),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Scroll horizontal fijo
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: _actionsColumnWidth,
                  child: _buildHorizontalScrollControl(totalColumnsWidth),
                ),
              ],
            );
          }
        )
      )
    )
  );  
}

Widget _buildHorizontalScrollControl(double totalWidth) {
  return Container(
    height: 12,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          spreadRadius: 1,
          offset: Offset(0, -2)
        )
      ],
    ),
    child: Scrollbar(
      controller: _dummyHorizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _dummyHorizontalController,
        scrollDirection: Axis.horizontal,
        physics: ClampingScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          height: 1,
        ),
      ),
    ),
  );
}

DataColumn _buildHeader(String text) {
  return DataColumn(
    label: Expanded( // Permite que la columna se ajuste dinámicamente
      child: Center(
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


Widget _buildMainDataTable(List <QueryDocumentSnapshot> filteredData) {
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
      _buildHeader("Recibo / Instructivo"),
      _buildHeader("Ubicación"),
      _buildHeader("Imagen"),
      ],
      rows: filteredData.map((document) => _buildDataRow(document)).toList(),
  );
}

Widget _buildActionsColumn(List<QueryDocumentSnapshot> filteredData) {
    return DataTable(
      columnSpacing: 30,
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
                      icon: Icon(Remix.eye_line, color: Color(0xFF009FE3)),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) => ViewProductsScreen(document: filteredData[index])
                        );
                      },
                    ),
                    /*IconButton(
                      icon: Icon(Remix.add_large_line, color: Colors.green),
                      onPressed: () {},
                    ),*/
                    IconButton(
                      icon: Icon(Remix.edit_box_line, color: Color(0xFFF6A000)),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) => EditOtrosScreen(document: filteredData[index])
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Remix.delete_bin_line, color: Color(0xFF971B81)),
                      onPressed: () {
                        showDialog(
                          context: context, 
                          builder: (context) => DeleteOtrosScreen(document: filteredData[index])
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    ),
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

  DataRow _buildDataRow (QueryDocumentSnapshot document) {
 final data = document.data() as Map<String, dynamic>? ?? {};
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
        _buildDataCell(data['recibo']?.toString()),
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