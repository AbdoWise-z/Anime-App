class User{
  int ID;
  String name;
  String password;
  String email;
  int Attr;
  List<int> favorites = [];
  List<int> watchList = [];


  User({
    this.ID = -1,
    this.name = "none",
    this.password = "none",
    this.email = "none",
    this.Attr = 0,
  });
}