import 'dart:convert'; 
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
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
            ),
            child: const Text("Očisti"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              var result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AdminUrediDodajVrstuUslugeScreen(),
              ));
              if (result == true) {
                final refreshed = await _vrstaUslugeProvider.get(
                  filter: {'naziv': _source.nazivFilter},
                  page: 1,
                  pageSize: _source.pageSize,
                );
                int lastPage = (refreshed.count / _source.pageSize).ceil();
                await _source.reset(targetPage: lastPage);

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
            ),
            child: const Text("Dodaj novu"),
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
                      DataColumn(label: Text("Naziv")),
                      DataColumn(label: Text("Slika")),
                      DataColumn(label: Text("Obriši")),
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
    await reset(targetPage: page);
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
          var result = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AdminUrediDodajVrstuUslugeScreen(vrstaUsluge: item),
          ));
          if (result == true) {
            await reset(targetPage: page); 

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
        DataCell(Text(item.naziv ?? '')),
        DataCell(
          item.slika != null && item.slika!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(item.slika!),
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
        DataCell(
          ElevatedButton(
            onPressed: () async {
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
                  await provider.delete(item.vrstaId!);
                  await reset(targetPage: page); 

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
            ),
            child: const Text("Obriši"),
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
      filter: {'naziv': nazivFilter},
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      final fallbackResult = await provider.get(
        filter: {'naziv': nazivFilter},
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
  Future<RemoteDataSourceDetails<VrstaUsluge>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final result = await provider.get(
      filter: {'naziv': nazivFilter},
      page: page,
      pageSize: pageSize,
    );

    data = result.result;
    count = result.count;

    return RemoteDataSourceDetails(count, data);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => count;

  @override
  int get selectedRowCount => 0;
}
