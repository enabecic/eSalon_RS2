import 'dart:convert';
import 'dart:io';
import 'package:esalon_desktop/models/usluga.dart';
import 'package:esalon_desktop/models/vrsta_usluge.dart';
import 'package:esalon_desktop/providers/utils.dart';
import 'package:esalon_desktop/providers/vrsta_usluge_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:provider/provider.dart';

class FrizerUslugeDetailsScreen extends StatefulWidget {
  final Usluga? usluga;

  const FrizerUslugeDetailsScreen({super.key, this.usluga});

  @override
  State<FrizerUslugeDetailsScreen> createState() =>
      _FrizerUslugeDetailsScreenState();
}

class _FrizerUslugeDetailsScreenState
    extends State<FrizerUslugeDetailsScreen> {
  late VrstaUslugeProvider vrstaUslugeProvider;
  SearchResult<VrstaUsluge>? vrstaUslugeResult;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  String? uslugaError;

  File? _image;
  String? _base64Image;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'naziv': widget.usluga?.naziv,
      'opis': widget.usluga?.opis,
      'cijena': widget.usluga?.cijena?.toStringAsFixed(2), 
      'trajanje': widget.usluga?.trajanje?.toString(),
      'vrstaId': widget.usluga?.vrstaId, 
    };
    _base64Image = widget.usluga?.slika;
    if (_base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(_base64Image!));
    }
        vrstaUslugeProvider = context.read<VrstaUslugeProvider>();
    _loadVrsteUsluga();
  }

  Future<void> _loadVrsteUsluga() async {
    vrstaUslugeResult = await vrstaUslugeProvider.get();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 240, 255),
      body: Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("eSalon",
                    style:
                        TextStyle(fontSize: 36, fontWeight: FontWeight.w500)),
                const SizedBox(width: 12),
                Image.asset('assets/images/logo.png',
                    height: 80, width: 80, fit: BoxFit.contain),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 35.0, top: 30.0, bottom: 20.0),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Detalji usluge",
                  style: TextStyle(fontSize: 22),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: vrstaUslugeResult == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: _buildForm(),
            ),

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
  return FormBuilder(
    key: _formKey,
    initialValue: _initialValue,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                const Padding(
                    padding:  EdgeInsets.only(bottom: 26), 
                    child:  Text(
                      "Slika usluge:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: 310,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: _imageProvider ??
                            const AssetImage("assets/images/praznaUsluga.png"),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 40),
              // Desna kolona 
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    //Naziv
                    _buildInfoRow("Naziv:", widget.usluga?.naziv ?? ""),
                    const SizedBox(height: 15),
                    // Cijena
                    _buildInfoRow("Cijena:", "${(widget.usluga?.cijena ?? 0).toStringAsFixed(2)} KM"),
                    const SizedBox(height: 15),
                    // Trajanje
                    _buildInfoRow("Trajanje:", "${(widget.usluga?.trajanje ?? 0).toInt()} min"),
                    const SizedBox(height: 15),
                    // Datum objavljivanja
                    _buildInfoRow(
                      "Datum objavljivanja:",
                      widget.usluga?.datumObjavljivanja != null
                          ? formatDateTime(widget.usluga!.datumObjavljivanja!)
                          : ""
                    ),
                    const SizedBox(height: 15),
                    // Vrsta usluge
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 0), 
                            child: Text(
                              "Vrsta usluge:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 210 - 60,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Text(
                                _getVrstaUslugeNaziv(widget.usluga?.vrstaId),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Opis
                    const Padding(
                      padding:  EdgeInsets.only(left: 0, bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding:  EdgeInsets.only(left: 0 ), 
                          child:  Text(
                            "Opis:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 160,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.usluga?.opis ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _saveRow(),
        ],
      ),
    ),
  );
}

  Widget _saveRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
              Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("OK"),
              ),
            ),
          ),                    
        ],
      ),
    );
  }

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      final bytes = await _image!.readAsBytes();
      _base64Image = base64Encode(bytes);
      _imageProvider = MemoryImage(bytes);
      setState(() {});
    }
  }

  void clearInput() {
    _formKey.currentState?.reset();
    uslugaError = null;
    _base64Image = null;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190, 
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              softWrap: true,   
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getVrstaUslugeNaziv(int? vrstaId) {
    final vrsta = vrstaUslugeResult?.result
        .firstWhere((v) => v.vrstaId == vrstaId, orElse: () => VrstaUsluge(naziv: 'Nepoznata'));
    return vrsta?.naziv ?? "Nepoznata";
  }

}
 
