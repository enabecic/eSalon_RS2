import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/recenzija.dart';
import 'package:esalon_desktop/models/recenzija_odgovor.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/recenzija_provider.dart';
import 'package:esalon_desktop/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_desktop/screens/frizer_recenzije_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

enum PrikazTipa { recenzije, odgovori }

class FrizerRecenzijaScreen extends StatefulWidget {
  const FrizerRecenzijaScreen({super.key});

  @override
  State<FrizerRecenzijaScreen> createState() => _FrizerRecenzijaScreenState();
}

class _FrizerRecenzijaScreenState extends State<FrizerRecenzijaScreen> {
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
                    hintText: 'Unesite korisničko ime',
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
          const SizedBox(height: 15),
          Row(
            children: [
              RadioGroup<PrikazTipa>(
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
                child: const Radio<PrikazTipa>(
                  value: PrikazTipa.recenzije,
                ),
              ),
              const Text("Prikaži recenzije"),
              const SizedBox(width: 20),
              RadioGroup<PrikazTipa>(
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
                child: const Radio<PrikazTipa>(
                  value: PrikazTipa.odgovori,
                ),
              ),
              const Text("Prikaži odgovore"),
              const SizedBox(width: 15),

              const Tooltip(
                message: "Izaberite da prikažete korisničke recenzije ili odgovore na njih.",
                child: Icon(
                  Icons.info_outline,
                  color: Colors.grey,
                  size: 20,
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
                          message: "Prikazuje se skraćena verzija korisničkog imena (20 karaktera).",
                          child: Text("KORISNIČKO IME"),
                        ),
                      ),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija komentara (30 karaktera).",
                          child: Text("KOMENTAR"),
                        ),
                      ),
                      DataColumn(label: Text('BROJ LAJKOVA')),
                      DataColumn(label: Text('BROJ DISLAJKOVA')),
                      DataColumn(label: Text('OPCIJE')),
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

  void filterServerSide() async {
    if (!context.mounted) return;
    await reset(targetPage: 1);
  }

  Future<void> reset({int? targetPage}) async {
    final newPage = targetPage ?? page;

    final filter = {
      'KorisnickoIme': korisnickoImeFilter,
    };

    try {
      if (tip == PrikazTipa.recenzije) {
        if (!context.mounted) return;
        final result = await recenzijaProvider.get(
          filter: filter,
          page: newPage,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      } else {
        if (!context.mounted) return;
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
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FrizerRecenzijeDetailsScreen(item: item),
            ),
          );
          if (!context.mounted) return;
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
              if (!context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FrizerRecenzijeDetailsScreen(item: item),
                ),
              );
              if (!context.mounted) return;
              await reset(); 
            },
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

  @override
  Future<RemoteDataSourceDetails<dynamic>> getNextPage(NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'KorisnickoIme': korisnickoImeFilter,
    };

    try{
      if (tip == PrikazTipa.recenzije) {
        if (!context.mounted) return RemoteDataSourceDetails(0, []);
        final result = await recenzijaProvider.get(
          filter: filter,
          page: page,
          pageSize: pageSize,
        );
        data = result.result;
        count = result.count;
      } else {
        if (!context.mounted) return RemoteDataSourceDetails(0, []);
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
