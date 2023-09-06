class Comment{
  String data;
  String user_name;
  int User_Id;
  int Anime_Id;
  int Comment_Id;
  DateTime? date;

  Comment({
    this.data = "",
    this.user_name = "",
    this.User_Id = -1,
    this.Anime_Id = -1,
    this.Comment_Id = -1,
    this.date,
  });
}