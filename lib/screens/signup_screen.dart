import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/widgets.dart';

import '../user_model.dart';

class SignUp_Page extends StatefulWidget {
  const SignUp_Page({Key? key}) : super(key: key);

  @override
  _SignUp_PageState createState() => _SignUp_PageState();
}

class _SignUp_PageState extends State<SignUp_Page> {
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final phoneNumberController = TextEditingController();

  // final addressController = TextEditingController();
  final passwordEditingController = TextEditingController();

  // final confirmPasswordEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool hidePassword = true;
  String? role = 'customer';
  List<String> countryCode = [];
  Map<String, dynamic> countryCodeMap = {};
  String? value;
  String countryCodeNum = '';
  String country = '';
  late Future futureCountry;

  void initState() {
    super.initState();
    futureCountry = getCountryCode();
  }

  getCountryCode() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('country')
        .get()
        .then((value) {
      countryCodeMap.addAll(value['country']);
      countryCode.addAll(countryCodeMap.keys);
    });
    print(countryCode);
  }

  postDetailsToUsers(String email, String role, String name, String phoneNumber,
      String country) async {
    print('postUsers');
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.email = email;
    userModel.uid = user!.uid;
    userModel.role = role;
    userModel.name = name;
    userModel.phoneNumber = phoneNumber;
    userModel.country = country;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());
    //await FirebaseMessaging.instance.subscribeToTopic("$country");

    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
  }

  @override
  void dispose() {
    Loader.hide();
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    final nameField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        // style: TextStyle(color: Colors.purple),
        autofocus: false,
        controller: nameEditingController,

        onSaved: (value) {
          nameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Colors.purple[200],
            ),
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: 'Enter Your Name',
            hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
            filled: true,
            fillColor: Colors.purple.shade50,
            enabledBorder: InputBorder.none,
            border: InputBorder.none),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your name';
          }
          if (!RegExp("[a-zA-Z]").hasMatch(value)) {
            return 'Invalid Name';
          }
          return null;
        },
      ),
    );
    final emailField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        //  style: TextStyle(color: Colors.purple),
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.mail,
              color: Colors.purple[200],
            ),
            contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: 'Enter Your Email',
            hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
            enabledBorder: InputBorder.none,
            fillColor: Colors.purple.shade50,
            filled: true,
            border: InputBorder.none),
        validator: (value) {
          if (value!.length == 0) {
            return "Email cannot be empty";
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Invalid Email");
          } else {
            return null;
          }
        },
      ),
    );
    final phoneNumberField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
          autofocus: false,
          controller: phoneNumberController,
          onSaved: (value) {
            phoneNumberController.text = value!;
          },
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.add_ic_call_rounded,
                color: Colors.purple[200],
              ),
              contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              hintText: 'Enter Your Phone Number',
              hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
              enabledBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.purple.shade50,
              border: InputBorder.none),
          validator: (value) {
            if (countryCodeNum == '+88') {
              if (value!.length < 11 || value.isEmpty || value.length > 11) {
                return 'Invalid phone number';
              }
              if (countryCodeNum == '+01') {
                if (value.length < 11 || value.isEmpty || value.length > 11) {
                  return 'Invalid phone number';
                }
              }

              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                return 'Invalid phone number';
              }
              return null;
            }
          }),
    );

    final passwordField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
      child: TextFormField(
        //style: TextStyle(color: Colors.purple),
        autofocus: false,
        obscureText: hidePassword,
        controller: passwordEditingController,
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.vpn_key,
              color: Colors.purple[200],
            ),
            suffixIcon: hidePassword
                ? IconButton(
                    icon: Icon(Icons.visibility, color: Colors.black54),
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
            hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
            enabledBorder: InputBorder.none,
            fillColor: Colors.purple.shade50,
            border: InputBorder.none,
            filled: true),
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return "Password cannot be empty";
          }
          if (!regex.hasMatch(value)) {
            return ("please enter valid password min. 6 character");
          } else {
            return null;
          }
        },
      ),
    );

    final signupButton = Material(
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
              final newUser = await _auth
                  .createUserWithEmailAndPassword(
                      email: emailEditingController.text,
                      password: passwordEditingController.text)
                  .then((value) {
                country = countryCodeMap[countryCodeNum];
                postDetailsToUsers(
                    emailEditingController.text,
                    role!,
                    nameEditingController.text,
                    phoneNumberController.text,
                    country);
                print('ok');
                Loader.hide();
              });
              //     .then((value) async {
              //   await FirebaseFirestore.instance.collection('user').doc('').set({
              //     'name': nameEditingController.text,
              //     'role': role,
              //   }).then((value) => print('success'));
              // });

            } on FirebaseAuthException catch (e) {
              Loader.hide();
              errorAlert(context, e.message.toString());
            }
          }
        },
        child: Text(
          'SignUp',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
    return Scaffold(
      body: FutureBuilder<dynamic>(
          future: futureCountry,
          builder: (context, stream) {
            return ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).padding.top,
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.purple,
                              size: 40,
                            )),
                        Expanded(
                          child: Center(
                            child: Text(
                              "SignUp with Email",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple),
                            ),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20.0,
                              ),
                              nameField,
                              SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: DropdownButtonFormField<String>(
                                      value: value,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Colors.lightGreen),
                                      hint: Text(
                                        'Country',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      decoration: InputDecoration(
                                        fillColor: Colors.purple.shade50,
                                        filled: true,
                                        enabledBorder: InputBorder.none,
                                        border: InputBorder.none,
                                        errorStyle: TextStyle(fontSize: 0),
                                      ),
                                      items: countryCode
                                          .map(buildCountry)
                                          .toList(),
                                      onChanged: (value) => {
                                        setState(() {
                                          this.value = value;
                                          countryCodeNum = value!;
                                          //leaveType = value;
                                          //checkleaveType();
                                        }),
                                      },
                                      validator: (value) =>
                                          value == null ? '' : null,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(child: phoneNumberField),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              emailField,
                              SizedBox(
                                height: 20.0,
                              ),
                              passwordField,
                              SizedBox(
                                height: 20.0,
                              ),
                              signupButton,
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          }),
    );
  }

  DropdownMenuItem<String> buildCountry(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}
