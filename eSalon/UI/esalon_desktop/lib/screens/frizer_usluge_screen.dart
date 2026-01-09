import 'dart:convert'; 
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/usluga_provider.dart';
import 'package:esalon_desktop/screens/frizer_usluge_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FrizerUslugeScreen extends StatefulWidget {
  const FrizerUslugeScreen({super.key});

  @override
  State<FrizerUslugeScreen> createState() =>
      _FrizerUslugeScreenState();
}

class _FrizerUslugeScreenState
    extends State<FrizerUslugeScreen> {
  late UslugaProvider _uslugaProvider;
  late UslugaDataSource _source;

  final TextEditingController _nazivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _uslugaProvider = context.read<UslugaProvider>();
    _source =
        UslugaDataSource(provider: _uslugaProvider, context: context);
    _source.loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Usluge",
            style: TextStyle(fontSize: 26, color: Colors.black),
          ),
        ),
        _buildSearch(),
        _buildTable(),
      ],
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nazivController,
              decoration: InputDecoration(
                labelText: 'Naziv ili opis usluge',
                hintText: 'Unesite naziv ili opis usluge',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.hovered)) {
                    return const Color(0xFFE0D7F5);
                  }
                  if (states.contains(WidgetState.focused)) {
                    return const Color(0xFFF5F5F5);
                  }
                  return Colors.white;
                }),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade500, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                ),
              ),
              onChanged: (value) {
                _source.nazivFilter = value;
                _source.filterServerSide();
              },
            ),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              _nazivController.clear();
              _source.nazivFilter = '';
              _source.filterServerSide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(150, 63),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline, size: 18, color: Color.fromARGB(199, 0, 0, 0)),
                SizedBox(width: 6),
                Text('Očisti filter', style: TextStyle(color: Color.fromARGB(199, 0, 0, 0))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Flexible(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                type: MaterialType.transparency,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: const Color(0xFFF0F4F8),
                    dataTableTheme: DataTableThemeData(
                      headingRowColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 180, 140, 218),
                      ),
                    ),
                  ),
                  child: AdvancedPaginatedDataTable(
                    source: _source,
                    addEmptyRows: false,
                    rowsPerPage: _source.pageSize,
                    showFirstLastButtons: true,
                    showCheckboxColumn: false,
                    dataRowHeight: 80,
                    columns: const [
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija naziva (20 karaktera).",
                          child: Text("NAZIV"),
                        ),
                      ),
                      DataColumn(label: Text("CIJENA")),
                      DataColumn(label: Text("TRAJANJE")),
                      DataColumn(label: Text("SLIKA")),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija opisa (20 karaktera).",
                          child: Text("OPIS"),
                        ),
                      ),
                      DataColumn(label: Text("OPCIJE")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UslugaDataSource extends AdvancedDataTableSource<Usluga> {
  final UslugaProvider provider;
  final BuildContext context;

  String nazivFilter = '';
  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<Usluga> data = [];

  UslugaDataSource({
    required this.provider,
    required this.context,
  });

  Future<void> loadInitial() async {
    if (AuthProvider.korisnikId == null) return;
    if (!context.mounted) return;

    try {
      if (!context.mounted) return; 
      await reset(targetPage: page);
    } catch (e) {
      if (!context.mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Greška",
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected) ||
            states.contains(WidgetState.hovered)) {
          return const Color(0xFFE0D7F5);
        }
        return null;
      }),
      onSelectChanged: (selected) async {
        if (selected == true) {
          if (!context.mounted) return; 
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FrizerUslugeDetailsScreen(usluga: item),
          ));
        }
      },
      cells: [
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.naziv != null && item.naziv!.length > 20)
                  ? '${item.naziv!.substring(0, 20)}...'
                  : (item.naziv ?? ''),
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(item.cijena != null ? '${item.cijena!.toStringAsFixed(2)} KM' : ''),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text('${item.trajanje ?? ''} min'),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: item.slika != null && item.slika!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(item.slika!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/images/praznaUsluga.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.opis != null && item.opis!.length > 20)
                  ? '${item.opis!.substring(0, 20)}...'
                  : (item.opis ?? ''),
            ),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              if (!context.mounted) return; 
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FrizerUslugeDetailsScreen(
                  usluga: item,
                ),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(120, 50),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 20),
                SizedBox(width: 8),
                Text('Detalji'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void filterServerSide() async {
    if (!context.mounted) return; 
    await reset(targetPage: 1);
  }

  Future<void> reset({int? targetPage}) async {
    final newPage = targetPage ?? page;
    if (!context.mounted) return; 
    final result = await provider.get(
      filter: {'NazivOpisFTS': nazivFilter},
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      if (!context.mounted) return; 
      final fallbackResult = await provider.get(
        filter: {'NazivOpisFTS': nazivFilter},
        page: fallbackPage,
        pageSize: pageSize,
      );
      newData = fallbackResult.result;
      newCount = fallbackResult.count;
      page = fallbackPage;
    } else {
      page = newPage;
    }

    data = newData;
    count = newCount;

    setNextView(startIndex: (page - 1) * pageSize);
    if (!context.mounted) return; 
    await Future.delayed(const Duration(milliseconds: 100)); 
    notifyListeners();
  }
  
      @override
    Future<RemoteDataSourceDetails<Usluga>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'NazivOpisFTS': nazivFilter
    };

    try { 
      if (!context.mounted) return RemoteDataSourceDetails(0, []);
      final result =
          await provider.get(filter: filter, page: page, pageSize: pageSize);
      data = result.result;
      count = result.count;
      return RemoteDataSourceDetails(count, data);
    } catch (e) {
        if (!context.mounted) return RemoteDataSourceDetails(0, []);
        QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: "Greška",
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
        );
      return RemoteDataSourceDetails(0, []);
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => count;

  @override
  int get selectedRowCount => 0;
}
