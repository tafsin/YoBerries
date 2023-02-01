import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../store_model.dart';
import '../store_signup_model.dart';
import '../widgets.dart';

class Create_Store extends StatefulWidget {
  const Create_Store({Key? key}) : super(key: key);

  @override
  State<Create_Store> createState() => _Create_StoreState();
}

class _Create_StoreState extends State<Create_Store> {
  TextEditingController areaNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController storePhoneNumberController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String role = 'store';
  bool hidePassword = true;
  String? countryValue;
  String country = '';
  final _formKey = GlobalKey<FormState>();
  List<dynamic> countryList = [];
  Map<String, dynamic> vatMap = {};
  late Future futureCountry;

  void initState() {
    super.initState();
    futureCountry = getCountries();
  }

  getCountries() async {
    print('called');
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryArray')
        .get()
        .then((value) {
      setState(() {
        countryList = value['countryArray'];
      });
    });
    print('country list $countryList');
    await FirebaseFirestore.instance
        .collection('master')
        .doc('vat')
        .get()
        .then((value) => {vatMap.addAll(value['vat'])});
    print('vat $vatMap');
  }

  createStore(String area, String address, String zipCode, String storePhoneNum,
      String country) async {
    print('postUsers');
    String storeId = area + zipCode;
    print('store id is $storeId');
    int vat = vatMap[country];
    print('vaaaat Num $vat');

    Loader.show(context);
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    StoreModel storeModel = StoreModel();

    storeModel.area = area;
    storeModel.address = address;
    storeModel.zipCode = zipCode;
    storeModel.storePhoneNum = storePhoneNum;
    storeModel.storeId = storeId;
    storeModel.country = country;
    storeModel.vat = vat;

    await firebaseFirestore
        .collection("store_collection")
        .doc(storeId)
        .set(storeModel.toMap());

    Loader.hide();
  }

