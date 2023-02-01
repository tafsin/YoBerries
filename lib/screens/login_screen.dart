import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yo_berry_2/admin_screen/admin_dashboard.dart';
import 'package:yo_berry_2/payment_credentials.dart';
import 'package:yo_berry_2/screens/btm_nav.dart';
import 'package:yo_berry_2/screens/home_screen.dart';
import 'package:yo_berry_2/screens/signup_screen.dart';
import 'package:yo_berry_2/screens/welcome_page.dart';
import 'package:yo_berry_2/store_screens/store_dashboard.dart';
import 'package:yo_berry_2/widgets.dart';

import '../forgot_password.dart';

class Login_Page extends StatefulWidget {
  const Login_Page({Key? key}) : super(key: key);

  @override
  _Login_PageState createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool hidePassword = true;

  @override
  void dispose() {
    Loader.hide();
    // TODO: implement dispose
    super.dispose();
  }

  String uid = '';

  void initState() {
    super.initState();
  }



  Widget build(BuildContext context) {
    final emailField = Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        autofocus: false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field cannot be empty';
          }
          if (!RegExp('^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+.[a-z]')
              .hasMatch(value)) {
            return "Please Enter Valid Email";
          }
          return null;
        },
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.mail,
            color: Colors.purple[200],
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: 'Enter Your Email',
          hintStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.purple.shade50,
          enabledBorder: InputBorder.none,
          //const OutlineInputBorder(// width: 0.0 produces a thin "hairline" border
          //borderSide: const BorderSide(color: Colors.purple, width: 1.5),

          //),
          border: InputBorder
              .none, //OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
    final passwordField = Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.purple.shade50
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
        controller: passwordController,
        onSaved: (value) {
          passwordController.text = value!;
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
    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.purple,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Loader.show(context);
            try {
              await _auth
                  .signInWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text)
                  .then((value) async {
                uid = await value.user!.uid;
                print('uid is $uid');
                if (value.user != null) {
                  String role = '';
                  String country = '';
                  String userName ='';
                  String imgUrl ='';


                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .get()
                      .then((value) async {
                    role = value['role'];
                    print('user role is $role');
                    print(role);

                    if (role == 'customer') {

                      setState(() {
                        country = value['country'];
                        userName = value['userName'];
                        imgUrl = value['imageUrl'];
                      });
                      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString('country', country);
                      sharedPreferences.setString('role', role);
                      sharedPreferences.setString('userName', userName);
                      sharedPreferences.setString('imgUrl', imgUrl);
                      sharedPreferences.setString('uid', uid);
                      sharedPreferences.setString('email', emailController.text);


                      await FirebaseMessaging.instance
                          .subscribeToTopic("$country");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Btm_Nav(country, uid,
                                  userName, imgUrl)));
                    }
                    else if (role == 'store') {
                      String store_id = value['store_id'];
                      print(store_id);
                      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString('uid', uid);
                      sharedPreferences.setString('email', emailController.text);
                      sharedPreferences.setString('country', country);
                      sharedPreferences.setString('role', role);
                      await FirebaseMessaging.instance
                          .subscribeToTopic("$store_id");
                      // Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Store_Dashboard()));
                    } else if (role == 'admin') {
                      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                      sharedPreferences.setString('uid', uid);
                      sharedPreferences.setString('email', emailController.text);
                      sharedPreferences.setString('role', role);
                     // await getT();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Admin_DashBoard()));
                    } else {
                      errorAlert(context, 'User deleted, or User Not found');
                    }
                  });
                  print('Role $role');
                  Loader.hide();
                }
              });
              // .((error, stackTrace) {
              //       Loader.hide();
              //       print(error.toString());
              //       if (error.toString() ==
              //           '[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.') {
              //         errorAlert(context, 'Invalid email address');
              //       } else if (error.toString() ==
              //           '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.') {
              //         errorAlert(context, 'Invalid password');
              //       } else {
              //         errorAlert(context, error.toString());
              //       }
              //     });
            } on FirebaseAuthException catch (e) {
              Loader.hide();
              errorAlert(context, e.message.toString());
            }
          }
        },
        child: Text(
          'LOGIN',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );

    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top,
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    height: 220,
                    width: 220,
                    child: Image(
                      image:
                      AssetImage('assets/images/yo_berries_logo_fb-r.png'),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  emailField,
                  SizedBox(
                    height: 20,
                  ),
                  passwordField,
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot your password ? ",
                        style: TextStyle(fontSize: 15.0, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Forgot_Password()),
                          );
                        },
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  loginButton,
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 15.0, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUp_Page()),
                          );
                        },
                        child: Text(
                          'Signup',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.0,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}