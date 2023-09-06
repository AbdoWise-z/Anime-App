import 'package:flutter/material.dart';



class LoginPage extends StatefulWidget {
  final Function(String , String , bool login) loginCallback;
  final Function() registerCallback;
  final String PasswordError , UserError;
  final bool hasUserError , hasPasswordError;
  const LoginPage(this.loginCallback , this.registerCallback
      , { Key? key,
        this.PasswordError = "Wrong password",
        this.hasPasswordError = false,
        this.UserError = "Wrong username",
        this.hasUserError = false,}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String user = "";
  String pass = "";
  bool remember = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 1,
          child: SizedBox() ,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 12),
              child: Text(
                "Welcome",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]
                ),
              ),
            ),
          ],
        ),

        Theme(
          data: ThemeData(splashColor: Color(0x6170FFE6)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Material(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              color: const Color(0x08000000),
              child: InkWell(
                child: TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                      hintText: "Username",
                      border: InputBorder.none
                  ),
                  onChanged: (text) => user = text,
                ),
                onTap: () {
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.hasUserError,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 4, 24, 0),
            child: Text(
              widget.UserError,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red
              ),
            ),
          ),
        ),
        Theme(
          data: ThemeData(splashColor: const Color(0x6170FFE6)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Material(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              color: const Color(0x08000000),
              child: InkWell(
                child: TextFormField(
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                      hintText: "Password",
                      border: InputBorder.none
                  ),
                  onChanged: (text) => pass = text,
                ),
                onTap: () { //useless because fk flutter
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.hasPasswordError,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 4, 24, 0),
            child: Text(
              widget.PasswordError,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red
              ),
            ),
          ),
        ),
        Row(
          children: [
            const SizedBox(width: 24,),
            Checkbox(
                value: remember,
                onChanged: (bool? c)
                {
                  setState(() {
                    remember = c ?? false;
                  });
                }
            ),
            const Text("Remember me")
          ],
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Theme(
              data: ThemeData(splashColor: Colors.red[200]),
              child: Material(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.hardEdge,
                color: const Color(0x12000000),
                child: InkWell(
                  child: const SizedBox(width: 200 , height: 40,
                    child: Center(
                      child: Text(
                        "Login",
                      ),
                    ),
                  ),
                  onTap: () {
                    widget.loginCallback(user , pass , remember);
                  },
                ),
              ),
            ),
          ],
        ),

        const Expanded(
          flex: 2,
          child: SizedBox(),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "new user ?",
              style: TextStyle(
                  color: Colors.blue
              )
              ,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                height: 40,
                child: TextButton(
                    onPressed: () {
                      widget.registerCallback();
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(4)),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Colors.grey,
                                  width: 0.5),
                            )
                        )
                    ),
                    child: const Text("Register")
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