  postDetailsToUsers(String email, String role, String area, String zipCode,
      String country, String? uid) async {
    print('postUsers');
    String storeId = area + zipCode;
    var buid = await FirebaseAuth.instance.currentUser!.uid;
    print('before $buid');

    if (_formKey.currentState!.validate()) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      StoreSignUpModel storeSignUpModelModel = StoreSignUpModel();
      storeSignUpModelModel.email = email;

      storeSignUpModelModel.role = role;
      storeSignUpModelModel.uid = uid;
      storeSignUpModelModel.storeId = storeId;
      storeSignUpModelModel.country = country;
      // storeSignUpModelModel.phoneNumber = phoneNumber;
      // storeSignUpModelModel.address = address;
      await firebaseFirestore
          .collection("users")
          .doc(uid)
          .set(storeSignUpModelModel.toMap());
    }
    var auid = await FirebaseAuth.instance.currentUser!.uid;
    print('after $auid');
  }
  Future <void >Store()async{
    FirebaseApp app = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options);
    try {
      UserCredential userCredential =
      await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
          email: emailEditingController.text,
          password: passwordEditingController.text)
          .then((value) async {
        Loader.show(context);
        print('store uid ${value.user?.uid}');
        await postDetailsToUsers(emailEditingController.text, role,
            areaNameController.text, zipCodeController.text, country, value.user?.uid);
        await createStore(areaNameController.text, addressController.text,
            zipCodeController.text, storePhoneNumberController.text, country);


        // await postDetailsToUsers(emailEditingController.text, role,
        //     areaNameController.text, zipCodeController.text, country, value.user?.uid);
        // await createStore(areaNameController.text, addressController.text,
        //     zipCodeController.text, storePhoneNumberController.text, country);

        Loader.hide();
        await app.delete();
        Navigator.pop(context);
        return errorAlert(
            context, 'Store Created');
      }).catchError((error) async {
        Loader.hide();
        await app.delete();
        return errorAlert(context, error.message);
      });
    } catch (e) {
      await app.delete();
    }

  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  showAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Store created successfully"),
      content: Text("You have created the store successfully"),
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

  Future<void> code() async {
    final AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!, password: textFieldController.text);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailEditingController.text,
          password: passwordEditingController.text);
      var uid = FirebaseAuth.instance.currentUser!.uid;
      print('current usr uid');
      await postDetailsToUsers(emailEditingController.text, role,
          areaNameController.text, zipCodeController.text, country, uid);
      await createStore(areaNameController.text, addressController.text,
          zipCodeController.text, storePhoneNumberController.text, country);
    } catch (e) {
      Loader.hide();
      print(e);
    }

    _auth.signOut().then((value) {
      _auth.signInWithCredential(credential);
    });

  }

  TextEditingController textFieldController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('TextField in Dialog'),
            content: TextFormField(
              //style: TextStyle(color: Colors.purple),
              autofocus: false,
              obscureText: true,
              controller: textFieldController,
              onSaved: (value) {
                textFieldController.text = value!;
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
                          hidePassword = !hidePassword;
                        },
                      )
                    : IconButton(
                        onPressed: () {
                          hidePassword = !hidePassword;
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
                  borderSide:
                      const BorderSide(color: Colors.purple, width: 1.5),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
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
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  await code();

                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
      obscureText: hidePassword,
      autofocus: false,
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
                  hidePassword = !hidePassword;
                },
              )
            : IconButton(
                onPressed: () {
                  hidePassword = !hidePassword;
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

    final area = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: areaNameController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        areaNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.location_on,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter store area',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final address = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: addressController,
      // keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        addressController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.house,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter store address',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final zipCode = TextFormField(
      autofocus: false,
      //  style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: zipCodeController,
      // keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        zipCodeController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          //Icons,
          Icons.house,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter store zipCode',
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final storePhoneNum = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: storePhoneNumberController,
      // keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        storePhoneNumberController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter store phone Number',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("Create a new Store"),
      ),
      body: FutureBuilder<dynamic>(
          future: futureCountry,
          builder: (context, stream) {
            return Container(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 80,
                              child: emailField,
                            ),
                            SizedBox(
                              height: 80,
                              child: passwordField,
                            ),
                            SizedBox(
                              height: 80,
                              child: area,
                            ),
                            SizedBox(
                              height: 80,
                              child: address,
                            ),
                            SizedBox(
                              height: 80,
                              child: zipCode,
                            ),
                            SizedBox(
                              height: 80,
                              child: storePhoneNum,
                            ),
                            Container(
                              height: 60,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                //errorStyle: TextStyle(fontSize: 0),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.purple, width: 1.5),
                              ),
                              child: DropdownButtonFormField<String>(
                                // decoration: InputDecoration(

                                //
                                // ),
                                value: countryValue,
                                isExpanded: true,

                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.lightGreen),
                                hint: Text(
                                  'Select Store Country',
                                  style: TextStyle(
                                      fontSize: 18.0, color: Colors.black54
                                      // fontWeight: FontWeight.bold,
                                      ),
                                ),
                                decoration: InputDecoration(
                                  // filled: true,
                                  errorStyle: TextStyle(fontSize: 0),
                                  border: InputBorder.none,
                                ),
                                items: countryList.map(buildCountry).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    this.countryValue = value;
                                    country = value!;
                                  });
                                  //leaveType = value;
                                  //checkleaveType();
                                },
                                validator: (value) => value == null ? '' : null,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    minimumSize: Size(100, 35)),
                                onPressed: () async {
                                  print('create store');
                                  if (_formKey.currentState!.validate()) {
                                    //_displayTextInputDialog(context);
                                    await Store();

                                    // areaNameController.clear();
                                    // addressController.clear();
                                    // zipCodeController.clear();
                                    // storePhoneNumberController.clear();
                                    // emailEditingController.clear();
                                    // passwordEditingController.clear();
                                    // setState(() {
                                    //   countryValue = null;
                                    // });
                                  }

                                  showAlertDialog(context);
                                },
                                child: Text('create'))
                          ],
                        )),
                  )
                ],
              ),
            );
          }),
    );
  }

  DropdownMenuItem<String> buildCountry(dynamic item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}
