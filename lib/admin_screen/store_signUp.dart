import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/login_screen.dart';
import 'package:yo_berry_2/store_signup_model.dart';

import '../user_model.dart';

class Store_SignUp extends StatefulWidget {
  const Store_SignUp({Key? key}) : super(key: key);

  @override
  _Store_SignUpState createState() => _Store_SignUpState();
}

class _Store_SignUpState extends State<Store_SignUp> {
  final storeIdController = TextEditingController();
  final emailEditingController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String? role = 'store';
  bool hidePassword = true;

  postDetailsToUsers(String email, String role, String storeId,
      String phoneNumber, String address) async {
    print('postUsers');
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User? user = _auth.currentUser;
      StoreSignUpModel storeSignUpModelModel = StoreSignUpModel();
      storeSignUpModelModel.email = email;
      storeSignUpModelModel.uid = user!.uid;
      storeSignUpModelModel.role = role;
      storeSignUpModelModel.storeId = storeId;
      // storeSignUpModelModel.phoneNumber = phoneNumber;
      // storeSignUpModelModel.address = address;
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(storeSignUpModelModel.toMap());

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Login_Page()),
      );
    }
  }

  @override
  void dispose() {
    Loader.hide();
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    final store_id = TextFormField(
      //style: TextStyle(color: Colors.purple),
      autofocus: false,
      controller: storeIdController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        storeIdController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Store Id',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter store id';
        }
        return null;
      },
    );
    final emailField = TextFormField(
      //style: TextStyle(color: Colors.purple),
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
        hintText: 'Enter Store Email',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value!.length == 0) {
          return "Email cannot be empty";
        }
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)) {
          return ("Please enter a valid email");
        } else {
          return null;
        }
      },
    );

    final passwordField = TextFormField(
      style: TextStyle(color: Colors.purple),
      autofocus: false,
      obscureText: true,
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
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
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
              await _auth
                  .createUserWithEmailAndPassword(
                      email: emailEditingController.text,
                      password: passwordEditingController.text)
                  .then((value) {
                postDetailsToUsers(
                    emailEditingController.text,
                    role!,
                    storeIdController.text,
                    phoneNumberController.text,
                    addressController.text);
                print('ok');
                Loader.hide();
              });
              //     .then((value) async {
              //   await FirebaseFirestore.instance.collection('user').doc('').set({
              //     'name': nameEditingController.text,
              //     'role': role,
              //   }).then((value) => print('success'));
              // });

            } catch (e) {
              Loader.hide();
              print(e);
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
      body: ListView(
        children: [
          Column(
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
                        "Create a Store Credential",
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        height: 80.0,
                        child: store_id,
                      ),
                      SizedBox(
                        height: 80.0,
                        child: emailField,
                      ),
                      SizedBox(
                        height: 80.0,
                        child: passwordField,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      signupButton,
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
