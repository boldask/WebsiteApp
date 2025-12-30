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

  await Firebase.initializeApp(
    // TODO: Add your Firebase options here
    // options: DefaultFirebaseOptions.currentPlatform,
  );

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
