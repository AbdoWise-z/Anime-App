
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'EpisodePage.dart';
import '../data/Episode.dart';

class EpisodesList extends StatelessWidget {
  final List<Episode> list;

  const EpisodesList({Key? key , required this.list}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (bc , i) => EpisodesListItem(index: list[i].num, url: list[i].url,),
      itemCount: list.length,
    );
  }
}


class EpisodesListItem extends StatelessWidget {
  final String url;
  final int index;
  const EpisodesListItem({Key? key , required this.url ,required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        child: Theme(
          data: ThemeData(splashColor: const Color(0xBEC392FF)),
          child: Material(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            clipBehavior: Clip.hardEdge,
            color: const Color(0x04000000),
            child: OpenContainer(
                openBuilder: (context,VoidCallback fnn){
                  return EpisodePage(url, index);
                },
                closedBuilder: (context,VoidCallback fn){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Episode $index",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,

                          ),
                        ),
                        Text(
                          url,
                          style: const TextStyle(
                              fontSize: 8,
                              color: Colors.black54
                          ),
                        ),
                      ],
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }
}

