import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yo_berry_2/change_email.dart';
import 'package:yo_berry_2/change_password.dart';

class Customer_Settings extends StatefulWidget {
  const Customer_Settings({Key? key}) : super(key: key);

  @override
  State<Customer_Settings> createState() => _Customer_SettingsState();
}

class _Customer_SettingsState extends State<Customer_Settings> {
  File? _pickedImage;
  String? userEmail = '';
  String url = "";
  String uid = '';

  void initState() {
    super.initState();

    currentUsr();
  }

  void dispose() {
    Loader.hide();
    super.dispose();
  }

  void currentUsr() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
    }
  }

  void _pickedImageCamera() async {
    final picker = ImagePicker();
    final pickedIamge =
        await picker.getImage(source: ImageSource.camera, imageQuality: 10);
    final pickedImageFile = File(pickedIamge!.path);

    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _pickedImageGallery() async {
    final picker = ImagePicker();
    final pickedImage =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    Navigator.pop(context);
  }

  void _remove() {
    setState(() {
      _pickedImage = null;
    });
    Navigator.pop(context);
  }

  _saveImage() async {
    try {
      Loader.show(context);
      final ref = FirebaseStorage.instance
          .ref()
          .child('usersImage')
          .child(userEmail! + '.jpg');
      await ref.putFile(_pickedImage!);
      url = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'imageUrl': url});
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('imgUrl', url);

      Loader.hide();
    } catch (e) {
      Loader.show(context);
      print(e);
      Loader.hide();
    }
  }

  showMessage() {
    if (_pickedImage != null) {
      showAlertDialog(context);
    } else {
      showAlertDialogNull(context);
    }
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Profile picture uploaded"),
      content: Text(""),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialogNull(BuildContext context) {
    // Create button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("You Did Not Select Any Picture"),
      content: Text(""),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Center(child: Text('Edit Profile')),
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   width: 50,
              // ),
              Stack(
                children: [
                  Container(
                    //color: Colors.grey,
                    margin: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.black87,
                      child: CircleAvatar(
                        //foregroundColor: Colors.white,
                        backgroundColor: Colors.grey,
                        radius: 66,

                        backgroundImage: _pickedImage == null
                            ? null
                            : FileImage(_pickedImage!),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    left: 120,
                    child: RawMaterialButton(
                      elevation: 10,
                      fillColor: Colors.purple,
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(15),
                      shape: CircleBorder(),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Choose Option'),
                                content: SingleChildScrollView(
                                  child: ListBody(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _pickedImageCamera();
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.camera),
                                            ),
                                            Text('Camera')
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _pickedImageGallery();
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.image),
                                            ),
                                            Text('Gallery')
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _remove();
                                        },
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.remove_circle),
                                            ),
                                            Text('Remove')
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.purple, // background

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () async {
                await _saveImage();
                showMessage();
                //showAlertDialog(context);
              },
              child: Text(
                "upload",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Password_Change()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.key,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Change Password',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
}
