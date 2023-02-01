import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/widgets.dart';

class Password_Change extends StatefulWidget {
  const Password_Change({Key? key}) : super(key: key);

  @override
  _Password_ChangeState createState() => _Password_ChangeState();
}

class _Password_ChangeState extends State<Password_Change> {
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;

  //
  // void currentUsr() {
  //   var currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     userId = currentUser.uid;
  //     print('current user $userId');
  //     //roleStream();
  //   }
  // }
  changePassword() async {
    var user = FirebaseAuth.instance.currentUser;

    await user?.updatePassword(passwordEditingController.text).then((_) async {
      print("Successfully changed password");
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      errorAlert(context, "Password can't be changed. Re-Authentication need.");
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        autofocus: false,
        obscureText: hidePassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return "Password too short";
          }
          return null;
        },
        controller: passwordEditingController,
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.purple.shade50,
            enabledBorder: InputBorder.none,
            prefixIcon: Icon(
              Icons.vpn_key,
              color: Colors.purple[200],
            ),
            suffixIcon: hidePassword
                ? IconButton(
                    icon: Icon(
                      Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                      Icons.visibility_off,
                      color: Colors.black54,
                    ),
                  ),
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: 'Enter Your Password',
            hintStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none),
      ),
    );

    final changeButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.purple,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Loader.show(context);
            await changePassword();
            Loader.hide();

          }
        },
        child: Text(
          'Change password',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Text(
                    //   'TechTrioz Solution',
                    //   style: TextStyle(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.lightBlue),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    passwordField,

                    SizedBox(
                      height: 20.0,
                    ),
                    changeButton,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
