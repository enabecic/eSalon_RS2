import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/providers/arhiva_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_desktop/providers/recenzija_provider.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:esalon_desktop/providers/usluga_provider.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  late KorisnikProvider korisnikProvider;
  late RezervacijaProvider rezervacijaProvider;
  late ArhivaProvider arhivaProvider;
  late RecenzijaProvider recenzijaProvider;
  late UslugaProvider uslugaProvider;
  late RecenzijaOdgovorProvider recenzijaOdgovorProvider;

  SearchResult rezervacije = SearchResult(); 
  SearchResult uslugeResult = SearchResult();

  bool isLoading = true;

  int brojKorisnika = 0;
  int brojArhiviranih = 0;
  int brojRecenzija = 0;
  String? najtrazenijaUslugaNaziv = "";
  int najtrazenijaBroj = 0;
  int brojRecenzijaOdgovor = 0;

  String? _selectedState; 
  final List<String> _states = ['odobrena', 'ponistena', 'zavrsena','kreirana'];


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      korisnikProvider = context.read<KorisnikProvider>();
      rezervacijaProvider = context.read<RezervacijaProvider>();
      arhivaProvider = context.read<ArhivaProvider>();
      recenzijaProvider = context.read<RecenzijaProvider>();
      uslugaProvider = context.read<UslugaProvider>();
      recenzijaOdgovorProvider = context.read<RecenzijaOdgovorProvider>();

      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;                 
    if (AuthProvider.korisnikId == null) return;

    try {
      final korisniciResult = await korisnikProvider.get();
      final rezervacijaResult = await rezervacijaProvider.get();
      final arhivaResult = await arhivaProvider.get();
      final recenzijaResult = await recenzijaProvider.get();
      final usluge = await uslugaProvider.get();
      final recenzijaOdgovorResult = await recenzijaOdgovorProvider.get();

      rezervacije = rezervacijaResult;
      uslugeResult = usluge;
      _izracunajNajtrazenijuUslugu();

      if (!mounted) return;
      setState(() {
        brojKorisnika = korisniciResult.count;
        brojArhiviranih = arhivaResult.count;
        brojRecenzija = recenzijaResult.count;
        brojRecenzijaOdgovor = recenzijaOdgovorResult.count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
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

  if (isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

    final brojOtkazanih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "ponistena")
        .length;
    final brojUkupno = rezervacije.result.length;
    final stopaOtkaza = brojUkupno > 0 ? (brojOtkazanih / brojUkupno) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
          child: Text(
            "Statistika",
            style: TextStyle(fontSize: 26, color: Colors.black),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildCard("Broj korisnika", brojKorisnika.toString())),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Stopa otkazanih rezervacija", "${stopaOtkaza.toStringAsFixed(1)}%")),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Ukupan broj rezervacija", brojUkupno.toString())),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildCard("Broj arhiviranih usluga", brojArhiviranih.toString())),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Trenutno najtraženija usluga",najtrazenijaUslugaNaziv ?? '',),),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Broj napisanih recenzija", (brojRecenzija + brojRecenzijaOdgovor).toString())),

                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Text(
                        'Filtriraj rezervacije po stanju:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        height: 45, 
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedState,
                          hint: const Text('Sve'),
                          dropdownColor: Colors.white, 
                          underline: const SizedBox.shrink(), 
                          borderRadius: BorderRadius.circular(8), 
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Sve')),
                            ..._states.map((stanje) => DropdownMenuItem(
                                  value: stanje,
                                  child: Text(
                                    stanje[0].toUpperCase() + stanje.substring(1),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                )),
                          ],
                          onChanged: (value) {
                             if (!mounted) return;
                            setState(() {
                              _selectedState = value;
                            });
                          },
                          isExpanded: false, 
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (_selectedState != null)
                        TextButton(
                          onPressed: () {
                             if (!mounted) return;
                            setState(() {
                              _selectedState = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size(160, 53),
                          ),
                          child: const Text(
                            'Očisti filter',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                 _buildLineChart(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                       onPressed: () async {
                        await _promptSaveReport();
                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(160, 53), 
                    ),
                    child: const Text(
                      "Sačuvaj izvještaj",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String label, String value) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 205, 235),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _izracunajNajtrazenijuUslugu() {
    Map<int, int> brojac = {};

    for (var r in rezervacije.result) {
      if (r.stateMachine?.toLowerCase() != 'ponistena' &&
          r.stavkeRezervacijes != null) {
        for (var stavka in r.stavkeRezervacijes!) {
          if (stavka.uslugaId != null) {
            brojac.update(stavka.uslugaId!, (v) => v + 1, ifAbsent: () => 1);
          }
        }
      }
    }

    var aktivniIdjevi = uslugeResult.result.map((u) => u.uslugaId).toSet();
    brojac.removeWhere((id, _) => !aktivniIdjevi.contains(id));

    if (brojac.isNotEmpty) {
      var najtrazenijaId =
          brojac.keys.reduce((a, b) => brojac[a]! > brojac[b]! ? a : b);
      najtrazenijaBroj = brojac[najtrazenijaId]!;

      var usluga = uslugeResult.result.firstWhere(
        (u) => u.uslugaId == najtrazenijaId,
        orElse: () => Usluga(naziv: "Nepoznata"),
      );
      najtrazenijaUslugaNaziv = usluga.naziv ?? "Nepoznata";
    }
    else {
    najtrazenijaUslugaNaziv = "Nepoznata";
    najtrazenijaBroj = 0;
  }
  }

  final GlobalKey _chartKey = GlobalKey();
  
  Widget _buildLineChart() {
    if (rezervacije.result.isEmpty || 
        rezervacije.result.where((r) => r.datumRezervacije != null && r.stateMachine != 'ponistena').isEmpty) {
      return const Center(
        child: Text(
          'Trenutno nema podataka za prikazati na grafu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    List<int> mjeseci = List.filled(12, 0);
    for (var r in rezervacije.result) {
      if (r.datumRezervacije != null &&
    (_selectedState == null || r.stateMachine?.toLowerCase() == _selectedState)) 
      {
        DateTime datum = r.datumRezervacije!;
        mjeseci[datum.month - 1]++;
      }
    }

    List<FlSpot> spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), mjeseci[index].toDouble()),
    );
    return RepaintBoundary(
      key: _chartKey, 
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 40), 
              child: Center(
                child: Text(
                  'Broj rezervacija po mjesecima',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          SizedBox(
            height: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: const Offset(0, 50),
                      child: Transform.rotate(
                        angle: -1.5708,
                        child: Text(
                          _selectedState == null
                              ? 'Broj rezervacija svih stanja'
                              : 'Broj rezervacija stanja: ${_selectedState![0].toUpperCase()}${_selectedState!.substring(1)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ),
                ),
                // Grafikon
                Expanded(
                  child: LineChart(
                    LineChartData(
                      showingTooltipIndicators: List.generate(spots.length, (index) => ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: spots),
                        0,
                        spots[index],
                      )
                    ])),
                      lineTouchData: LineTouchData(
                        enabled: false,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Colors.transparent,
                          tooltipPadding: EdgeInsets.zero,
                          tooltipMargin: 0,
                          tooltipBorder: const BorderSide(color: Colors.transparent),
                          tooltipRoundedRadius: 0,
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                '${spot.y.toInt()} rezervacija/e',
                                const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false), 
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Padding(
                            padding: EdgeInsets.only(bottom: 10), 
                          child: Text(
                            "Mjesec",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                            ),
                          ),
                          axisNameSize: 40,
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              const mjeseciNazivi = [
                                'Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun',
                                'Jul', 'Avg', 'Sep', 'Okt', 'Nov', 'Dec'
                              ];
                              if (value < 0 || value > 11) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Text(
                                  mjeseciNazivi[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false), 
                      borderData: FlBorderData(show: true),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withOpacity(0.2),
                          ),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Future<Uint8List?> _captureChartImage() async {
    try {
      if (_chartKey.currentContext == null) return null;

      final renderObject = _chartKey.currentContext!.findRenderObject();
      if (renderObject == null || renderObject is! RenderRepaintBoundary) return null;

      RenderRepaintBoundary boundary = renderObject;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      //print("Greška kod konvertovanja grafa u sliku: $e");
      debugPrint("Greška kod konvertovanja grafa u sliku: $e");
      return null;
    }
  }


  Future<void> _promptSaveReport() async {
    bool? potvrda = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda"),
        content: const Text("Jeste li sigurni da želite sačuvati izvještaj?"),
        actions: [
          TextButton(
                onPressed: () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        },
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ne",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Da",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (potvrda == true) {
      await _exportPdf(); 
    }
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final brojOtkazanih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "ponistena")
        .length;
    final brojUkupno = rezervacije.result.length;
    final stopaOtkaza = brojUkupno > 0 ? (brojOtkazanih / brojUkupno) * 100 : 0;
    final String filterTekst = (_selectedState == null || _selectedState!.isEmpty) 
    ? "Odabrano stanje filtera: Sve" 
    : "Odabrano stanje filtera: ${_selectedState![0].toUpperCase()}${_selectedState!.substring(1)}";
    final int zbirRecenzija = brojRecenzija + brojRecenzijaOdgovor;

    try{
      final chartImageBytes = await _captureChartImage();   
      if (!mounted) return;   
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Izvjestaj za salon:',
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 30),
              pw.Text("Broj korisnika: $brojKorisnika",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Stopa otkazanih rezervacija: ${stopaOtkaza.toStringAsFixed(1)}%",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Ukupan broj rezervacija: $brojUkupno",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Broj arhiviranih usluga: $brojArhiviranih",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Trenutno najtrazenija usluga: $najtrazenijaUslugaNaziv",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Broj napisanih recenzija: $zbirRecenzija",
                      style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text(filterTekst,
                      style: const pw.TextStyle(fontSize: 16)),

              if (chartImageBytes != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 20),
                    pw.Text('Graf rezervacija po mjesecima:',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.normal)),
                    pw.SizedBox(height: 10),
                    pw.Image(pw.MemoryImage(chartImageBytes)),
                  ],
                ),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      if (!mounted) return;
      final vrijeme = DateTime.now();

      String path =
            '${dir.path}/Izvjestaj-Dana-${formatDateTimeForFilename(vrijeme.toString())}.pdf';
        File file = File(path);
        file.writeAsBytes(await pdf.save());
        
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Izvještaj uspješno sačuvan"),
          content: Text("Lokacija izvještaja: ${file.path}"),
          actions: [
            TextButton(
                onPressed: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
    }
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri spremanju PDF-a: $e")),
        );
      }
    }
  }

}
