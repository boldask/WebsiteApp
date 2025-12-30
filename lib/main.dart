import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/polls_provider.dart';
import 'providers/circles_provider.dart';
import 'providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // THIS IS THE FIX: Explicitly pass your web credentials here
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        aapiKey: "AIzaSyBWrmfI_fa0wo4uHm2HqUO_geimmPGsP6s",
        authDomain: "boldask-150.firebaseapp.com",
        databaseURL: "https://boldask-150-default-rtdb.firebaseio.com",
        projectId: "boldask-150",
        storageBucket: "boldask-150.firebasestorage.app",
        messagingSenderId: "772421956417",
        appId: "1:772421956417:web:de5808c2f6193cd1b6a7c0",
        measurementId: "G-L3HQ7QZR26"
      ),
    );
  } else {
    // For Android/iOS, it reads from google-services.json or GoogleService-Info.plist
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PollsProvider()),
        ChangeNotifierProvider(create: (_) => CirclesProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const BoldaskApp(),
    ),
  );
}
