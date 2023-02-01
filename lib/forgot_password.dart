import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import 'widgets.dart';

//import '../helper/customFunction.dart';

class Forgot_Password extends StatefulWidget {
  const Forgot_Password({Key? key}) : super(key: key);

  @override
  _Forgot_PasswordState createState() => _Forgot_PasswordState();
}

class _Forgot_PasswordState extends State<Forgot_Password> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    Loader.hide();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
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
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.0),
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
    final resetButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.purple,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            Loader.show(context);
            try {
              print(emailController.text);
              await _auth
                  .sendPasswordResetEmail(email: emailController.text)
                  .then((value) {
                print('Forget');
                Navigator.pop(context);
                errorAlert(context, 'Check email for password rest link');
              });
            } catch (e) {
              print(e);
              errorAlert(context, e.toString());
            }
          }
          Loader.hide();
        },
        child: Text(
          'Reset Password',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
    return Scaffold(
      //backgroundColor: Color(0xff0a0e21),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Forgot Password ?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    emailField,
                    SizedBox(
                      height: 20.0,
                    ),
                    resetButton,
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
