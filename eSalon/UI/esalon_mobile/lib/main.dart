import 'package:esalon_mobile/layouts/master_screen.dart';
import 'package:esalon_mobile/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_mobile/providers/arhiva_provider.dart';
import 'package:esalon_mobile/providers/auth_provider.dart';
import 'package:esalon_mobile/providers/favorit_provider.dart';
import 'package:esalon_mobile/providers/korisnik_provider.dart';
import 'package:esalon_mobile/providers/nacin_placanja_provider.dart';
import 'package:esalon_mobile/providers/obavijest_provider.dart';
import 'package:esalon_mobile/providers/ocjena_provider.dart';
import 'package:esalon_mobile/providers/promocija_provider.dart';
import 'package:esalon_mobile/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_mobile/providers/recenzija_provider.dart';
import 'package:esalon_mobile/providers/rezervacija_provider.dart';
import 'package:esalon_mobile/providers/stavke_rezervacije_provider.dart';
import 'package:esalon_mobile/providers/uloga_provider.dart';
import 'package:esalon_mobile/providers/usluga_provider.dart';
import 'package:esalon_mobile/providers/vrsta_usluge_provider.dart';
import 'package:esalon_mobile/screens/registracija_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KorisnikProvider()),
        ChangeNotifierProvider(create: (_) => UlogaProvider()),
        ChangeNotifierProvider(create: (_) => VrstaUslugeProvider()),
        ChangeNotifierProvider(create: (_) => UslugaProvider()),
        ChangeNotifierProvider(create: (_) => FavoritProvider()),
        ChangeNotifierProvider(create: (_) => OcjenaProvider()),
        ChangeNotifierProvider(create: (_) => ArhivaProvider()),
        ChangeNotifierProvider(create: (_) => PromocijaProvider()),
        ChangeNotifierProvider(create: (_) => AktiviranaPromocijaProvider()),
        ChangeNotifierProvider(create: (_) => StavkeRezervacijeProvider()),
        ChangeNotifierProvider(create: (_) => RezervacijaProvider()),
        ChangeNotifierProvider(create: (_) => ObavijestProvider()),
        ChangeNotifierProvider(create: (_) => NacinPlacanjaProvider()),
        ChangeNotifierProvider(create: (_) => RecenzijaProvider()),
        ChangeNotifierProvider(create: (_) => RecenzijaOdgovorProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
        surface: const Color(0xfffffbff),),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    AuthProvider.isSignedIn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: 
              Image.asset('assets/images/pozadina.png',
              fit: BoxFit.fill,   
            ),
          ),
          Center(
            child: SingleChildScrollView(
                child: Container(
                //  constraints: const BoxConstraints(maxHeight: 550, maxWidth: 450),
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _autoValidate,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "eSalon",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Image.asset("assets/images/logo.png",
                                    height: 70, width: 70),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // Korisničko ime
                            TextFormField(
                              controller: _usernameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                labelText: "Korisničko ime",
                                labelStyle:  TextStyle(color: Colors.black), 
                                floatingLabelStyle:  TextStyle(color: Colors.black), 
                                prefixIcon: Icon(Icons.account_circle_outlined),
                                border: OutlineInputBorder(),   
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Unesite korisničko ime';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Lozinka
                            TextFormField(
                              controller: _passwordController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: const TextStyle(color: Colors.black),
                              obscureText: !_isPasswordVisible,
                              decoration:  InputDecoration(
                                labelText: "Lozinka",
                                labelStyle: const TextStyle(color: Colors.black), 
                                floatingLabelStyle: const TextStyle(color: Colors.black), 
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Unesite lozinku';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isLoggingIn ? null : () async {
                                    setState(() {
                                      _autoValidate = AutovalidateMode.onUserInteraction;
                                      _isLoggingIn = true;
                                    });
                                 if (_formKey.currentState?.validate() ?? false) {
               
                                  AuthProvider.username = _usernameController.text;
                                  AuthProvider.password = _passwordController.text;
         
                                    try {
                                      final korisnikProvider = KorisnikProvider();
                                      final korisnik = await korisnikProvider.login(
                                          AuthProvider.username!, AuthProvider.password!);

                                      if (korisnik.jeAktivan == false) {
                                        if (!context.mounted) return;
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: 'Račun deaktiviran',
                                          text: 'Vaš korisnički račun je deaktiviran.',
                                          confirmBtnText: 'OK',
                                          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                                          textColor: Colors.black,
                                          titleColor: Colors.black,
                                        );

                                        return;
                                      }

                                      AuthProvider.isSignedIn = true;

                                      if (AuthProvider.uloge != null &&
                                          AuthProvider.uloge!.contains("Klijent")) {  
                                            if (!context.mounted) return;     
                                              Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => const MasterScreen()));                   
                                      }                             
                                      else {
                                        if (!context.mounted) return;
                                         QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: "Pristup odbijen",
                                          text: "Niste autorizovani za pristup ovom interfejsu.",
                                          confirmBtnText: 'OK',
                                          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                                          textColor: Colors.black,
                                          titleColor: Colors.black,
                                        );
                                      }
                                    } on Exception catch (e) {
                                      if (!context.mounted) return;
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
                                    }
                                    finally {
                                      if (mounted) {
                                        setState(() {
                                          _isLoggingIn = false;
                                        });
                                      }
                                    }
                                  }
                                  else {
                                    setState(() {
                                      _isLoggingIn = false;
                                    });
                                  }
                                },
                                child: _isLoggingIn
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Prijava",
                                    style: TextStyle(fontSize: 16),
                                  ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                text: TextSpan(
                                  text: "Nemate korisnički račun? ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Kreirajte ga!",
                                      style:const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => const RegistracijaScreen(),
                                          ));
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Preskoči",
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          AuthProvider.korisnikId = null;
                                          AuthProvider.ime = null;
                                          AuthProvider.prezime = null;
                                          AuthProvider.email = null;
                                          AuthProvider.telefon = null;
                                          AuthProvider.datumRegistracije = null;
                                          AuthProvider.slika = null;
                                          AuthProvider.isSignedIn = false;
                                          AuthProvider.jeAktivan = false;
                                          AuthProvider.uloge = null;
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => const MasterScreen()),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

}

