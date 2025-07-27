import 'dart:convert'; 
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/promocija.dart';
import 'package:esalon_desktop/providers/base_provider.dart';
import 'package:esalon_desktop/providers/promocija_provider.dart';
import 'package:esalon_desktop/screens/admin_promocija_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminPromocijaScreen extends StatefulWidget {
  const AdminPromocijaScreen({super.key});

  @override
  State<AdminPromocijaScreen> createState() =>
      _AdminUpravljanjeUslugamaScreenState();
}

class _AdminUpravljanjeUslugamaScreenState
    extends State<AdminPromocijaScreen> {
  late PromocijaProvider _promocijaProvider;
  late PromocijaDataSource _source;

  RangeValues _popustRange = const RangeValues(0, 100);

  final TextEditingController _nazivController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _promocijaProvider = context.read<PromocijaProvider>();
    _source =
        PromocijaDataSource(provider: _promocijaProvider, context: context);
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
            "Promocije",
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nazivController,
                decoration: InputDecoration(
                  labelText: 'Naziv ili opis promocije',
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
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade600, width: 2.0),
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
                setState(() {
                  _nazivController.clear();
                  _source.nazivFilter = '';
                  _source.samoAktivne = null;
                  _source.samoBuduce = null;
                  _source.samoProsle = null;
                  _popustRange = const RangeValues(0, 100);
                  _source.popustGTE = 0;
                  _source.popustLTE = 100;
                });
                _source.filterServerSide();
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Očisti"),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                var result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminPromocijaDetails(),
                  ),
                );
                if (result == true) {
                  final refreshed = await _promocijaProvider.get(
                    filter: {
                      'nazivOpisFTS': _source.nazivFilter,
                      if (_source.samoAktivne != null)
                        'samoAktivne': _source.samoAktivne,
                      if (_source.samoBuduce != null)
                        'samoBuduce': _source.samoBuduce,
                      if (_source.samoProsle != null)
                        'samoProsle': _source.samoProsle,
                    },
                    page: 1,
                    pageSize: _source.pageSize,
                  );
                  int lastPage = (refreshed.count / _source.pageSize).ceil();
                  await _source.reset(targetPage: lastPage);

                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text("Dodano"),
                        content:
                            const Text("Promocija je uspješno dodana."),
                        actions: [
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pop(),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Dodaj novu"),
            ),
          ],
        ),
