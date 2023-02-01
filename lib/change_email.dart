import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/screens/login_screen.dart';

class Email_Change extends StatefulWidget {
  const Email_Change({Key? key}) : super(key: key);

  @override
  _Email_ChangeState createState() => _Email_ChangeState();
}

class _Email_ChangeState extends State<Email_Change> {
  final emailEditingController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = '';
  String role = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentUsr();
  }

  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      //userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  changeEmail() async {
    var user = FirebaseAuth.instance.currentUser;

    await user?.updateEmail(emailEditingController.text).then((_) async {
      print("Successfully changed password");
      await updateEmail();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => Login_Page()), (route) => false);
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
      //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
  }

  updateEmail() async {
    try {
      final employeeData = await firestore.collection('users').doc(uid).get();

      if (employeeData['role'] == 'Employee') {
        await firestore
            .collection('employee_leave')
            .doc(uid)
            .update({'employeeEmail': emailEditingController.text});
      }

      await firestore
          .collection('users')
          .doc(uid)
          .update({'email': emailEditingController.text});
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    Loader.hide();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final emailField = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
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
            await changeEmail();
            Loader.hide();

          }
        },
        child: Text(
          'Change Email',
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
                    //   'Change Email',
                    //   style: TextStyle(
                    //       fontSize: 30,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.lightBlue),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    emailField,
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
