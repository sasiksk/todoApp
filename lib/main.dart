import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todolist/screen/SplashScreen.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 194, 247, 187),
  ),
  brightness: Brightness.light,
  textTheme: GoogleFonts.robotoSlabTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.teal.shade800, // AppBar background color
    foregroundColor: Colors.white, // AppBar text color
    titleTextStyle: GoogleFonts.robotoSlab(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white, // AppBar icons color
    ),
    actionsIconTheme: const IconThemeData(
      color: Colors.white, // AppBar actions icons color
    ),

    elevation: 4.0,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: GoogleFonts.robotoSlab(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.teal, // Matching title color with AppBar
    ),
    contentTextStyle: GoogleFonts.aBeeZee(
      fontSize: 16.0,
      color: Colors.black87, // Content text color
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
      // Rounded corners
    ),
  ),
  scaffoldBackgroundColor: Colors.teal.shade50,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Ensure that Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Initialize flutterLocalNotificationsPlugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  tz.initializeTimeZones();

  runApp(
    MaterialApp(
      home: const SplashScreen(),
      theme: theme,
    ),
  );
}
