import 'package:esalon_mobile/main.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/base_provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class KorisnikProfileScreen extends StatefulWidget {
  const KorisnikProfileScreen({super.key});

  @override
  State<KorisnikProfileScreen> createState() => _KorisnikProfileScreenState();
}

class _KorisnikProfileScreenState extends State<KorisnikProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late KorisnikProvider _provider;
  bool _promijeniLozinku = false;
  bool _isOldPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Map<String, dynamic> _initialValue = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _provider = context.read<KorisnikProvider>();
    _loadKorisnik();
  }

  Future<void> _loadKorisnik() async {
    try {
      if (AuthProvider.korisnikId == null) return;
      if (!mounted) return;

      final korisnik = await _provider.getById(AuthProvider.korisnikId!);

      if (!mounted) return;
      setState(() {
        _initialValue = {
          'ime': korisnik.ime ?? '',
          'prezime': korisnik.prezime ?? '',
          'telefon': korisnik.telefon ?? '',
          'jeAktivan': korisnik.jeAktivan ?? true,
          'promijeniLozinku': false,
        };
      });
    } catch (e) {
      if (!mounted) return;
      await QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Greška',
        text: 'Neuspješno učitavanje podataka o korisniku.',
        confirmBtnText: 'OK',
        confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
        textColor: Colors.black,
        titleColor: Colors.black,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
            Text(
              "Moj korisnički profil",
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.person,
              color: Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 244, 247),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AuthProvider.isSignedIn
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildHeader(), 
                                        const SizedBox(height: 30),
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 7,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            enabled: false,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Korisničko ime',
                                              labelStyle:
                                                  const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                                              hintText: AuthProvider.username ?? '',
                                              hintStyle:
                                                  const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              prefixIcon: const Icon(Icons.account_circle_outlined),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                            ),
                                          ),
                                        ),
                                        // Email
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 7,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            enabled: false,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              labelStyle:
                                                  const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                                              hintText: AuthProvider.email ?? '',
                                              hintStyle:
                                                  const TextStyle(color: Color.fromARGB(176, 0, 0, 0)),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              prefixIcon: const Icon(Icons.email_outlined),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildForm(), 
                                ],
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.save_alt, color: Colors.black),
                                      label: const Text(
                                        "Sačuvaj",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (!mounted) return;
                                        final potvrda = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Potvrda"),
                                            content: const Text("Da li ste sigurni da želite sačuvati promjene?"),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text(
                                                  "Ne",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(true),
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
                                          await _save();
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.logout, color: Colors.black),
                                      label: const Text(
                                        "Odjavi se",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 210, 193, 214),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (!mounted) return;
                                        final potvrda = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Potvrda odjave"),
                                            content: const Text("Da li ste sigurni da se želite odjaviti?"),
                                            actions: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text(
                                                  "Ne",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.deepPurple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text(
                                                  "Da",
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (potvrda == true) {
                                          AuthProvider.datumRegistracije = null;
                                          AuthProvider.email = null;
                                          AuthProvider.ime = null;
                                          AuthProvider.korisnikId = null;
                                          AuthProvider.prezime = null;
                                          AuthProvider.slika = null;
                                          AuthProvider.telefon = null;
                                          AuthProvider.username = null;
                                          AuthProvider.password = null;
                                          if (!context.mounted) return;
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(builder: (context) => const MyApp()),
                                          );
                                          if (!mounted) return;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.block, color: Colors.black),
                                      label: const Text(
                                        "Deaktiviraj",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 173, 178, 178),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: _onDeaktivirajPressed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
              : // Ako korisnik nije logiran
              Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Za pristup ovom dijelu aplikacije morate biti prijavljeni! ",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Molimo prijavite se!",
                        style: const TextStyle(
                          color: Colors.deepPurple, 
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, 
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ), 
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      child: FormBuilder(
        key: _formKey,
        initialValue: _initialValue,
        child: Column(
          children: [
            // Ime
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FormBuilderTextField(
                name: 'ime',
                decoration: _decoration('Ime', 'Unesite ime').copyWith(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "Ime je obavezno."),
                  FormBuilderValidators.minLength(1, errorText: "Ime ne može biti prazno."),
                  FormBuilderValidators.maxLength(50, errorText: "Ime može imati najviše 50 karaktera."),
                  FormBuilderValidators.match(
                    r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                    errorText: "Ime mora početi velikim slovom i sadržavati samo slova.",
                  ),
                ]),
              ),
            ),
            // Prezime
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FormBuilderTextField(
                name: 'prezime',
                decoration: _decoration('Prezime', 'Unesite prezime').copyWith(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: "Prezime je obavezno."),
                  FormBuilderValidators.minLength(1, errorText: "Prezime ne može biti prazno."),
                  FormBuilderValidators.maxLength(50, errorText: "Prezime može imati najviše 50 karaktera."),
                  FormBuilderValidators.match(
                    r'^[A-ZČĆŽĐŠ][a-zA-ZčćžđšČĆŽĐŠ\s]*$',
                    errorText: "Prezime mora početi velikim slovom i sadržavati samo slova.",
                  ),
                ]),
              ),
            ),
            // Telefon
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: FormBuilderTextField(
                      name: 'telefon',
                      decoration: _decoration('Telefon', 'Unesite telefon (npr. +387...)').copyWith(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: "Telefon je obavezan."),
                        FormBuilderValidators.match(
                          r'^\+\d{7,15}$',
                          errorText: 'Telefon mora početi sa + i imati 7-15 cifara.',
                        ),
                        FormBuilderValidators.maxLength(20, errorText: 'Maksimalno 20 karaktera.'),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
            // Checkbox promijeni lozinku
            FormBuilderCheckbox(
              name: 'promijeniLozinku',
              title: const Text('Promijeni lozinku', style: TextStyle(fontSize: 16)),
              onChanged: (val) {
                if (!mounted) return;
                setState(() {
                  _promijeniLozinku = val ?? false;
                });
              },
            ),

            if (_promijeniLozinku) ...[
              const SizedBox(height: 8),
              // Stara lozinka
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FormBuilderTextField(
                  name: 'staraLozinka',
                  obscureText: _isOldPasswordHidden,
                  decoration: _decoration('Stara lozinka', '').copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_isOldPasswordHidden ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _isOldPasswordHidden = !_isOldPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Stara lozinka je obavezna.';
                    }

                    if (val != AuthProvider.password) {
                      return 'Unesite ispravnu lozinku.';
                    }

                    return null;
                  },
                ),
              ),
              // Nova lozinka
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FormBuilderTextField(
                  name: 'lozinka',
                  obscureText: _isNewPasswordHidden,
                  decoration: _decoration('Nova lozinka', '').copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_isNewPasswordHidden ? Icons.visibility_off : Icons.visibility),
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
              // Potvrda lozinke
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FormBuilderTextField(
                  name: 'lozinkaPotvrda',
                  obscureText: _isConfirmPasswordHidden,
                  decoration: _decoration('Potvrda lozinke', '').copyWith(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmPasswordHidden ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (val) {
                    final lozinka = _formKey.currentState?.fields['lozinka']?.value;
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
          ],
        ),
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
      'slika': AuthProvider.slika,
    };

    if (_promijeniLozinku) {
      request['staraLozinka'] = formValues['staraLozinka'];
      request['lozinka'] = formValues['lozinka'];
      request['lozinkaPotvrda'] = formValues['lozinkaPotvrda'];
    }

    try {
      if (AuthProvider.korisnikId == null) throw UserException("KorisnikId je null.");
      if (!mounted) return;
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
      AuthProvider.ime = request['ime'];
      AuthProvider.prezime = request['prezime'];
      AuthProvider.telefon = request['telefon'];
      if (!mounted) return;
      setState(() {});
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
    }
  }

  void _onDeaktivirajPressed() {
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
                  if (AuthProvider.korisnikId == null) throw UserException("KorisnikId je null.");
                  if (!mounted) return;
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  await QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Greška',
                    text: e.toString(),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
