import 'package:flutter/material.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Expanded(child: AdminOptionCard(text: "Enquiries", path: "/admin/enq_list", image: Icons.question_mark_rounded, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Animes", path: "/admin/add/Anime", image: Icons.list_alt, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Authors", path: "/admin/add/Author", image: Icons.person, imageColor: Colors.blue)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Expanded(child: AdminOptionCard(text: "Characters", path: "/admin/add/Character", image: Icons.person_pin_rounded, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Episodes", path: "/admin/add/Episode", image: Icons.video_camera_back_outlined, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Add News", path: "/admin/add/News", image: Icons.newspaper_rounded, imageColor: Colors.blue)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Expanded(child: AdminOptionCard(text: "Singers", path: "/admin/add/Singer", image: Icons.library_music_outlined, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Songs", path: "/admin/add/Song", image: Icons.music_note, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Studios", path: "/admin/add/Studio", image: Icons.apartment_outlined, imageColor: Colors.blue)),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Expanded(child: AdminOptionCard(text: "VAs", path: "/admin/add/VA", image: Icons.person_outline_outlined, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Awards", path: "/admin/add/Awards", image: Icons.school, imageColor: Colors.blue)),
              Expanded(child: AdminOptionCard(text: "Del News", path: "/admin/delete/News", image: Icons.delete_forever_outlined, imageColor: Colors.blue)),
            ],
          ),
        ],
      ),
    );
  }
}


class AdminOptionCard extends StatelessWidget {
  final String text;
  final String path;
  final IconData image;
  final Color imageColor;
  const AdminOptionCard({Key? key, required this.text, required this.path, required this.image, required this.imageColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Icon(
                  image,
                  color: imageColor,
                  size: 120,
                ),
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

