import 'package:esalon_mobile/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/screens/aktivne_promocije_screen.dart';
import 'package:esalon_mobile/screens/buduce_promocije_screen.dart';
import 'package:esalon_mobile/screens/promocija_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:esalon_mobile/models/promocija.dart';
import 'package:esalon_mobile/providers/promocija_provider.dart';
import 'package:esalon_mobile/providers/utils.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class PromocijaScreen extends StatefulWidget {
  const PromocijaScreen({super.key});

  @override
  State<PromocijaScreen> createState() => _PromocijaScreenState();
}

class _PromocijaScreenState extends State<PromocijaScreen> {
  late PromocijaProvider _promocijaProvider;
  late AktiviranaPromocijaProvider _aktiviranaPromocijaProvider;

  List<Promocija> _trenutnoAktivne = [];
  List<Promocija> _buducePromocije = [];

  bool _isLoadingAktivne = false;
  bool _isLoadingBuduce = false;

  @override
  void initState() {
    super.initState();
    _promocijaProvider = context.read<PromocijaProvider>();
    _aktiviranaPromocijaProvider = context.read<AktiviranaPromocijaProvider>();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _fetchAktivne();
    _fetchBuduce();
  }

  Future<void> _fetchAktivne() async {
    if (!mounted) return;
    setState(() => _isLoadingAktivne = true);

    try {
      final filterPromocije = <String, dynamic>{
        'SamoAktivne': true,
        'orderBy': 'DatumPocetka',
        'sortDirection': 'asc',
      };

      final resultPromocije = await _promocijaProvider.get(filter: filterPromocije);

      List<Promocija> aktivnePromocije = resultPromocije.result;

      if (AuthProvider.korisnikId != null) {
        final filterAktivirane = <String, dynamic>{
          'KorisnikId': AuthProvider.korisnikId,
          'Iskoristena': true,
        };
        final resultAktivirane = await _aktiviranaPromocijaProvider.get(filter: filterAktivirane);

        final aktiviraneIds = resultAktivirane.result.map((e) => e.promocijaId).toList();

        aktivnePromocije = aktivnePromocije
            .where((p) => !aktiviraneIds.contains(p.promocijaId))
            .toList();
      }

      setState(() {
        _trenutnoAktivne = aktivnePromocije.take(2).toList();
      });

    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAktivne = false;
        });
      }
    }
  }

  Future<void> _fetchBuduce() async {
    if (!mounted) return;
    setState(() => _isLoadingBuduce = true);
    try {
      final filter = <String, dynamic>{
        'SamoBuduce': true,
        'page': 1,
        'pageSize': 2,
        'orderBy': 'DatumPocetka',
        'sortDirection': 'asc',
      };
      if (!mounted) return;
      final result = await _promocijaProvider.get(filter: filter);
      if (!mounted) return;
      setState(() {
        _buducePromocije = result.result;
      });
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: e.toString(),
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBuduce = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSection(
                "Trenutno aktivne promocije", 
                _trenutnoAktivne, 
                true,
                _isLoadingAktivne,
              ),
              const SizedBox(height: 20),
              _buildSection(
                "Buduće promocije", 
                _buducePromocije, 
                false,
                _isLoadingBuduce,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 210, 193, 214),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible( 
              child: Text(
                "Posebne ponude",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis, 
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.local_offer,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List<Promocija> promocije, bool jeTrenutna, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: () {
                if (jeTrenutna) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AktivnePromocijeScreen(),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BuducePromocijeScreen(),
                    ),
                  );
                }
              },
              child: const Text(
                "Vidi sve >>",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (promocije.isEmpty)
           Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(97, 158, 158, 158),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    jeTrenutna
                        ? "Trenutno nema aktivnih promocija."
                        : "Trenutno nema budućih promocija.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          LayoutBuilder(builder: (context, constraints) {
            final boxWidth = (constraints.maxWidth - 10) / 2;
            final boxHeight = boxWidth * 1.3;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: promocije.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: boxWidth / boxHeight,
              ),
              itemBuilder: (context, index) {
                final promocija = promocije[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PromocijaDetailsScreen(promocija: promocija),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(promocija.slikaUsluge),
                        const SizedBox(height: 15),
                        Expanded(
                          child: Text(
                            promocija.naziv ?? "",
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_offer, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "-${promocija.popust != null ? promocija.popust!.round() : 0}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "na ${promocija.uslugaNaziv ?? ''}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${promocija.datumPocetka != null ? formatDate(promocija.datumPocetka!.toIso8601String()) : ""} - "
                              "${promocija.datumKraja != null ? formatDate(promocija.datumKraja!.toIso8601String()) : ""}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      ],
    );
  }

  Widget _buildImage(String? slikaBase64) {
    Widget imageWidget;

    if (slikaBase64 == null || slikaBase64.isEmpty) {
      imageWidget = Image.asset(
        "assets/images/praznaUsluga.png",
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      try {
        imageWidget = SizedBox(
          height: 120,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: imageFromString(slikaBase64),
          ),
        );
      } catch (_) {
        imageWidget = const Icon(Icons.broken_image, size: 100);
      }
    }

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageWidget,
      ),
    );
  }
}
