import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:pxmusic/CustomWidgets/GradientContainers.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';

class SettingPage extends StatefulWidget {
  final Function callback;
  SettingPage({this.callback});
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music/');
  List dirPaths = Hive.box('settings').get('searchPaths', defaultValue: []);
  String streamingQuality =
  Hive.box('settings').get('streamingQuality', defaultValue: '96 kbps');
  String downloadQuality =
  Hive.box('settings').get('downloadQuality', defaultValue: '320 kbps');
  bool stopForegroundService =
  Hive.box('settings').get('stopForegroundService', defaultValue: true);
  bool stopServiceOnPause =
  Hive.box('settings').get('stopServiceOnPause', defaultValue: true);
  bool synced = false;
  List languages = [
    "Hindi",
    "English",
    "Tamil",
    "Malayalam"
  ];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList();

  @override
  void initState() {
    main();
    super.initState();
  }

  void main() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    List temp = packageInfo.version.split('.');
    temp.removeLast();
    setState(() {});
  }

  updateUserDetails(String key, dynamic value) {
    final userID = Hive.box('settings').get('userID');
    final dbRef = FirebaseDatabase.instance.reference().child("Users");
    dbRef.child(userID).update({"$key": "$value"});
  }

  Future<String> selectFolder() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isRestricted || status.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      debugPrint(statuses[Permission.storage].toString());
    }
    status = await Permission.storage.status;
    if (status.isGranted) {
      String path = await ExtStorage.getExternalStorageDirectory();
      Directory rootPath = Directory(path);
      String temp = await FilesystemPicker.open(
        title: 'Select folder',
        context: context,
        rootDirectory: rootPath,
        fsType: FilesystemType.folder,
        pickText: 'Select this folder',
        folderIconColor: Theme.of(context).accentColor,
      ) ??
          '';
      return temp;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
            'Settings',
            style: GoogleFonts.dmSans(fontSize: size.width * 0.07, color: Theme.of(context).primaryColor,
            )),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(left: 1.5, right: 1.5, top: 10),
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
              child: GradientCard(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: Hive.box('settings').listenable(),
                      builder: (context, box, widget) {
                        return ListTile(
                          title: Text('Name'),
                          dense: true,
                          trailing: Text(
                            box.get('name') == null || box.get('name') == ''
                                ? 'Guest User'
                                : box.get('name'),
                            style: GoogleFonts.dmSans(fontSize: 12,),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final controller = TextEditingController(
                                    text: box.get('name'));
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Name',
                                            style: GoogleFonts.dmSans(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextField(
                                          autofocus: true,
                                          controller: controller,
                                          onSubmitted: (value) {
                                            box.put('name', value.trim());
                                            updateUserDetails(
                                                'name', value.trim());
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Theme.of(context).brightness ==
                                            Brightness.dark
                                            ? Colors.white
                                            : Colors.grey[700],
                                        //       backgroundColor: Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        "Cancel",
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor:
                                        Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        "Ok",
                                        style: GoogleFonts.dmSans(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        box.put('name', controller.text.trim());
                                        updateUserDetails(
                                            'name', controller.text.trim());
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder(
                      valueListenable: Hive.box('settings').listenable(),
                      builder: (context, box, widget) {
                        return ListTile(
                          title: Text('Email'),
                          dense: true,
                          trailing: Text(
                            box.get('email') == null || box.get('email') == ''
                                ? 'xxxxxxxxxx@gmail.com'
                                : box.get('email'),
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final controller = TextEditingController(
                                    text: box.get('email'));
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Email',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextField(
                                          autofocus: true,
                                          controller: controller,
                                          onSubmitted: (value) {
                                            box.put('email', value.trim());
                                            updateUserDetails(
                                                'email', value.trim());
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Theme.of(context).brightness ==
                                            Brightness.dark
                                            ? Colors.white
                                            : Colors.grey[700],
                                        //       backgroundColor: Theme.of(context).accentColor,
                                      ),
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor:
                                        Theme.of(context).accentColor,
                                      ),
                                      child: Text(
                                        "Ok",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        box.put(
                                            'email', controller.text.trim());
                                        updateUserDetails(
                                            'email', controller.text.trim());
                                        Navigator.pop(context);
                                      },
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(5.0, 0, 5, 10),
              child: GradientCard(
                child: Column(
                  children: [
                    // Divider(
                    //   height: 0,
                    //   indent: 15,
                    //   endIndent: 15,
                    // ),
                    ListTile(
                      title: Text('Share'),
                      onTap: () {
                        Share.share(
                            'Hey! Check out this cool music player app: Wow_music and enjoy');
                      },
                      dense: true,
                    ),

                    ListTile(
                      title: Text('Contact Us'),
                      dense: true,
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      // stops: [0, 0.2, 0.8, 1],
                                      colors: Theme.of(context).brightness ==
                                          Brightness.dark
                                          ? [
                                          Colors.grey[850],
                                      Colors.grey[850],
                                      Colors.grey[900],
                                      ]
                                          : [
                                      Colors.white,
                                      Theme.of(context).canvasColor,
                                  ],
                                ),
                              ),
                              // color: Colors.black,
                              height: 100,
                              child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                              Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              IconButton(
                              icon: Icon(MdiIcons.instagram),
                              iconSize: 40,
                              onPressed: () {
                              Navigator.pop(context);
                              launch(
                              "https://instagram.com/flutter.experts");
                              },
                              ),
                              Text('Instagram'),
                              ],
                              ),
                              ],
                              ),
                              );
                            });
                      },
                    ),
                    ListTile(
                      title: Text('More info'),
                      dense: true,
                      onTap: () {
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}