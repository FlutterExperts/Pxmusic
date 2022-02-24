import 'package:pxmusic/CustomWidgets/GradientContainers.dart';
import 'package:pxmusic/CustomWidgets/miniplayer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Box settingsBox = Hive.box('settings');
  List playlistNames = [];
  Map playlistDetails = {};
  @override
  Widget build(BuildContext context) {
    playlistNames = settingsBox.get('playlistNames')?.toList() ?? [];
    playlistDetails = settingsBox.get('playlistDetails', defaultValue: {});

    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(
                  'Playlists',
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.transparent
                    : Theme.of(context).accentColor,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5),
                    ListTile(
                      title: Text('Create Playlist'),
                      leading: Card(
                        elevation: 0,
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? null
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final _controller = TextEditingController();
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Create new playlist',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextField(
                                      controller: _controller,
                                      autofocus: true,
                                      onSubmitted: (String value) {
                                        if (value.trim() == '')
                                          value =
                                              'Playlist ${playlistNames.length}';

                                        if (playlistNames.contains(value))
                                          value = value + ' (1)';
                                        playlistNames.add(value);
                                        settingsBox.put(
                                            'playlistNames', playlistNames);
                                        Navigator.pop(context);
                                        setState(() {});
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
                                    if (_controller.text.trim() == '')
                                      _controller.text =
                                          'Playlist ${playlistNames.length}';

                                    if (playlistNames
                                        .contains(_controller.text))
                                      _controller.text =
                                          _controller.text + ' (1)';
                                    playlistNames.add(_controller.text);
                                    settingsBox.put(
                                        'playlistNames', playlistNames);
                                    Navigator.pop(context);
                                    setState(() {});
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}

void addPlaylist(String name, Map info) async {
  if (name != 'Favorite Songs') await Hive.openBox(name);
  Box playlistBox = Hive.box(name);
  playlistBox.put(info['id'].toString(), info);
}

