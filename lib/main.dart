import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:pxmusic/Screens/Library/nowplaying.dart';
import 'package:pxmusic/Screens/Library/playlists.dart';
import 'package:pxmusic/Screens/Library/recent.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pxmusic/Screens/About/about.dart';
import 'package:pxmusic/Screens/Home/home.dart';
import 'package:pxmusic/Screens/Settings/setting.dart';
import 'package:pxmusic/Screens/Search/search.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pxmusic/Screens/Login/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'Screens/Library/downloaded.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await Hive.openBox('settings');
  } catch (e) {
    print('Failed to open Settings Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "settings";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("settings");
  }
  try {
    await Hive.openBox('cache');
  } catch (e) {
    print('Failed to open Cache Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "cache";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("cache");
  }
  try {
    await Hive.openBox('recentlyPlayed');
  } catch (e) {
    print('Failed to open Recent Box');
    print("Error: $e");
    var dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    String boxName = "recentlyPlayed";
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox("recentlyPlayed");
  }
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Failed to initialize Firebase');
  }

  Paint.enableDithering = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  void initState() {
    super.initState();

    analytics.logAppOpen();
  }

  initialFuntion() {
    return Hive.box('settings').get('name') != null
        ? AudioServiceWidget(child: HomePage())
        : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BlackHole',
      //system,
      theme: ThemeData(
        primaryColor: Colors.black,
        canvasColor: Colors.white,
        textTheme: TextTheme(
          headline1: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: Color(0xFF1F1F1F)),
          headline2: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Color(0xFF1F1F1F)),
          headline5: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.5,
              color: Color(0xFF1F1F1F)),
          bodyText1: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: Color(0xFF1F1F1F)),
          bodyText2: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            color: Color(0xFFB2B2B2),
          ),
          caption: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF838383),
          ),
          subtitle1: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1F1F1F),
          ),
          subtitle2: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Color(0xFF1F1F1F),
          ),
          headline3: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            color: Color(0xFFB2B2B2), // Timer (Song Duration)
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(
            fontFamily: "DMSans",
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      // dark theme
      darkTheme: ThemeData(
        primaryColor: Colors.white,
        canvasColor: Color(0xFF1F1F1F),
        scaffoldBackgroundColor: Color(0xFF0F0F0F),
        primarySwatch: Colors.grey,
        textTheme: TextTheme(
          headline1: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: Colors.white), // Main Heading (Discover)
          headline2: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.white), // Sub Heading (Moods)
          headline5: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -0.5,
              color: Colors.white), // Sub Heading (Playlist Tittle)
          bodyText1: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w300,
              fontSize: 14,
              color: Colors.white), // Song Name (Home Page)
          bodyText2: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 12,
            color: Colors.white, // Artist Name (Home Page)
          ),
          caption: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Colors.white, //Search Box
          ),
          subtitle1: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.white, // Search Results Tittle (Song Name)
          ),
          subtitle2: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Colors.white, // Library Tile Text
          ),
          headline3: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            color: Colors.white, // Timer (Song Duration)
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(
            fontFamily: "DMSans",
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      // home: HomePage(),
      routes: {
        '/': (context) => initialFuntion(),
        '/setting': (context) => SettingPage(),
        '/search': (context) => SearchPage(),
        // '/liked': (context) => LikedSongs(),
        '/downloaded': (context) => DownloadedSongs(),
        // '/play': (context) => PlayScreen(),
        '/about': (context) => AboutScreen(),
        '/playlists': (context) => PlaylistScreen(),
        // '/mymusic': (context) => MyMusicScreen(),
        '/nowplaying': (context) => NowPlaying(),
        '/recent': (context) => RecentlyPlayed(),
      },
    );
  }
}
