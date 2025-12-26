import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/models/search_result.dart';
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
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


class FrizerHomeScreen extends StatefulWidget {
  const FrizerHomeScreen({super.key});

  @override
  State<FrizerHomeScreen> createState() => _FrizerHomeScreenState();
}

class _FrizerHomeScreenState extends State<FrizerHomeScreen> {
  late KorisnikProvider korisnikProvider;
  late RezervacijaProvider rezervacijaProvider;

  SearchResult rezervacije = SearchResult(); 

  bool isLoading = true;

  int brojKorisnika = 0;
  String? _selectedState; 
  final List<String> _states = ['odobrena', 'ponistena', 'zavrsena','kreirana'];


  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      korisnikProvider = context.read<KorisnikProvider>();
      rezervacijaProvider = context.read<RezervacijaProvider>();

      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    if (AuthProvider.korisnikId == null) return; 

    try {
      if (!mounted) return;
      final korisniciResult = await korisnikProvider.get();
      if (!mounted) return;
      final rezervacijaResult = await rezervacijaProvider.get();
      rezervacije = rezervacijaResult;

      if (!mounted) return;
      setState(() {
        brojKorisnika = korisniciResult.count;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
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
    final brojZavrsenih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "zavrsena")
        .length;
    final brojUkupno = rezervacije.result.length;

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
                    Expanded(child: _buildCard("Ukupan broj rezervacija", brojUkupno.toString())),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Broj završenih rezervacija", brojZavrsenih.toString())),
                    const SizedBox(width: 20),
                    Expanded(child: _buildCard("Broj otkazanih rezervacija", brojOtkazanih.toString())),      
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
                            minimumSize: const Size(100, 52), 
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
                        if (!mounted) return;
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
      if (!mounted) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      if (!mounted) return null;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Greška kod konvertovanja grafa u sliku: $e");
      return null;
    }
  }

  Future<void> _promptSaveReport() async {
    if (!mounted) return;
    bool? potvrda = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda"),
        content: const Text("Jeste li sigurni da želite sačuvati izvještaj?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
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
      if (!mounted) return;
      await _exportPdf(); 
    }
  }


  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final brojZavrsenih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "zavrsena")
        .length;
    final brojOtkazanih = rezervacije.result
        .where((r) => r.stateMachine?.toLowerCase() == "ponistena")
        .length;
    final brojUkupno = rezervacije.result.length;
    final String filterTekst = (_selectedState == null || _selectedState!.isEmpty) 
    ? "Odabrano stanje filtera: Sve" 
    : "Odabrano stanje filtera: ${_selectedState![0].toUpperCase()}${_selectedState!.substring(1)}";

    try {
      if (!mounted) return;
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
              pw.SizedBox(height: 25),
              pw.Text("Ukupan broj rezervacija: $brojUkupno",
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Ukupan broj zavrsenih rezervacija: $brojZavrsenih",
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),
              pw.Text("Ukupan broj otkazanih rezervacija: $brojOtkazanih",
                  style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 20),
              pw.Text(filterTekst,//
                      style: const pw.TextStyle(fontSize: 16)),
              if (chartImageBytes != null) ...[
                pw.SizedBox(height: 20),
                pw.Text('Graf rezervacija po mjesecima:',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Image(pw.MemoryImage(chartImageBytes)),
              ]
            ],
          ),
        ),
      );
      if (!mounted) return;
      final dir = await getApplicationDocumentsDirectory();
      if (!mounted) return;

      final vrijeme = DateTime.now();
      final path =
          '${dir.path}/Izvjestaj-Rezervacija-Dana-${formatDateTimeForFilename(vrijeme.toString())}.pdf';
      final file = File(path);
      if (!mounted) return;
      await file.writeAsBytes(await pdf.save());

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri spremanju PDF-a: $e")),
        );
      }
    }
  }

}