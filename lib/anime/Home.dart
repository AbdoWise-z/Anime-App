import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../Widgets/DotsIndicator.dart';
import '../Widgets/LoadingPage.dart';
import '../utility/Base.dart';
import 'AnimeCard.dart';


class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool ready=false;
  bool error=false;
  bool loading =true;
  List recentAnime=[];
  List authorsList=[];
  List studioList=[];
  List news=[];
  List favourites=[];
  List watchList=[];
  int _currentPage=0;
  Timer _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer){});
  final controller =PageController(initialPage: 0);

  static const _kDuration =  Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;


  void getRecentAnimeAndNews() async {
    //print("starting..");
    var r = await http.get(Uri.parse('$ServerAddress/anime_list'));
    //print(r.body);
    recentAnime =jsonDecode(r.body);
    //print(recentAnime.map((e) => e));
    //print("done..");
    var rr = await http.get(Uri.parse('$ServerAddress/select/allNews'));
    //print(rr.body);
    news=jsonDecode(rr.body);
    //print(news.map((e) => e));
    //print("done..");
    var rrr = await http.get(Uri.parse('$ServerAddress/select/favoritesByUser?userId=${CurrentUser.ID}'));
    //print(rrr.body);
    favourites=jsonDecode(rrr.body);
    var rrrr = await http.get(Uri.parse('$ServerAddress/select/watchlistByUser?userId=${CurrentUser.ID}'));
    print(rrrr.body);
    watchList=jsonDecode(rrrr.body);

    for(var element in favourites) {
      CurrentUser.favorites.add(element['anime_id']);
    }
    for(var element in watchList) {
      CurrentUser.watchList.add(element['anime_id']);
    }

    setState(() {
      ready=true;
      loading=false;
    });

  }

  Future refresh() async {
    getRecentAnimeAndNews();
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri= Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    getRecentAnimeAndNews();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < news.length-1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }


  @override
  Widget build(BuildContext context) {
    if(ready){
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Home',),
            backgroundColor: Colors.blue,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/anime/Search");
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text('Categories',
                    style: TextStyle(color: Colors.white,fontSize: 24),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child:
                  Text("Lists",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent
                    ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/user/Favourite');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.favorite_outlined,color: Colors.black,),
                    title: Text('Favourites'),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/user/WatchList');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.playlist_play_sharp,color: Colors.black,),
                    title: Text('Watch List'),
                  ),
                ),
                Divider(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child:
                  Text("Functions",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent
                    ),
                  ),
                ),
                Visibility(
                  visible: CurrentUser.Attr == 1 ,
                  child: TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/admin/panel');
                    },
                    child: const ListTile(
                      leading: Icon(Icons.key_sharp ,color: Colors.black,),
                      title: Text('Admin panel'),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pushNamed(context, '/user/enquiry');
                  },
                  child: const ListTile(
                    leading: Icon(Icons.question_mark ,color: Colors.black,),
                    title: Text('Submit Enquiry'),
                  ),
                ),
                TextButton(
                  onPressed: (){
                    _logout();
                  },
                  child: const ListTile(
                    leading: Icon(Icons.power_settings_new_outlined ,color: Colors.black,),
                    title: Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            color: Colors.black,
            onRefresh: refresh,
            child: ListView(
                children: [
                  Stack(
                      children: [
                        Container(
                          height: 400,
                          child: PageView(
                              controller: controller,
                              children:
                              news.map((e) => InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(e['img_link']),
                                          fit: BoxFit.cover
                                      )
                                  ),
                                ),
                                onTap: (){
                                  _launchInBrowser(e['link']);
                                },
                              ),).toList()
                          ),
                        ),
                        Positioned(
                            bottom: 0.0,
                            left: 0.0,
                            right: 0.0,
                            child:Container(
                              color: Colors.black.withOpacity(0.5),
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: DotsIndicator(
                                  controller: controller,
                                  itemCount: news.length,
                                  onPageSelected: (int page) {
                                    controller.animateToPage(
                                      page,
                                      duration: _kDuration,
                                      curve: _kCurve,
                                    );
                                  },
                                ),
                              ),
                            )
                        )
                      ]
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 500,
                      color: Colors.blue,
                      child: const Center(
                        child: Text('Most Recent Anime',
                          style: TextStyle(
                            fontSize: 25,color: Colors.white,
                          ),),
                      ),
                    ),
                  ),
                  GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      children:
                      recentAnime.map((e) => AnimeCard(e['id'], e['rate'].toString(), e['anime_name'], e['episodes'].toString(),e['img_link'],
                      )).toList()
                  ),
                ]
            ),
          )
      );
    }else if(loading){
      return const LoadingPage();
    }else {return const Center(
      child: Text('error'),
    );}
  }

  void _logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString("SessionID", ""); //clear the share
    exit(0);
  }
}

