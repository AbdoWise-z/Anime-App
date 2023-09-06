import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utility/Base.dart';
import 'AnimeCard.dart';

import 'package:http/http.dart' as http;


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = TextEditingController();
  String searchQuery = "";

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
    );
  }

  List<Widget> _buildActions() {
    return <Widget>[
      Visibility(
        visible: current_query != null,
        child: Center(child: LoadingAnimationWidget.discreteCircle(color: Colors.black, size: 24)),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (_controller == null ||
              _controller.text.isEmpty) {
            Navigator.pop(context);
            return;
          }
          _clearSearchQuery();
        },
      ),
    ];
  }
  String? current_query = null;
  String? next_query = null;
  void updateSearchQuery(String newQuery) async{
    if (current_query != null) {
      next_query = newQuery;
      return;
    }
    current_query = newQuery;
    next_query = null;
    setState(() {});

    var res = await http.post(
      Uri.parse("$ServerAddress/anime_list_search"),
      headers: {"content-type" : "application/json"},
      body: jsonEncode(
        {"searchWord" : current_query},
      ),
    );
    print("-----------RECEIVED-----------");
    print(res.body);
    print("------------------------------");

    animes = jsonDecode(res.body);
    setState(() {});

    current_query = null;
    if (next_query != null) {
      updateSearchQuery(newQuery);
    }
  }


  void _clearSearchQuery() {
    setState(() {
      _controller.clear();
      updateSearchQuery("");
    });
  }


  List animes = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: _buildSearchField(),
        actions: _buildActions(),
      ),

      body: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 3,
          children:
          animes.map((e) => AnimeCard(e['id'], e['rate'].toString(), e['anime_name'], e['episodes'].toString(),e['img_link'],
          )).toList()
      ),
    );
  }
}
