import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/models/uloga.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/uloga_provider.dart';
import 'package:esalon_desktop/screens/korisnici_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FrizerKorisniciScreen extends StatefulWidget {
  const FrizerKorisniciScreen({super.key});

  @override
  State<FrizerKorisniciScreen> createState() => _FrizerKorisniciScreenState();
}

class _FrizerKorisniciScreenState extends State<FrizerKorisniciScreen> {
  late KorisnikProvider _korisnikProvider;
  late KorisnikDataSource _source;

  final TextEditingController _korisnickoImeController = TextEditingController();
  Uloga? _selectedUloga;
  late UlogaProvider _ulogaProvider;
  List<Uloga> _ulogeList = [];

  @override
  void initState() {
    super.initState();
    _korisnikProvider = context.read<KorisnikProvider>();
    _ulogaProvider = context.read<UlogaProvider>();
    _source = KorisnikDataSource(provider: _korisnikProvider, context: context);
    _source.loadInitial();
    _loadUloge();
  }

  Future<void> _loadUloge() async {
    if (AuthProvider.korisnikId == null) return;
    if (!context.mounted) return;

    try {
      final result = await _ulogaProvider.get();
      if (!mounted) return;
      setState(() {
        _ulogeList = result.result;
      });
    } catch (e) {
      if (!mounted) return;
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Korisnici",
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
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: Container(
              height: 56, 
              width: 250, 
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade500, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<Uloga>(
                isExpanded: true,
                value: _selectedUloga,
                hint: const Text("Odaberi ulogu"),
                onChanged: (value) {
                  if (!mounted) return;
                  setState(() {
                    _selectedUloga = value;
                  });
                  _source.ulogaIdFilter = value?.ulogaId;
                  _source.filterServerSide();
                },
                items: _ulogeList
                    .map((uloga) => DropdownMenuItem(
                          value: uloga,
                          child: Text(uloga.naziv ?? ''),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              _korisnickoImeController.clear();
              if (!mounted) return;
              setState(() {
                _selectedUloga = null;
              });
              _source.korisnickoImeFilter = '';
              _source.ulogaIdFilter = null;
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
                          message: "Prikazuje se skraćena verzija email-a (20 karaktera).",
                          child: Text("Email"),
                        ),
                      ),
                      DataColumn(
                        label: Tooltip(
                          message: "Prikazuje se skraćena verzija uloga (25 karaktera).",
                          child: Text("Uloge"),
                        ),
                      ),
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

class KorisnikDataSource extends AdvancedDataTableSource<Korisnik> {
  final KorisnikProvider provider;
  final BuildContext context;

  String korisnickoImeFilter = '';
  int? ulogaIdFilter;

  int count = 0;
  int page = 1;
  final int pageSize = 5;
  List<Korisnik> data = [];

  KorisnikDataSource({
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

  void filterServerSide() async {
    await reset(targetPage: 1);
  }

  Future<void> reset({int? targetPage}) async {
    final newPage = targetPage ?? page;
    final filter = {
      'KorisnickoIme': korisnickoImeFilter,
      if (ulogaIdFilter != null) 'UlogaId': ulogaIdFilter,
    };

    final result = await provider.get(
      filter: filter,
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      final fallbackResult = await provider.get(
        filter: filter,
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
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final item = data[index];
    final ulogeText = item.uloge?.join(', ') ?? '';

    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.selected) ||
            states.contains(MaterialState.hovered)) {
          return const Color(0xFFE0D7F5);
        }
        return null;
      }),
      onSelectChanged: (_) async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => KorisniciDetailsScreen(korisnik: item),
          ),
        );
        await reset();
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
              (item.email != null && item.email!.length > 20)
                  ? '${item.email!.substring(0, 20)}...'
                  : item.email ?? '',
            ),
          ),
        ),
        DataCell(
          Tooltip(
            message: "Klikni za detalje",
            child: Text(
              (ulogeText.length > 25) 
                  ? '${ulogeText.substring(0, 25)}...' 
                  : ulogeText,
            ),
          ),
        ),
        DataCell(
          Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KorisniciDetailsScreen(korisnik: item),
                  ),
                );
                await reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(120, 50),
              ),
              child: const Text("Detalji"),
            ),
          ],
         )
        ),
      ],
    );
  }

    @override
  Future<RemoteDataSourceDetails<Korisnik>> getNextPage(
      NextPageRequest pageRequest) async {
    page = (pageRequest.offset ~/ pageSize) + 1;

    final filter = {
      'KorisnickoIme': korisnickoImeFilter,
      if (ulogaIdFilter != null) 'UlogaId': ulogaIdFilter,
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
