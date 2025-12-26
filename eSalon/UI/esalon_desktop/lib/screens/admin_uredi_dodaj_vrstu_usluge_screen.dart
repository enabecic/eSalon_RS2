import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:esalon_desktop/models/vrsta_usluge.dart';
import 'package:esalon_desktop/providers/vrsta_usluge_provider.dart';
import 'package:esalon_desktop/models/search_result.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class AdminUrediDodajVrstuUslugeScreen extends StatefulWidget {
  final VrstaUsluge? vrstaUsluge;

  const AdminUrediDodajVrstuUslugeScreen({super.key, this.vrstaUsluge});

  @override
  State<AdminUrediDodajVrstuUslugeScreen> createState() =>
      _AdminUrediDodajVrstuUslugeScreenState();
}

class _AdminUrediDodajVrstuUslugeScreenState
    extends State<AdminUrediDodajVrstuUslugeScreen> {
  late VrstaUslugeProvider _provider;
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  SearchResult<VrstaUsluge>? _vrsteUslugaResult;
  String? nazivError;

  bool _isTextFieldHovered = false;
  bool _isImageFieldHovered = false;
  bool _isSaveHovered = false;

  File? _image;
  String? _base64Image;
  ImageProvider? _imageProvider;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initialValue = {
      'naziv': widget.vrstaUsluge?.naziv,
    };
    _base64Image = widget.vrstaUsluge?.slika;
    if (_base64Image != null) {
      _imageProvider = MemoryImage(base64Decode(_base64Image!));
    }
    _provider = context.read<VrstaUslugeProvider>();
    _loadVrsteUsluga();
  }

  Future<void> _loadVrsteUsluga() async {
    if (!mounted) return;
    _vrsteUslugaResult = await _provider.get();
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
                Text(
                  widget.vrstaUsluge == null
                      ? "Dodaj vrstu usluge"
                      : "Uredi vrstu usluge / Detalji vrste usluge",
                  style: const TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildForm(),
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
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 250,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: _imageProvider ??
                      const AssetImage("assets/images/praznaVrstaUsluge.png"),
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
            const SizedBox(height: 40),
            MouseRegion(
              onEnter: (_) => setState(() => _isImageFieldHovered = true),
              onExit: (_) => setState(() => _isImageFieldHovered = false),
              child: Container(
                decoration: BoxDecoration(
                  color: _isImageFieldHovered
                      ? const Color(0xFFE0D7F5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: FormBuilderField(
                  name: "slika",
                  builder: (field) {
                    return InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Odaberite sliku',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text("Izaberite sliku"),
                        trailing: const Icon(Icons.file_upload),
                        onTap: getImage,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 100,  
              child: MouseRegion(
                onEnter: (_) => setState(() => _isTextFieldHovered = true),
                onExit: (_) => setState(() => _isTextFieldHovered = false),
                child: FormBuilderTextField(
                  name: 'naziv',
                  maxLength: 50,
                  decoration: InputDecoration(
                    labelText: 'Naziv vrste usluge',
                    hintText: 'Unesite naziv vrste usluge',
                    contentPadding: const EdgeInsets.symmetric(vertical: 29, horizontal: 12),
                    errorText: nazivError,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.7),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade600, width: 2.0),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 1.7),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    filled: true,
                    fillColor:
                        _isTextFieldHovered ? const Color(0xFFE0D7F5) : Colors.white,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.match(
                      r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                      errorText:
                          "Naziv mora početi velikim slovom i sadržavati samo slova.",
                    ),
                    FormBuilderValidators.required(
                      errorText: "Obavezno polje.",
                    ),
                    FormBuilderValidators.minLength(
                      1,
                      errorText: "Minimalna dužina je 1 znaka.",
                    ),
                    FormBuilderValidators.maxLength(
                      50,
                      errorText: "Maksimalna dozvoljena dužina je 50 znakova.",
                    ),
                  ]),
                  onChanged: (value) async {
                    _formKey.currentState?.validate();
                    if (value != null && _vrsteUslugaResult?.result != null) {
                      final postoji = _vrsteUslugaResult!.result.any(
                        (e) =>
                            (e.naziv?.toLowerCase() ?? '') == value.toLowerCase() &&
                            (widget.vrstaUsluge == null ||
                                e.vrstaId != widget.vrstaUsluge!.vrstaId),
                      );

                      if (postoji) {
                        nazivError = "Vrsta usluge sa tim imenom već postoji.";
                      } else {
                        nazivError = null;
                      }
                      if (!mounted) return;
                      setState(() {});
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 5),
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
          MouseRegion(
            onEnter: (_) => setState(() => _isSaveHovered = true),
            onExit: (_) => setState(() => _isSaveHovered = false),
            child: Container(
              width: 190,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _isSaveHovered
                    ? const Color.fromARGB(255, 160, 120, 200)
                    : const Color.fromARGB(255, 180, 140, 218),
              ),
              child: InkWell(
              onTap: _isSaving
                ? null
                : () async {
                var isValid = _formKey.currentState!.saveAndValidate();
                if (isValid) {
                  if (!mounted) return;
                  final potvrda = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text("Potvrda"),
                      content: Text(widget.vrstaUsluge == null
                          ? "Jeste li sigurni da želite dodati?"
                          : "Jeste li sigurni da želite urediti?"),
                      actions: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, false), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Ne",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true), 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Da",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (potvrda == true) {
                    if (!mounted) return;
                    setState(() => _isSaving = true);

                    final req = Map.from(_formKey.currentState!.value);
                    req['slika'] = _base64Image;

                     try {
                      if (widget.vrstaUsluge == null) {
                        if (!mounted) return;
                        await _provider.insert(req);
                      } else {
                        if (!mounted) return;
                        await _provider.update(widget.vrstaUsluge!.vrstaId!, req);
                      }
                      if (!mounted) return;
                      Navigator.pop(context, true);
                      clearInput();
                    } catch (e) {
                      if (!mounted) return;
                        await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Greška!',
                          text: e.toString(),
                          confirmBtnText: 'OK',
                          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                          textColor: Colors.black,
                          titleColor: Colors.black,
                        );
                      }
                      finally {
                      if (mounted) {
                        setState(() => _isSaving = false);
                      }
                    }
                  }
                }
              },
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Sačuvaj",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(199, 0, 0, 0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getImage() async {
    if (!mounted) return;
    var result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      if (!mounted) return;
      final bytes = await _image!.readAsBytes();
      _base64Image = base64Encode(bytes);
      _imageProvider = MemoryImage(bytes);
      if (!mounted) return;
      setState(() {});
    }
  }

  void clearInput() {
    _formKey.currentState?.reset();
    nazivError = null;
    _base64Image = null;
  }
}

