import 'dart:convert';

import 'package:anime/Widgets/LoadingCard.dart';
import 'package:flutter/material.dart';
import '../data/Comment.dart';
import 'package:anime/utility/Base.dart';
import 'package:http/http.dart' as http;

class CommentsSectionPage extends StatefulWidget {
  List<Comment> comments;
  int AnimeID;

  CommentsSectionPage({
    Key? key,
    this.comments = const [],
    this.AnimeID = -1,
  }) : super(key: key);

  @override
  State<CommentsSectionPage> createState() => _CommentsSectionPageState();
}

class _CommentsSectionPageState extends State<CommentsSectionPage> {
  List<int> hidden_comments = [];

  var TextController = TextEditingController();
  String? comment_error = null;
  String loadingmsg = "";

  bool isLoading = false;

  void DeleteComment(int CommentID) async {
    setState(() {
      isLoading = true;
      loadingmsg = "Deleting comment";
    });
    try {
      var r = await http.post(
        Uri.parse('$ServerAddress/delete/Comment'),
        body: jsonEncode({
          "Token": SessionID,
          "commentId": CommentID,
        }).toString(),
        headers: {
          "content-type": "application/json",
        },
      );
      print(r.body);
      var data = jsonDecode(r.body);
      if (data["STATUS"] == 1){
        widget.comments.removeWhere((element) => element.Comment_Id == CommentID);
        comment_error = null;
      }else{
        comment_error = "Failed to delete , don't have permission.";
      }
    }catch (e){
      print(e);
      comment_error = "Failed to delete , check internet.";
    }

    setState(() {
      isLoading = false;
    });
  }

  void CreateComment() async {

    TextController.text = TextController.text.trim();
    if (TextController.text.isEmpty) {
      comment_error = "Comment cannot be empty";
      setState(() {});
      return;
    }

    comment_error = null;
    setState(() {
      isLoading = true;
      loadingmsg = "Adding your comment ...";
    });

    try {
      var r = await http.post(
        Uri.parse('$ServerAddress/insert/Comment'),
        body : jsonEncode({
          "Token" : SessionID,
          "commentData" : TextController.text,
          "animeId" : widget.AnimeID,
        }).toString(),
        headers: {
          "content-type" : "application/json",
        },
      );

      print(r.body);

      var comment_data = jsonDecode(r.body);

      widget.comments.add(Comment(
        date: DateTime.now(),
        data: TextController.text,
        User_Id: CurrentUser.ID,
        Anime_Id: widget.AnimeID,
        user_name: CurrentUser.name,
        Comment_Id: comment_data["commentId"],
      ));

    }catch (e){
      print(e);
      comment_error = "Failed to add comment , check connection.";
      setState(() {
        isLoading = false;
      });
      return;
    }



    TextController.text = "";

    setState(() {
      isLoading = false;
    });

  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: isLoading,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child:
                  ListView.builder(
                    itemBuilder: (bc , i) {
                      Comment e = widget.comments[i];
                      return CommentView(
                        date: e.date,
                        text: hidden_comments.contains(e.Comment_Id) ? "-- hidden --" : e.data,
                        author: e.user_name,
                        menu_items: isAdmin() ? [hidden_comments.contains(e.Comment_Id) ? "show" : "hide" ,  "delete" , "ban user"] : e.User_Id == CurrentUser.ID ? [hidden_comments.contains(e.Comment_Id) ? "show" : "hide" , "delete"] : [hidden_comments.contains(e.Comment_Id) ? "show" : "hide"],
                        onItemSelected: (index) {
                          if (index == 0) { //hide or show
                            if (hidden_comments.contains(e.Comment_Id)) {
                              hidden_comments.remove(e.Comment_Id);
                            } else {
                              hidden_comments.add(e.Comment_Id);
                            }
                            setState(() {});
                          }else if (index == 1){
                            DeleteComment(e.Comment_Id);
                          } else {
                            Navigator.pushNamed(context, "/admin/ban" , arguments: {
                              "uName" : e.user_name,
                              "uID" : e.User_Id
                            });
                          }
                        },
                      );
                    },
                    itemCount: widget.comments.length,
                  )
              ),
              Divider(
                height: 1,
                color: Colors.grey[400],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Theme(
                      data: ThemeData(splashColor: Color(0x610080FF)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: Material(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          clipBehavior: Clip.hardEdge,
                          color: const Color(0x08000000),
                          child: InkWell(
                            child: TextFormField(
                              maxLength: 100,
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                                hintText: "Enter comment",
                                border: InputBorder.none,
                                errorText: comment_error,
                              ),
                              controller: TextController,
                            ),
                            onTap: () { //useless because fk flutter
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(onPressed: () {
                    CreateComment();
                  }, icon: const Icon(Icons.send_rounded))
                ],
              )
            ],
          ),
        ),
        Visibility(
          visible: isLoading,
          child: const Center(
            child: LoadingCard(
              msg: "Adding your comment ..",
            ),
          ),
        )
      ],
    );
  }
}

class CommentView extends StatelessWidget {
  final String author;
  final String text;
  final List<String> menu_items;
  final DateTime? date;

  final Function(int item_index)? onItemSelected;

  const CommentView({
    Key? key,
    this.author = "none",
    this.text = "none",
    this.menu_items = const <String>[],
    this.date,
    this.onItemSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        elevation: 0,
        color: Color(0x08000000),
        shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    this.author,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,

                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    date == null ? "" : "${date?.year}/${date?.month}/${date?.day} ${date?.hour}:${date?.minute}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 15,),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: PopupMenuButton(
                      iconSize: 14,
                      padding: EdgeInsets.all(0),
                      onSelected: (val) {
                        if (onItemSelected != null) onItemSelected!(val);
                      },
                      itemBuilder: (bc) {
                        int i = 0;
                        List<PopupMenuItem<int>> l = [];
                        for (var e in menu_items) {
                          l.add(PopupMenuItem<int>(
                            value: i++,
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(e),
                          ));
                        }
                        return l;
                      },
                    ),
                  )
                ],
              ),
              Text(
                this.text,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentView2 extends StatelessWidget {
  final String author;
  final String text;
  final List<String> menu_items;
  final DateTime? date;

  final Function(int item_index)? onItemSelected;

  const CommentView2({
    Key? key,
    this.author = "none",
    this.text = "none",
    this.menu_items = const <String>[],
    this.date,
    this.onItemSelected
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        elevation: 0,
        color: Color(0x800B1FF),
        shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Row(
                children: [
                  Text(
                    this.author,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,

                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    date == null ? "" : "${date?.year}/${date?.month}/${date?.day} ${date?.hour}:${date?.minute}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(width: 15,),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: PopupMenuButton(
                      iconSize: 14,
                      padding: EdgeInsets.all(0),
                      onSelected: (val) {
                        if (onItemSelected != null) onItemSelected!(val);
                      },
                      itemBuilder: (bc) {
                        int i = 0;
                        List<PopupMenuItem<int>> l = [];
                        for (var e in menu_items) {
                          l.add(PopupMenuItem<int>(
                            value: i++,
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(e),
                          ));
                        }
                        return l;
                      },
                    ),
                  )
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              elevation: 0,
              color: Color(0x08000000),
              shape: RoundedRectangleBorder(
                borderRadius:BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    this.text,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

