import 'dart:convert';
import 'dart:developer' as dev;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

extension on Object {
  void log() {
    dev.log(toString());
  }
}

extension on User {
  Map<String, dynamic> get json {
    return {
      'uid': uid,
      'emailVerified': emailVerified,
      'displayName': displayName,
      'email': email,
      'refreshToken': refreshToken,
      'tenantId': tenantId,
      'isAnonymous': isAnonymous,
      'metadata': {
        'creationTime': metadata.creationTime?.toIso8601String(),
        'lastSignInTime': metadata.lastSignInTime?.toIso8601String(),
      },
      'providerData': providerData
          .map((info) => {
                'displayName': info.displayName,
                'email': info.email,
                'phoneNumber': info.phoneNumber,
                'photoURL': info.photoURL,
                'providerId': info.providerId,
                'uid': info.uid,
              })
          .toList(),
    };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 213, 228, 214),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        'User is currently signed out!'.log();
      } else {
        user.log();
      }
      setState(() {});
    });
  }

  void signInWithEmailPassword() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'test@testing.com',
        password: 'testing',
      );
      credential.log();
    } catch (e) {
      e.log();
    }
  }

  Future<void> _signOut() {
    return FirebaseAuth.instance.signOut();
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Firebase Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              const JsonEncoder.withIndent('    ').convert(
                FirebaseAuth.instance.currentUser?.json ?? "No User logged in",
              ),
            ),
            TextButton(
              onPressed: signInWithEmailPassword,
              child: const Text('signInWithEmailPassword'),
            ),
            TextButton(
              onPressed: signInWithGoogle,
              child: const Text('signInWithGoogle'),
            ),
            TextButton(
              onPressed: _signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