const SizedBox(height: 20),

Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    Expanded(
      flex: 2,
      child: Wrap(
        spacing: 10,
        children: [
          FilterChip(
            label: const Text("Sve"),
            selected: _source.samoAktivne == null &&
                _source.samoBuduce == null &&
                _source.samoProsle == null,
            onSelected: (_) {
              setState(() {
                _source.samoAktivne = null;
                _source.samoBuduce = null;
                _source.samoProsle = null;
              });
              _source.filterServerSide();
            },
            selectedColor: const Color(0xFFE0D7F5),
            labelStyle: const TextStyle(color: Colors.black),
            side: const BorderSide(color: Colors.transparent),
            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          FilterChip(
            label: const Text("Aktivne"),
            selected: _source.samoAktivne == true,
            onSelected: (_) {
              setState(() {
                _source.samoAktivne = true;
                _source.samoBuduce = null;
                _source.samoProsle = null;
              });
              _source.filterServerSide();
            },
            selectedColor: const Color(0xFFE0D7F5),
            labelStyle: const TextStyle(color: Colors.black),
            side: const BorderSide(color: Colors.transparent),
            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          FilterChip(
            label: const Text("Buduće"),
            selected: _source.samoBuduce == true,
            onSelected: (_) {
              setState(() {
                _source.samoAktivne = null;
                _source.samoBuduce = true;
                _source.samoProsle = null;
              });
              _source.filterServerSide();
            },
            selectedColor: const Color(0xFFE0D7F5),
            labelStyle: const TextStyle(color: Colors.black),
            side: const BorderSide(color: Colors.transparent),
            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          FilterChip(
            label: const Text("Prošle"),
            selected: _source.samoProsle == true,
            onSelected: (_) {
              setState(() {
                _source.samoAktivne = null;
                _source.samoBuduce = null;
                _source.samoProsle = true;
              });
              _source.filterServerSide();
            },
            selectedColor: const Color(0xFFE0D7F5),
            labelStyle: const TextStyle(color: Colors.black),
            side: const BorderSide(color: Colors.transparent),
            backgroundColor: const Color.fromARGB(255, 180, 140, 218),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    ),
    const SizedBox(width: 20),
    Expanded(
      flex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Popust od - do (%)', style: TextStyle(fontWeight: FontWeight.normal)),
          RangeSlider(
            values: _popustRange,
            min: 0,
            max: 100,
            divisions: 20,
            labels: RangeLabels(
              '${_popustRange.start.round()}%',
              '${_popustRange.end.round()}%',
            ),
            onChanged: (values) {
              setState(() {
                _popustRange = values;
                _source.popustGTE = values.start;
                _source.popustLTE = values.end;
              });
              _source.filterServerSide();
            },
          ),
              Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_popustRange.start.round()}%'),
                      Text('${_popustRange.end.round()}%'),
                    ],
                  ),
                  ],
                ),
              ),
            ],
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
                      DataColumn(label: Text("Naziv promocije")),
                      DataColumn(label: Text("Popust")),
                      DataColumn(label: Text("Naziv usluge")),
                      DataColumn(label: Text("Slika usluge")),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija opisa (20 karaktera).",
                          child: Text("Opis"),
                        ),
                      ),
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

class PromocijaDataSource extends AdvancedDataTableSource<Promocija> {
  final PromocijaProvider provider;
  final BuildContext context;

  String nazivFilter = '';
  bool? samoAktivne;
  bool? samoBuduce;
  bool? samoProsle;
  double? popustGTE;
  double? popustLTE;

  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<Promocija> data = [];
   
  PromocijaDataSource({
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
            builder: (_) => AdminPromocijaDetails(promocija: item),
          ));
          if (result == true) {
            await reset(targetPage: page); 

            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Uređeno"),
                  content: const Text("Promocija je uspješno uređena."),
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
            child: Text(item.naziv ?? ''),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text('${item.popust?.toInt() ?? 0}%'),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(item.uslugaNaziv ?? ''),
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
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text("Potvrda brisanja"),
                  content: const Text("Da li želite obrisati uslugu?"),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Ne",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Da",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await provider.delete(item.promocijaId!);
                  await reset(targetPage: page);

                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text("Obrisano"),
                        content: const Text("Promocija je uspješno obrisana."),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      filter: {
        'nazivOpisFTS': nazivFilter,
        'samoAktivne': samoAktivne,
        'samoBuduce': samoBuduce,
        'samoProsle': samoProsle, 
        if (popustGTE != null) 'popustGTE': popustGTE,
        if (popustLTE != null) 'popustLTE': popustLTE,
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
          'nazivOpisFTS': nazivFilter,
          'samoAktivne': samoAktivne,
          'samoBuduce': samoBuduce,
          'samoProsle': samoProsle,
          if (popustGTE != null) 'popustGTE': popustGTE,
          if (popustLTE != null) 'popustLTE': popustLTE,
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
  Future<RemoteDataSourceDetails<Promocija>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'NazivOpisFTS': nazivFilter,
      'SamoAktivne': samoAktivne,
      'SamoBuduce': samoBuduce,
      'SamoProsle': samoProsle,
      if (popustGTE != null) 'PopustGTE': popustGTE,
      if (popustLTE != null) 'PopustLTE': popustLTE,
    };

    try {
      final result =
          await provider.get(filter: filter, page: page, pageSize: pageSize);
      data = result.result;
      count = result.count;
      return RemoteDataSourceDetails(count, data);
    } catch (e) {
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

