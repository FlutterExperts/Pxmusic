import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:pxmusic/CustomWidgets/miniplayer.dart';
import 'package:pxmusic/Helpers/icon.dart';
import 'package:pxmusic/Screens/Library/library.dart';
import 'package:pxmusic/Screens/Library/liked.dart';
import 'package:pxmusic/Screens/Search/search.dart';
import 'discover.dart';

class HomePage extends StatefulWidget {
  final String playlistName;
  HomePage({Key key, @required this.playlistName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box settingsBox;
  Box likedBox;
  bool status = false;
  bool understood;
  final _pageViewController = PageController();

  int _activePage = 0;
  void getLiked() {
    likedBox = Hive.box(widget.playlistName);
    understood = Hive.box('settings').get('understood');
    understood ??= false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageViewController.dispose();

    super.dispose();
  }

  final _screens = [
    Discover(),
    SearchPage(),
    LikedSongs(playlistName: 'Favorite Songs'),
    LibraryPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          fixedColor: Theme.of(context).primaryColor,
          currentIndex: _activePage,
          onTap: (index) {
            _pageViewController.animateToPage(index,
                duration: Duration(milliseconds: 500), curve: Curves.ease);
          },
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Iconclass().discovery,
                  color: Theme.of(context).primaryColor,
                ),
                activeIcon: SvgPicture.asset(
                  Iconclass().discoveryFill,
                  color: Theme.of(context).primaryColor,
                ),
                label: "Discover"),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Iconclass().search,
                  color: Theme.of(context).primaryColor,
                ),
                activeIcon: SvgPicture.asset(
                  Iconclass().searchFill,
                  color: Theme.of(context).primaryColor,
                ),
                label: "Search"),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Iconclass().liked,
                  color: Theme.of(context).primaryColor,
                ),
                activeIcon: SvgPicture.asset(
                  Iconclass().likedFill,
                  color: Theme.of(context).primaryColor,
                ),
                label: "Liked"),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  Iconclass().library,
                  color: Theme.of(context).primaryColor,
                ),
                activeIcon: SvgPicture.asset(
                  Iconclass().libraryFill,
                  color: Theme.of(context).primaryColor,
                ),
                label: "Library"),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: PageView(
                controller: _pageViewController,
                children: _screens,
                onPageChanged: (index) {
                  setState(() {
                    _activePage = index;
                  });
                }),
          ),
          MiniPlayer()
        ]));
  }
}
