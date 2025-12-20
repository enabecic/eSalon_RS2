import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:esalon_desktop/models/korisnik.dart';
import 'package:esalon_desktop/models/uloga.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/uloga_provider.dart';
import 'package:esalon_desktop/screens/admin_dodaj_frizera_screen.dart';
import 'package:esalon_desktop/screens/korisnici_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esalon_desktop/main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminKorisniciScreen extends StatefulWidget {
  const AdminKorisniciScreen({super.key});

  @override
  State<AdminKorisniciScreen> createState() => _AdminKorisniciScreenState();
}

class _AdminKorisniciScreenState extends State<AdminKorisniciScreen> {
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
      if (!mounted) return;
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
              minimumSize: const Size(130, 63),
            ),
            child: const Text("Očisti"),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              var result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>  const AdminDodajFrizeraScreen(),
              ));
              if (result == true) {
                if (!mounted) return;
                final refreshed = await _korisnikProvider.get(
                  filter: {'KorisnickoIme': _source.korisnickoImeFilter},
                  page: 1,
                  pageSize: _source.pageSize,
                );
                int lastPage = (refreshed.count / _source.pageSize).ceil();
                if (!mounted) return;
                await _source.reset(targetPage: lastPage);
                if (!mounted) return;
                await Future.delayed(const Duration(milliseconds: 10)); 

                if (!mounted) return;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Future.delayed(const Duration(seconds: 3), () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    });

                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text("Dodano"),
                      content: const Text("Frizer je uspješno dodan."),
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
            child: const Text("Dodaj frizera"),
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
                      DataColumn(label: Text("Opcije")),
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
      if (ulogaIdFilter != null) 'UlogaId': ulogaIdFilter,
    };
    if (!context.mounted) return;
    final result = await provider.get(
      filter: filter,
      page: newPage,
      pageSize: pageSize,
    );

    var newData = result.result;
    var newCount = result.count;

    if (newData.isEmpty && newPage > 1) {
      final fallbackPage = newPage - 1;
      if (!context.mounted) return;
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
    if (!context.mounted) return;
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
        if (!context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => KorisniciDetailsScreen(korisnik: item),
          ),
        );
        if (!context.mounted) return;
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
        DataCell(Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(item.jeAktivan == true
                      ? "Deaktivacija korisnika"
                      : "Aktivacija korisnika"),
                  content: Text("Da li ste sigurni da želite ${item.jeAktivan == true ? "deaktivirati" : "aktivirati"} ovog korisnika?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7), 
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Ne",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7), 
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
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
                  if (item.jeAktivan == true) {
                    if (!context.mounted) return;
                    await provider.deaktiviraj(item.korisnikId!);

                    if (item.korisnikId == AuthProvider.korisnikId) {
                      AuthProvider.username = null;
                      AuthProvider.password = null;
                      AuthProvider.korisnikId = null;
                      AuthProvider.ime = null;
                      AuthProvider.prezime = null;
                      AuthProvider.email = null;
                      AuthProvider.telefon = null;
                      AuthProvider.uloge = null;
                      AuthProvider.isSignedIn = false;
                      AuthProvider.slika = null;
                      AuthProvider.datumRegistracije = null;
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                      return;
                    }
                  } else {
                    if (!context.mounted) return;
                    await provider.aktiviraj(item.korisnikId!);
                  }
                  if (!context.mounted) return;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Uspjeh"),
                      content: Text( "Korisnik je uspješno ${item.jeAktivan == true ? 'deaktiviran' : 'aktiviran'}.",),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (!context.mounted) return;
                  await reset();
                } catch (e) {
                  if (!context.mounted) return;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Greška"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(120, 50),
              ),
              child: Text(item.jeAktivan == true ? "Deaktiviraj" : "Aktiviraj"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => KorisniciDetailsScreen(korisnik: item),
                  ),
                );
                if (!context.mounted) return;
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
        )),
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
