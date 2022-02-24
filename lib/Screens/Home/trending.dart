import 'package:pxmusic/Screens/Player/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pxmusic/APIs/api.dart';

List playlists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": "",
    "songsList": [],
    "type": ""
  }
];
List cachedPlaylists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": "",
    "songsList": [],
    "type": ""
  }
];
bool fetched = false;
bool showCached = true;
List preferredLanguage =
    Hive.box('settings').get('preferredLanguage') ?? ['English'];

class TrendingPage extends StatefulWidget {
  @override
  _TrendingPageState createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  List recentList = Hive.box('recentlyPlayed').get('recentSongs') ?? [];

  getPlaylists() async {
    final dbRef = FirebaseDatabase.instance.reference().child("Playlists");
    for (int a = 0; a < preferredLanguage.length; a++) {
      await dbRef
          .child(preferredLanguage[a])
          .once()
          .then((DataSnapshot snapshot) {
        playlists.addAll(snapshot.value);
        Hive.box('cache').put(preferredLanguage[a], snapshot.value);
      });
    }
  }

  getPlaylistSongs() async {
    await getPlaylists();
    for (int i = 1; i < playlists.length; i++) {
      try {
        playlists[i] = await Playlist().fetchPlaylistSongs(playlists[i]);
        if (playlists[i]["songsList"].isNotEmpty) {
          Hive.box('cache').put(playlists[i]["id"], playlists[i]);
        }
      } catch (e) {
        print("Error in Index $i in TrendingList: $e");
      }
    }
    setState(() {
      cachedPlaylists = playlists;
      showCached = false;
    });
  }

  getCachedPlaylists() async {
    for (int a = 0; a < preferredLanguage.length; a++) {
      Iterable value = await Hive.box('cache').get(preferredLanguage[a]);
      if (value == null) return;
      cachedPlaylists.addAll(value);
    }
    if (cachedPlaylists.length <= 1) return;
    for (int i = 1; i < cachedPlaylists.length; i++) {
      try {
        cachedPlaylists[i] =
            await Hive.box('cache').get(cachedPlaylists[i]["id"]);
      } catch (e) {
        print("Error in Index $i in CachedTrendingList: $e");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      getCachedPlaylists();
      getPlaylistSongs();
      fetched = true;
    }

    List plst = showCached == true ? cachedPlaylists : playlists;
    return ListView.builder(
        physics:
            NeverScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
        scrollDirection: Axis.vertical,
        itemCount: plst.length,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return (recentList.isEmpty)
                ? SizedBox()
                : Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                            child: Text('Last Session',
                                style: Theme.of(context).textTheme.headline5),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 185,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          itemCount: recentList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: SizedBox(
                                width: 140,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 3.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: CachedNetworkImage(
                                          imageUrl: recentList[index]["image"]
                                              .replaceAll('http:', 'https:'),
                                          placeholder: (context, url) => Image(
                                            image: AssetImage(
                                                'assets/pxmusic_cover.png'),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${recentList[index]["title"].split("(")[0]}',
                                          textAlign: TextAlign.start,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '${recentList[index]["artist"].split("(")[0]}',
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                        opaque: false,
                                        pageBuilder: (_, __, ___) => PlayScreen(
                                              data: {
                                                'response': recentList,
                                                'index': index,
                                                'offline': false,
                                              },
                                              fromMiniplayer: false,
                                            )));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: Text(
                      '${(plst[idx]["title"])}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ],
              ),
              plst[idx]["songsList"] == null
                  ? SizedBox(
                      height: 185,
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 140,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image(
                                        fit: BoxFit.cover,
                                        width: 140,
                                        image: AssetImage(
                                            'assets/pxmusic_cover.png'),
                                      ),
                                    ),
                                    Text(
                                      'Loading ...',
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    Text(
                                      'Please Wait',
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    )
                  : SizedBox(
                      height: 185,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        itemCount: plst[idx]["songsList"].length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: SizedBox(
                              width: 140,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        imageUrl: plst[idx]["songsList"][index]
                                                ["image"]
                                            .replaceAll('http:', 'https:'),
                                        placeholder: (context, url) =>
                                            Image.asset(
                                                "assets/pxmusic_cover.png"),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '${plst[idx]["songsList"][index]["title"].split("(")[0]}',
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        '${plst[idx]["songsList"][index]["artist"].split("(")[0]}',
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => PlayScreen(
                                    data: {
                                      'response': playlists[idx]["songsList"],
                                      'index': index,
                                      'offline': false,
                                    },
                                    fromMiniplayer: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          );
        });
  }
}
