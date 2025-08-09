import 'package:esalon_desktop/layouts/master_screen.dart';
import 'package:esalon_desktop/providers/aktivirana_promocija_provider.dart';
import 'package:esalon_desktop/providers/arhiva_provider.dart';
import 'package:esalon_desktop/providers/auth_provider.dart';
import 'package:esalon_desktop/providers/korisnik_provider.dart';
import 'package:esalon_desktop/providers/promocija_provider.dart';
import 'package:esalon_desktop/providers/recenzija_odgovor_provider.dart';
import 'package:esalon_desktop/providers/recenzija_provider.dart';
import 'package:esalon_desktop/providers/rezervacija_provider.dart';
import 'package:esalon_desktop/providers/uloga_provider.dart';
import 'package:esalon_desktop/providers/usluga_provider.dart';
import 'package:esalon_desktop/providers/vrsta_usluge_provider.dart';
import 'package:esalon_desktop/screens/admin_home_screen.dart';
import 'package:esalon_desktop/screens/frizer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => KorisnikProvider()),
        ChangeNotifierProvider(create: (_) => RezervacijaProvider()),
        ChangeNotifierProvider(create: (_) => VrstaUslugeProvider()),
        ChangeNotifierProvider(create: (_) => UslugaProvider()),
        ChangeNotifierProvider(create: (_) => PromocijaProvider()),
        ChangeNotifierProvider(create: (_) => AktiviranaPromocijaProvider()),
        ChangeNotifierProvider(create: (_) => RecenzijaProvider()),
        ChangeNotifierProvider(create: (_) => RecenzijaOdgovorProvider()),
        ChangeNotifierProvider(create: (_) => UlogaProvider()),
        ChangeNotifierProvider(create: (_) => ArhivaProvider()),

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

        //colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, primary: const Color(0xfffffbff)),
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

  @override
  void initState() {
    super.initState();
    AuthProvider.isSignedIn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  constraints: const BoxConstraints(maxHeight: 550, maxWidth: 450),
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
                                    fontSize: 28,
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
                                onPressed: () async {
                                    setState(() {
                                      _autoValidate = AutovalidateMode.onUserInteraction;
                                    });
                                 if (_formKey.currentState?.validate() ?? false) {
               
                                  AuthProvider.username = _usernameController.text;
                                  AuthProvider.password = _passwordController.text;
         
                                    try {
                                      final korisnikProvider = KorisnikProvider();
                                      final korisnik = await korisnikProvider.login(
                                          AuthProvider.username!, AuthProvider.password!);

                                      if (korisnik.jeAktivan == false) {
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
                                          AuthProvider.uloge!.contains("Admin")) {                          
                                        Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (context) =>const MasterScreen(
                                                  "Admin panel",
                                                   AdminHomeScreen(),
                                                ),
                                              ),
                                            );

                                      } else if (AuthProvider.uloge != null &&
                                          AuthProvider.uloge!.contains("Frizer")) {                     
                                          Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) => const MasterScreen(
                                              "Frizer panel",
                                               FrizerHomeScreen(),
                                            ),
                                          ),
                                        );

                                      } else {
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.error,
                                          title: "Pristup odbijen",
                                          text: "Niste autorizovani za pristup ovog interfejsa.",
                                          confirmBtnText: 'OK',
                                          confirmBtnColor: const Color.fromRGBO(220, 201, 221, 1),
                                          textColor: Colors.black,
                                          titleColor: Colors.black,
                                        );
                                      }
                                    } on Exception catch (e) {
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
                                  }


                                },
                                child: const Text("Prijava"),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
         // ),
        ],
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
