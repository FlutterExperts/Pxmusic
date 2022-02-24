import 'dart:ui';
import 'package:pxmusic/Helpers/icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pxmusic/APIs/api.dart';
import 'package:flutter_svg/svg.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Widget> moods = [];
  TextEditingController searchController = TextEditingController();
  List searchedList = [];
  bool fetched = false;
  @override
  void initState() {
    rowbuilder();
    super.initState();
  }

  void rowbuilder() {
    for (var i = 1; i <= Iconclass().emotion.length; i++) {
      if (i.remainder(3) == 0) {
        moods.add(Row(
          children: List.generate(3, (index) {
            print(i == 0 ? index + 1 : i + index - 2);
            return Padding(
              padding:
              const EdgeInsets.only(right: 12.0, bottom: 5.0, top: 5.0),
              child: Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                height: 52,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Color.fromRGBO(0, 0, 0, 0.07000000029802322),
                    //     offset: Offset(0, 0),
                    //     blurRadius: 40,
                    //   )
                    // ],
                    color: Color(0xFFF2F2F2)),
                child: Center(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 14.0),
                        child: Text(
                          Iconclass().emoji[i == 0 ? index : i + index - 2],
                          style: TextStyle(
                            fontSize: 26,
                          ),
                        ),
                      ),
                      Text(
                        Iconclass().emotion[i == 0 ? index : i + index - 2],
                        style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Color(0xff383838)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: 22),
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.only(left: 23.0, right: 23.0, bottom: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: Container(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: searchController,
                      onChanged: (value) {
                        setState(() async {
                          if (value.length == 0) {
                            fetched = false;
                          } else {
                            await Search()
                                .fetchSearchResults(value)
                                .then((value) {
                              setState(() {
                                searchedList = value;
                                fetched = true;
                              });
                            });
                          }
                        });
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: SvgPicture.asset(
                            Iconclass().search,
                            width: 25,
                            height: 25,
                            color: Theme.of(context).primaryColor,
                          ),
                          hintText: "Search by Artists,Songs",
                          hintStyle: Theme.of(context).textTheme.caption),
                      cursorColor: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            searchController.text == ""
                ? Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 23.0, bottom: 10.0),
                    child: Text(
                      "Moods",
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
                ),

                // Emoji RECTANGLE
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 23.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: moods,
                    ),
                  ),
                )
              ],
            )
                : searchedList.length == 0
                ? SizedBox(
              child: Text("iam"),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: searchedList.length,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(23),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      '${searchedList[index]["image"].replaceAll('http:', 'https:')}'))),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width:
                          MediaQuery.of(context).size.width * 0.6,
                          child: Flexible(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${searchedList[index]["title"].split("(")[0]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 1,
                                ),
                                Text(
                                  '${searchedList[index]["subtitle"]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  maxLines: 1,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}