import 'dart:convert'; 
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:esalon_desktop/models/vrsta_usluge.dart';
import 'package:esalon_desktop/providers/vrsta_usluge_provider.dart';
import 'package:esalon_desktop/screens/admin_uredi_dodaj_vrstu_usluge_screen.dart';

class AdminUpravljanjeVrstamaUslugaScreen extends StatefulWidget {
  const AdminUpravljanjeVrstamaUslugaScreen({super.key});

  @override
  State<AdminUpravljanjeVrstamaUslugaScreen> createState() =>
      _AdminUpravljanjeVrstamaUslugaScreenState();
}

class _AdminUpravljanjeVrstamaUslugaScreenState
    extends State<AdminUpravljanjeVrstamaUslugaScreen> {
  late VrstaUslugeProvider _vrstaUslugeProvider;
  late VrstaUslugeDataSource _source;

  final TextEditingController _nazivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vrstaUslugeProvider = context.read<VrstaUslugeProvider>();
    _source =
        VrstaUslugeDataSource(provider: _vrstaUslugeProvider, context: context);
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
            "Vrste usluga",
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
                labelText: 'Naziv vrste usluge',
                hintText: 'Unesite naziv vrste usluge',
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
          const SizedBox(width: 10),
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
              minimumSize: const Size(130, 63),
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
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              var result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AdminUrediDodajVrstuUslugeScreen(),
              ));
              if (result == true) {
                if (!mounted) return;
                final refreshed = await _vrstaUslugeProvider.get(
                  filter: {'Naziv': _source.nazivFilter},
                  page: 1,
                  pageSize: _source.pageSize,
                );
                int lastPage = (refreshed.count / _source.pageSize).ceil();
                if (!mounted) return;
                await _source.reset(targetPage: lastPage);
                if (!mounted) return;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Dodano"),
                      content: const Text("Vrsta usluge je uspješno dodana."),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
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
                Icon(Icons.add, size: 18, color: Color.fromARGB(199, 0, 0, 0)),
                SizedBox(width: 6),
                Text('Dodaj novu', style: TextStyle(color: Color.fromARGB(199, 0, 0, 0))),
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
                          message: "Prikazuje se skraćena verzija naziva (40 karaktera).",
                          child: Text("NAZIV"),
                        ),
                      ),
                      DataColumn(label: Text("SLIKA")),
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

class VrstaUslugeDataSource extends AdvancedDataTableSource<VrstaUsluge> {
  final VrstaUslugeProvider provider;
  final BuildContext context;

  String nazivFilter = '';
  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<VrstaUsluge> data = [];

  VrstaUslugeDataSource({
    required this.provider,
    required this.context,
  });

  Future<void> loadInitial() async {
  if (AuthProvider.korisnikId == null) return; 
  if (!context.mounted) return;
  
  try {
    if (!context.mounted) return;
    await  reset(targetPage: page);
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
          var result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AdminUrediDodajVrstuUslugeScreen(vrstaUsluge: item),
          ));
          if (result == true) {
            if (!context.mounted) return;
            await reset(targetPage: page); 
            if (!context.mounted) return;
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Uređeno"),
                  content: const Text("Vrsta usluge je uspješno uređena."),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        }
      },
      cells: [
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.naziv != null && item.naziv!.length > 40)
                  ? '${item.naziv!.substring(0, 40)}...'
                  : (item.naziv ?? ''),
            ),
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
                      "assets/images/praznaVrstaUsluge.png",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        DataCell(
          ElevatedButton(
            onPressed: () async {
              if (!context.mounted) return;
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Potvrda brisanja"),
                  content: const Text("Da li želite obrisati vrstu usluge?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Ne",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context,true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Da",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  if (!context.mounted) return;
                  await provider.delete(item.vrstaId!);
                  if (!context.mounted) return;
                  await reset(targetPage: page); 
                  if (!context.mounted) return;
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Obrisano"),
                        content: const Text("Vrsta usluge je uspješno obrisana."),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } on UserException catch (e) {
                  if (!context.mounted) return;
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
                }
              }
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
                Icon(Icons.delete_outline, size: 20),
                SizedBox(width: 8),
                Text('Obriši'),
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
      filter: {'Naziv': nazivFilter},
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      if (!context.mounted) return;
      final fallbackResult = await provider.get(
        filter: {'Naziv': nazivFilter},
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
    Future<RemoteDataSourceDetails<VrstaUsluge>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'Naziv': nazivFilter
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
