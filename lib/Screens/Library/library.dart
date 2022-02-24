import 'dart:io';
import 'package:pxmusic/Screens/Home/trending.dart' as trendingScreen;
import 'package:ext_storage/ext_storage.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pxmusic/CustomWidgets/gradientContainers.dart';
import 'package:pxmusic/Helpers/icon.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LibraryPage extends StatefulWidget {
  final Function callback;
  LibraryPage({this.callback});
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String downloadPath = Hive.box('settings')
      .get('downloadPath', defaultValue: '/storage/emulated/0/Music/');
  List dirPaths = Hive.box('settings').get('searchPaths', defaultValue: []);
  String streamingQuality =
      Hive.box('settings').get('streamingQuality', defaultValue: '96 kbps');
  String downloadQuality =
      Hive.box('settings').get('downloadQuality', defaultValue: '320 kbps');
  bool stopForegroundService =
      Hive.box('settings').get('stopForegroundService', defaultValue: true);
  bool synced = false;
  List languages = ["Hindi", "English", "Tamil", "Malayalam"];
  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList();
  Box likedBox;

  @override
  void initState() {
    super.initState();
    Hive.openBox('Favorite Songs');
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 25, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Library",
              style: Theme.of(context).textTheme.headline1,
            ),
            SizedBox(
              height: 39,
            ),
            customTile(
                tittle: "Recently Played",
                icon: Iconclass().timeCircle,
                route: "/recent"),
            customTile(
                tittle: "Downloads",
                icon: Iconclass().download,
                route: "/downloaded"),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SvgPicture.asset(Iconclass().musicNote,
                          color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        "Music Language",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              List checked = List.from(preferredLanguage);
                              return StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setStt) {
                                return BottomGradientContainer(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            physics: BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 10),
                                            scrollDirection: Axis.vertical,
                                            itemCount: languages.length,
                                            itemBuilder: (context, idx) {
                                              return CheckboxListTile(
                                                activeColor: Theme.of(context)
                                                    .primaryColor,
                                                value: checked
                                                    .contains(languages[idx]),
                                                title: Text(languages[idx]),
                                                onChanged: (value) {
                                                  value
                                                      ? checked
                                                          .add(languages[idx])
                                                      : checked.remove(
                                                          languages[idx]);
                                                  setStt(() {});
                                                },
                                              );
                                            }),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            child: Text('Cancel'),
                                            style: TextButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text(
                                              'Ok',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            style: TextButton.styleFrom(
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                preferredLanguage = checked;
                                                Navigator.pop(context);
                                                Hive.box('settings').put(
                                                    'preferredLanguage',
                                                    checked);
                                                updateUserDetails(
                                                    "preferredLanguage",
                                                    checked);
                                                trendingScreen.fetched = false;
                                                trendingScreen.showCached =
                                                    true;
                                                trendingScreen.playlists = [
                                                  {
                                                    "id": "RecentlyPlayed",
                                                    "title": "RecentlyPlayed",
                                                    "image": "",
                                                    "songsList": [],
                                                    "type": ""
                                                  }
                                                ];
                                                trendingScreen.cachedPlaylists =
                                                    [
                                                  {
                                                    "id": "RecentlyPlayed",
                                                    "title": "RecentlyPlayed",
                                                    "image": "",
                                                    "songsList": [],
                                                    "type": ""
                                                  }
                                                ];
                                                trendingScreen
                                                        .preferredLanguage =
                                                    preferredLanguage;
                                                widget.callback();
                                              });
                                              if (preferredLanguage.length == 0)
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    elevation: 6,
                                                    backgroundColor:
                                                        Colors.grey[900],
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    content: Text(
                                                      'No Music language selected. Select a language to see songs on Home Screen',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    action: SnackBarAction(
                                                      textColor:
                                                          Theme.of(context)
                                                              .accentColor,
                                                      label: 'Ok',
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                            });
                      },
                      child: Text(
                        preferredLanguage.isEmpty
                            ? "None"
                            : preferredLanguage.join(", "),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Color(0xFFDBDBDB),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SvgPicture.asset(Iconclass().musicStream,
                          color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Text(
                        "Streaming Quality",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Spacer(),
                    DropdownButton(
                      value: streamingQuality ?? '96 kbps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          streamingQuality = newValue;
                          Hive.box('settings')
                              .put('streamingQuality', newValue);
                          updateUserDetails('streamingQuality', newValue);
                        });
                      },
                      items: <String>['96 kbps', '160 kbps', '320 kbps']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Color(0xFFDBDBDB),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SvgPicture.asset(Iconclass().papperDownload,
                          color: Theme.of(context).primaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Text(
                        "Download Quality",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ),
                    Spacer(),
                    DropdownButton(
                      value: downloadQuality ?? '320 kbps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                      underline: SizedBox(),
                      onChanged: (String newValue) {
                        setState(() {
                          downloadQuality = newValue;
                          Hive.box('settings').put('downloadQuality', newValue);
                          updateUserDetails('downloadQuality', newValue);
                        });
                      },
                      items: <String>['96 kbps', '160 kbps', '320 kbps']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Color(0xFFDBDBDB),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customTile({
    String tittle,
    String icon,
    String route,
  }) {
    return Container(
      height: 70,
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: SvgPicture.asset(icon,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                tittle,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, route);
                },
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFDBDBDB),
                ),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: Color(0xFFDBDBDB),
          ),
        ],
      ),
    );
  }

  Widget musicLanguage() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: SvgPicture.asset(
                Iconclass().musicNote,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              "Music Language",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFDBDBDB),
              ),
            ),
          ],
        ),
        Divider(
          thickness: 1,
          color: Color(0xFFDBDBDB),
        ),
      ],
    );
  }
}
