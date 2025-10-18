import 'dart:convert'; 
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/aktivirana_promocija.dart';
import 'package:esalon_desktop/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/screens/admin_aktivirana_promocija_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminAktiviranaPromocijaScreen extends StatefulWidget {
  const AdminAktiviranaPromocijaScreen({super.key});

  @override
  State<AdminAktiviranaPromocijaScreen> createState() =>
      _AdminAktiviranaPromocijaScreenState();
}

class _AdminAktiviranaPromocijaScreenState
    extends State<AdminAktiviranaPromocijaScreen> {
  late AktiviranaPromocijaProvider _aktiviranaPromocijaProvider;
  late AktiviranaPromocijaDataSource _source;

  final TextEditingController _klijentController = TextEditingController();
  final TextEditingController _promocijaNazivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aktiviranaPromocijaProvider = context.read<AktiviranaPromocijaProvider>();
    _source =
        AktiviranaPromocijaDataSource(provider: _aktiviranaPromocijaProvider, context: context);
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
            "Aktivirane promocije",
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
              controller: _klijentController,
              decoration: InputDecoration(
                labelText: 'Ime ili prezime korisnika',
                filled: true,
                fillColor: MaterialStateColor.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return const Color(0xFFE0D7F5);
                  }
                  if (states.contains(MaterialState.focused)) {
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
                _source.korisnikImePrezimeFilter = value;
                _source.filterServerSide();
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: _promocijaNazivController,
              decoration: InputDecoration(
                labelText: 'Naziv promocije',
                filled: true,
                fillColor: MaterialStateColor.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return const Color(0xFFE0D7F5);
                  }
                  if (states.contains(MaterialState.focused)) {
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
                _source.promocijaNazivFilter = value;
                _source.filterServerSide();
              },
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              const Text("Iskorištena: "),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    hoverColor: const Color(0xFFE0D7F5), 
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: DropdownButton<bool?>(
                    isDense: false,
                    itemHeight: 48, 
                    iconSize: 24,
                    value: _source.iskoristenaFilter,
                    hint: const Text("Sve"),
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _source.iskoristenaFilter = value;
                        _source.filterServerSide();
                      });
                    },
                    items: const [
                      DropdownMenuItem(value: null, child: Text("Sve")),
                      DropdownMenuItem(value: true, child: Text("Da")),
                      DropdownMenuItem(value: false, child: Text("Ne")),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              _klijentController.clear();
              _source.korisnikImePrezimeFilter = '';
              _promocijaNazivController.clear();
              _source.promocijaNazivFilter = '';
              _source.iskoristenaFilter = null;
              _source.filterServerSide();
              if (!mounted) return;
              setState(() {}); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(150, 63),
            ),
            child: const Text("Očisti"),
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
                      headingRowColor: MaterialStateProperty.all(
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
                          message: "Prikazuje se skraćena verzija naziva promocije (40 karaktera).",
                          child: Text("Naziv promocije"),
                        ),
                      ),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija imena i prezimena korisnika (25 karaktera).",
                          child: Text("Ime i prezime korisnika"),
                        ),
                      ),
                      DataColumn(label: Text('Iskorištena')),
                      DataColumn(label: Text("Slika usluge")),
                      DataColumn(label: Text("Detalji")),
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

class AktiviranaPromocijaDataSource extends AdvancedDataTableSource<AktiviranaPromocija> {
  final AktiviranaPromocijaProvider provider;
  final BuildContext context;

  bool? iskoristenaFilter;

  String korisnikImePrezimeFilter= '';
  String promocijaNazivFilter = '';

  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<AktiviranaPromocija> data = [];

  AktiviranaPromocijaDataSource({
    required this.provider,
    required this.context,
  });

  Future<void> loadInitial() async {
    if (AuthProvider.korisnikId == null) return;
    if (!context.mounted) return;

    try {
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
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected) ||
            states.contains(MaterialState.hovered)) {
          return const Color(0xFFE0D7F5);
        }
        return null;
      }),

      onSelectChanged: (selected) async {
        if (selected == true) {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AdminAktiviranaPromocijaDetails(aktiviranaPromocija: item),
          ));
        }
      },
      cells: [
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.promocijaNaziv != null && item.promocijaNaziv!.length > 40)
                  ? '${item.promocijaNaziv!.substring(0, 40)}...'
                  : item.promocijaNaziv ?? '',
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.korisnikImePrezime != null && item.korisnikImePrezime!.length > 25)
                  ? '${item.korisnikImePrezime!.substring(0, 25)}...'
                  : item.korisnikImePrezime ?? '',
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(item.iskoristena == true ? 'Da' : 'Ne'),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: item.slikaUsluge != null && item.slikaUsluge!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      base64Decode(item.slikaUsluge!),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/images/praznaUsluga.png",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminAktiviranaPromocijaDetails(
                    aktiviranaPromocija: item,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0), 
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
              minimumSize: const Size(120, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Detalji",
              style: TextStyle(
                fontWeight: FontWeight.w500, 
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void filterServerSide() async {
    await reset(targetPage: 1);
  }

  Future<void> reset({int? targetPage}) async {
    final newPage = targetPage ?? page;

    final result = await provider.get(
      filter: {
        'KorisnikImePrezime': korisnikImePrezimeFilter,
        'Iskoristena': iskoristenaFilter,
        'PromocijaNaziv': promocijaNazivFilter,
      },
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      final fallbackResult = await provider.get(
        filter: {
          'KorisnikImePrezime': korisnikImePrezimeFilter,
          'Iskoristena': iskoristenaFilter,
          'PromocijaNaziv': promocijaNazivFilter,
        },
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
    await Future.delayed(const Duration(milliseconds: 100)); 
    notifyListeners();
  }

  @override
  Future<RemoteDataSourceDetails<AktiviranaPromocija>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'KorisnikImePrezime': korisnikImePrezimeFilter,
      'Iskoristena': iskoristenaFilter,
      'PromocijaNaziv': promocijaNazivFilter,
    };

    try {
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
