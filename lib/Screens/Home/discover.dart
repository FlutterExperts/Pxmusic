import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pxmusic/Helpers/icon.dart';
import 'package:pxmusic/Screens/Home/trending.dart';
import 'package:pxmusic/APIs/database.dart';

class Discover extends StatefulWidget {
  const Discover({Key key}) : super(key: key);

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      endDrawer: Drawer(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: CircleAvatar(
                maxRadius: 41,
                backgroundImage:
                    CachedNetworkImageProvider(Database().image[0]),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: Text("famil",
                      style: Theme.of(context).textTheme.headline5),
                )),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Center(
                  child: Text(
                "....gmail.com",
                style: Theme.of(context).textTheme.bodyText1,
              )),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                "I N F O",
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            ListTile(
              onTap: () {},
              leading: SvgPicture.asset(Iconclass().star),
              title: Text("Rate this app"),
            ),
            Divider(
              thickness: 1,
              color: Color(0xFFDBDBDB),
            ),
            ListTile(
              onTap: () {},
              leading: SvgPicture.asset(Iconclass().user),
              title: Text("About Us"),
            ),
            Divider(
              thickness: 1,
              color: Color(0xFFDBDBDB),
            ),
            ListTile(
              onTap: () {},
              leading: SvgPicture.asset(Iconclass().call),
              title: Text("Contact Us"),
            ),
            Divider(
              thickness: 1,
              color: Color(0xFFDBDBDB),
            ),
            ListTile(
              onTap: () {},
              leading: SvgPicture.asset(Iconclass().share),
              title: Text("Share"),
            ),
            Divider(
              thickness: 1,
              color: Color(0xFFDBDBDB),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 25, left: 24, right: 24, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discover",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    GestureDetector(
                      onTap: () {
                        _scaffoldkey.currentState.openEndDrawer();
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(Database().image[1]),
                      ),
                    )
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                  child: Row(
                    children: List.generate(
                      Database().image.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 14.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Column(
                            children: [
                              Container(
                                width: 240,
                                height: 261,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        Database().image[index],
                                      ),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              TrendingPage(),
            ],
          ),
        ),
      ),
    );
  }
}
