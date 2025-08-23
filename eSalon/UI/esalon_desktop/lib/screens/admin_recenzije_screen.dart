import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/recenzija.dart';
import 'package:esalon_desktop/models/recenzija_odgovor.dart';
import 'package:esalon_desktop/providers/recenzija_provider.dart';
import 'package:esalon_desktop/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_desktop/screens/admin_recenzije_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

enum PrikazTipa { recenzije, odgovori }

class AdminRecenzijaScreen extends StatefulWidget {
  const AdminRecenzijaScreen({super.key});

  @override
  State<AdminRecenzijaScreen> createState() => _AdminRecenzijaScreenState();
}

class _AdminRecenzijaScreenState extends State<AdminRecenzijaScreen> {
  late RecenzijaProvider _recenzijaProvider;
  late RecenzijaOdgovorProvider _odgovorProvider;
  late RecenzijaDataSource _source;

  PrikazTipa _prikazTipa = PrikazTipa.recenzije;

  final TextEditingController _korisnickoImeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recenzijaProvider = context.read<RecenzijaProvider>();
    _odgovorProvider = context.read<RecenzijaOdgovorProvider>();
    _source = RecenzijaDataSource(
      recenzijaProvider: _recenzijaProvider,
      odgovorProvider: _odgovorProvider,
      context: context,
    );
    _source.loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    String naslov = _prikazTipa == PrikazTipa.recenzije
        ? "Recenzije"
        : "Odgovori na recenzije";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            naslov,
            style: const TextStyle(fontSize: 26, color: Colors.black),
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
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _korisnickoImeController,
                  decoration: InputDecoration(
                    labelText: 'Korisničko ime',
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
                    _source.korisnickoImeFilter = value;
                    _source.filterServerSide();
                  },
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (!mounted) return;
                  setState(() {
                    _korisnickoImeController.clear();
                    _source.korisnickoImeFilter = '';
                    _prikazTipa = PrikazTipa.recenzije; 
                    _source.tip = PrikazTipa.recenzije;  
                  });
                  _source.filterServerSide(); 
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
          const SizedBox(height: 15),
          Row(
            children: [
              Radio<PrikazTipa>(
                value: PrikazTipa.recenzije,
                groupValue: _prikazTipa,
                onChanged: (value) {
                  if (value != null) {
                    if (!mounted) return;
                    setState(() {
                      _prikazTipa = value;
                      _source.tip = _prikazTipa;
                      _source.filterServerSide();
                    });
                  }
                },
              ),
              const Text("Prikaži recenzije"),
              const SizedBox(width: 20),
              Radio<PrikazTipa>(
                value: PrikazTipa.odgovori,
                groupValue: _prikazTipa,
                onChanged: (value) {
                  if (value != null) {
                    if (!mounted) return;
                    setState(() {
                      _prikazTipa = value;
                      _source.tip = _prikazTipa;
                      _source.filterServerSide();
                    });
                  }
                },
              ),
              const Text("Prikaži odgovore"),
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
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija korisničkog imena (20 karaktera).",
                          child: Text("Korisničko ime"),
                        ),
                      ),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija komentara (30 karaktera).",
                          child: Text("Komentar"),
                        ),
                      ),
                      DataColumn(label: Text('Broj lajkova')),
                      DataColumn(label: Text('Broj dislajkova')),
                      DataColumn(label: Text('Detalji')),
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

class RecenzijaDataSource extends AdvancedDataTableSource<dynamic> {
  final RecenzijaProvider recenzijaProvider;
  final RecenzijaOdgovorProvider odgovorProvider;
  final BuildContext context;

  PrikazTipa tip = PrikazTipa.recenzije;

  String korisnickoImeFilter = '';
  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<dynamic> data = [];

  RecenzijaDataSource({
    required this.recenzijaProvider,
    required this.odgovorProvider,
    required this.context,
  });

  Future<void> loadInitial() async {
    await reset(targetPage: page);
  }

  void filterServerSide() async {
    await reset(targetPage: 1);
  }

  Future<void> reset({int? targetPage}) async {
    final newPage = targetPage ?? page;

    final filter = {
      'korisnickoIme': korisnickoImeFilter,
    };

    try {
      if (tip == PrikazTipa.recenzije) {
        final result = await recenzijaProvider.get(
          filter: filter,
          page: newPage,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      } else {
        final result = await odgovorProvider.get(
          filter: filter,
          page: newPage,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      }

      page = newPage;
      setNextView(startIndex: (page - 1) * pageSize);
      notifyListeners();
    } catch (e) {
      debugPrint('Greška: $e');
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];

    String komentar = '';
    int brojLajkova = 0;
    int brojDislajkova = 0;

    if (item is Recenzija) {
      komentar = item.komentar;
      brojLajkova = item.brojLajkova;
      brojDislajkova = item.brojDislajkova;
    } else if (item is RecenzijaOdgovor) {
      komentar = item.komentar;
      brojLajkova = item.brojLajkova;
      brojDislajkova = item.brojDislajkova;
    }

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
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminRecenzijeDetailsScreen(item: item),
            ),
          );
          await reset(); 
        }
      },
      cells: [
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (item.korisnickoIme != null && item.korisnickoIme!.length > 20)
                  ? '${item.korisnickoIme!.substring(0, 20)}...'
                  : item.korisnickoIme ?? '',
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(
              (komentar.length > 30)
                  ? '${komentar.substring(0, 30)}...'
                  : komentar,
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(brojLajkova.toString()),
          ),
        ),
        DataCell(
          Tooltip(
            message: 'Klik za detalje',
            child: Text(brojDislajkova.toString()),
          ),
        ),
        DataCell(
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 180, 140, 218),
              foregroundColor: const Color.fromARGB(199, 0, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(120, 50),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminRecenzijeDetailsScreen(item: item),
                ),
              );
              await reset(); 
            },
            child: const Text("Detalji"),
          ),
        ),
      ],
    );
  }

  @override
  Future<RemoteDataSourceDetails<dynamic>> getNextPage(NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'KorisnickoIme': korisnickoImeFilter,
    };

    try{
      if (tip == PrikazTipa.recenzije) {
        final result = await recenzijaProvider.get(
          filter: filter,
          page: page,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      } else {
        final result = await odgovorProvider.get(
          filter: filter,
          page: page,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      }

      return RemoteDataSourceDetails(count, data);
    }  catch (e) {
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
