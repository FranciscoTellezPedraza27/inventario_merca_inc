import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'historial_top.dart'; // Ajusta la ruta según tu estructura de archivos

class HistorialTable extends StatefulWidget {
  final List<QueryDocumentSnapshot> documentos;
  final String searchQuery;
  
  const HistorialTable({
    Key? key,
    required this.documentos,
    required this.searchQuery,
  }) : super(key: key);

  @override
  HistorialTableState createState() => HistorialTableState();
}

class HistorialTableState extends State<HistorialTable> with AutomaticKeepAliveClientMixin{
  late List<QueryDocumentSnapshot> _documentosFiltrados;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final double _actionsColumnWidth = 190.0;
  final ScrollController _dummyHorizontalController = ScrollController();

  @override
  bool get wantKeepAlive => true; // Cambiado a true para mantener el estado


  @override
  void initState() {
    super.initState();
    _documentosFiltrados = widget.documentos; // Primero asignar
    _aplicarFiltros(); // Luego filtrar
    _setupScrollSync();
  }

  void _setupScrollSync() {
    _horizontalScrollController.addListener(() {
      if (_dummyHorizontalController.hasClients &&
          _dummyHorizontalController.offset != _horizontalScrollController.offset) {
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

  @override
  void didUpdateWidget(HistorialTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.documentos != widget.documentos || oldWidget.searchQuery != widget.searchQuery) {
      _aplicarFiltros();
    }
  }


    void _aplicarFiltros() {
    final searchLower = widget.searchQuery.toLowerCase();
    
    setState(() {
      _documentosFiltrados = widget.documentos.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _cumpleBusqueda(data, searchLower);
      }).toList();
    });
  }

      bool _cumpleBusqueda(Map<String, dynamic> data, String query) {
    if (query.isEmpty) return true;
    
    return data['usuario']?.toString().toLowerCase().contains(query) == true ||
           data['categoria']?.toString().toLowerCase().contains(query) == true ||
           data['tipo_movimiento']?.toString().toLowerCase().contains(query) == true;
  }

  @override
  void dispose() {
    _dummyHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalColumnsWidth = (160.0 * 8) + (30.0 * 7); // 8 columnas con espaciado

    return Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
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
          child: Stack(
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: totalColumnsWidth,
                              maxWidth: totalColumnsWidth,
                            ),
                            child: _buildMainDataTable(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildHorizontalScrollControl(totalColumnsWidth),
              ),
            ],
          ),
        ),
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
            offset: const Offset(0, -2)
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
          physics: const ClampingScrollPhysics(),
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
      label: SizedBox(
        width: 140,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainDataTable() {
    return DataTable(
      columnSpacing: 30,
      headingRowHeight: 60,
      dataRowHeight: 100,
      columns: [
        _buildHeader("Fecha"),
        _buildHeader("Hora"),
        _buildHeader("Usuario"),
        _buildHeader("Categoría"),
        _buildHeader("Tipo Mov."),
        _buildHeader("Campo"),
        _buildHeader("Valor Anterior"),
        _buildHeader("Valor Nuevo"),
      ],
      rows: _documentosFiltrados.map((document) => _buildDataRow(document)).toList(),
    );
  }

  DataRow _buildDataRow(QueryDocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final timestamp = data['timestamp']?.toDate();
    
    return DataRow(
      cells: [
        _buildDataCell(_formatDate(timestamp)),
        _buildDataCell(_formatTime(timestamp)),
        _buildDataCell(data['usuario'] ?? 'Sistema'),
        _buildDataCell(data['categoria'] ?? 'N/A'),
        _buildDataCell(data['tipo_movimiento'] ?? 'N/A'),
        _buildDataCell(_obtenerCampo(data)),
        _buildDataCell(_obtenerValorAnterior(data), isWide: true),
        _buildDataCell(_obtenerValorNuevo(data), isWide: true),
      ],
    );
  }

  String _obtenerCampo(Map<String, dynamic> data) {
    return data['tipo_movimiento'] == 'Modificación de stock' 
        ? 'Cantidad' 
        : data['campo'] ?? 'N/A';
  }

  String _obtenerValorAnterior(Map<String, dynamic> data) {
    return data['valor_anterior']?.toString() ?? '-';
  }

  String _obtenerValorNuevo(Map<String, dynamic> data) {
    return data['valor_nuevo']?.toString() ?? '-';
  }

  DataCell _buildDataCell(String text, {bool isWide = false}) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: SizedBox(
            width: isWide ? 190 : null,
            child: Text(
              text,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: isWide ? 3 : 2,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) => date != null 
      ? '${date.day.toString().padLeft(2,'0')}/${date.month.toString().padLeft(2,'0')}/${date.year}'
      : 'N/A';

  String _formatTime(DateTime? date) => date != null
      ? '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}'
      : 'N/A';
}