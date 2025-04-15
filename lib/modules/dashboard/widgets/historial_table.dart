import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  
  final searchLower = query.toLowerCase();
  return 
    data['usuario']?.toString().toLowerCase().contains(searchLower) == true ||
    data['categoria']?.toString().toLowerCase().contains(searchLower) == true ||
    data['tipo_movimiento']?.toString().toLowerCase().contains(searchLower) == true ||
    data['campo']?.toString().toLowerCase().contains(searchLower) == true || // Nuevo
    data['valor_nuevo']?.toString().toLowerCase().contains(searchLower) == true; // Nuevo
}

  @override
  void dispose() {
    _dummyHorizontalController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Container(
    margin: EdgeInsets.zero,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
    ),
    child: Scrollbar(
      controller: _verticalScrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalScrollController,
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          notificationPredicate: (notification) => notification.depth == 0,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: _buildMainDataTable(),
            ),
          ),
        ),
      ),
    ),
  );
}

DataColumn _buildHeader(String text, {double width = 140}) {
  return DataColumn(
    label: SizedBox(
      width: width,
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
      dataRowHeight: 80,
      columns: [
        _buildHeader("Fecha"),
        _buildHeader("Hora"),
        _buildHeader("Usuario"),
        _buildHeader("Categoría"),
        _buildHeader("Tipo Mov."),
        _buildHeader("Campo"),
        _buildHeader("Valor Anterior", width: 190),
        _buildHeader("Valor Nuevo", width: 190),
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