import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/main.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class KorisnikProfilEditScreen extends StatefulWidget {
  const KorisnikProfilEditScreen({super.key});

  @override
  State<KorisnikProfilEditScreen> createState() =>
      _KorisnikProfilEditScreenState();
}

class _KorisnikProfilEditScreenState extends State<KorisnikProfilEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _provider;
  bool _promijeniLozinku = false;
  bool _isOldPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Map<String, dynamic> _initialValue = {};
  bool _isLoading = true;
  late Widget _profileImageWidget;
  @override
  void initState() {
    super.initState();
    _provider = context.read<KorisnikProvider>();
    _profileImageWidget = _buildProfileImage(); 
    _loadKorisnik();
  }

  File? _image;
  String? _base64Image;

  Future<void> _loadKorisnik() async {
    try {
      final korisnik = await _provider.getById(AuthProvider.korisnikId!);
      _initialValue = {
        'ime': korisnik.ime ?? '',
        'prezime': korisnik.prezime ?? '',
        'telefon': korisnik.telefon ?? '',
        'jeAktivan': korisnik.jeAktivan ?? true,
        'promijeniLozinku': false,
        'slika': AuthProvider.slika,
      };
    _base64Image = AuthProvider.slika; 
    _profileImageWidget = _buildProfileImage(); 

    } catch (e) {
      if (!mounted) return;
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Greška',
          text: 'Neuspješno učitavanje podataka o korisniku.',
        );
        if (!mounted) return;
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "eSalon",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
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
                  "Uredi profil",
                  style: TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _profileImageWidget, 
                        const SizedBox(height: 30),
                        _buildForm(),
                        const SizedBox(height: 30),
                        _buildActionButtons(),
                          const SizedBox(height: 30),
                  ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'ime',
                    decoration: _decoration('Ime', 'Unesite ime'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: "Ime je obavezno."),
                      FormBuilderValidators.minLength(1,
                          errorText: "Ime ne može biti prazno."),
                      FormBuilderValidators.maxLength(50,
                          errorText: "Ime može imati najviše 50 karaktera."),
                      FormBuilderValidators.match(
                        r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                        errorText:
                            "Ime mora početi velikim slovom i sadržavati samo slova.",
                      ),
                    ]),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: FormBuilderTextField(
                    name: 'prezime',
                    decoration: _decoration('Prezime', 'Unesite prezime'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: "Prezime je obavezno."),
                      FormBuilderValidators.minLength(1,
                          errorText: "Prezime ne može biti prazno."),
                      FormBuilderValidators.maxLength(50,
                          errorText:
                              "Prezime može imati najviše 50 karaktera."),
                      FormBuilderValidators.match(
                        r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                        errorText:
                            "Prezime mora početi velikim slovom i sadržavati samo slova.",
                      ),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: 'telefon',
                    decoration: _decoration(
                        'Telefon', 'Unesite telefon (npr. +387...)'),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: "Telefon je obavezan."),
                      FormBuilderValidators.match(
                        r'^\+\d{7,15}$',
                        errorText:
                            'Telefon mora početi sa + i imati 7-15 cifara.',
                      ),
                      FormBuilderValidators.maxLength(20,
                          errorText: 'Maksimalno 20 karaktera.'),
                    ]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            FormBuilderField(
              name: "slika",
              builder: (field) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Odaberite sliku',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 108, 108, 108),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: ListTile(
                    leading:const Icon(Icons.image),
                    title:const Text("Select image"),
                    trailing: const Icon(Icons.file_upload),
                    onTap: getImage,
                  ),
                );
              },
            ),

            const SizedBox(height: 15),
            FormBuilderCheckbox(
              name: 'promijeniLozinku',
              title: const Text('Promijeni lozinku',
                  style: TextStyle(fontSize: 16)),
              onChanged: (val) {
                if (!mounted) return;
                setState(() {
                  _promijeniLozinku = val ?? false;
                });
              },
            ),
            if (_promijeniLozinku) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'staraLozinka',
                      obscureText: _isOldPasswordHidden,
                      decoration: _decoration('Stara lozinka', '').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isOldPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _isOldPasswordHidden = !_isOldPasswordHidden;
                            });
                          },
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                          errorText: 'Stara lozinka je obavezna.'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'lozinka',
                      obscureText: _isNewPasswordHidden,
                      decoration: _decoration('Nova lozinka', '').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isNewPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _isNewPasswordHidden = !_isNewPasswordHidden;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        final oldPassword = _formKey.currentState?.fields['staraLozinka']?.value ?? '';
                        if (val == null || val.isEmpty) {
                          return 'Nova lozinka je obavezna.';
                        }
                        if (val.length < 6) {
                          return 'Najmanje 6 karaktera.';
                        }
                          if (val.length > 40) {
                          return 'Najviše 40 karaktera.';
                        }
                        if (val == oldPassword) {
                          return 'Nova lozinka ne može biti ista kao stara.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'lozinkaPotvrda',
                      obscureText: _isConfirmPasswordHidden,
                      decoration: _decoration('Potvrda lozinke', '').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _isConfirmPasswordHidden =
                                  !_isConfirmPasswordHidden;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        final lozinka =
                            _formKey.currentState?.fields['lozinka']?.value;
                        if (val == null || val.isEmpty) {
                          return 'Potvrda je obavezna.';
                        }
                        if (val != lozinka) {
                          return 'Lozinke se ne podudaraju.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          image: _base64Image != null
              ? DecorationImage(
                  image: MemoryImage(base64Decode(_base64Image!)),
                  fit: BoxFit.cover,
                )
              : AuthProvider.slika != null
                  ? DecorationImage(
                      image: MemoryImage(base64Decode(AuthProvider.slika!)),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage("assets/images/prazanProfil.png"),
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
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text("Deaktivacija profila"),
                      content: const Text("Da li ste sigurni da želite deaktivirati svoj profil?"),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Otkaži",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Deaktiviraj",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop(); 

                            try {
                              await _provider.deaktiviraj(AuthProvider.korisnikId!);

                              AuthProvider.username = null;
                              AuthProvider.password = null;
                              AuthProvider.korisnikId = null;
                              AuthProvider.ime = null;
                              AuthProvider.prezime = null;
                              AuthProvider.email = null;
                              AuthProvider.telefon = null;
                              AuthProvider.uloge = null;
                              AuthProvider.slika = null;
                              AuthProvider.isSignedIn = false;

                              if (!context.mounted) return;
                              if (!mounted) return;
                              await showDialog(           
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Uspjeh"),
                                  content: const Text("Profil je uspješno deaktiviran."),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); 
                                      },
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (!mounted) return;
                               Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginPage()),
                                (route) => false,
                              );
                          
                            } catch (e) {
                              if (!mounted) return;
                              if (context.mounted) {
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Greška',
                                  text: e.toString(),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Deaktiviraj profil",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 20),
          SizedBox(
            width: 120,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 180, 140, 218),
                foregroundColor: const Color.fromARGB(199, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Uređivanje profila",
                  ),
                  content: const Text("Da li ste sigurni da želite sačuvati izmjene?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Ne",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); 
                        _save(); 
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Da",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
              },
              child: const Text(
                "Sačuvaj",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final isValid = _formKey.currentState?.saveAndValidate();
    if (isValid != true) return;

    final formValues = Map<String, dynamic>.from(_formKey.currentState!.value);
    final request = {
      'ime': formValues['ime'],
      'prezime': formValues['prezime'],
      'email': AuthProvider.email,
      'telefon': formValues['telefon'],
    };

    request['slika'] = _base64Image ?? AuthProvider.slika;

    if (_promijeniLozinku) {
      request['staraLozinka'] = formValues['staraLozinka'];
      request['lozinka'] = formValues['lozinka'];
      request['lozinkaPotvrda'] = formValues['lozinkaPotvrda'];
    }

    try {
      await _provider.update(AuthProvider.korisnikId!, request);

      if (_promijeniLozinku &&
          formValues['lozinka'] != null &&
          formValues['lozinka'] != '') {
        AuthProvider.password = formValues['lozinka'];
      }
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Uspjeh"),
          content: const Text("Profil uspješno ažuriran."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      AuthProvider.slika = request['slika'];
      if (!mounted) return;
      Navigator.pop(context, true);
    } 
    catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Greška',
          text: e.toString(),
          confirmBtnText: 'OK',
          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        );
      }
    }
  }

  void getImage() async {
    var result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      if (!mounted) return;
      setState(() {
        _profileImageWidget = _buildProfileImage(); 
      });
    }
  }

}

