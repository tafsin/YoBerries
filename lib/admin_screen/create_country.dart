import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Create_Country extends StatefulWidget {
  const Create_Country({Key? key}) : super(key: key);

  @override
  State<Create_Country> createState() => _Create_CountryState();
}

class _Create_CountryState extends State<Create_Country> {
  TextEditingController countryNameController = TextEditingController();
  TextEditingController countryPhoneCodeController = TextEditingController();
  TextEditingController countryNameCodeController = TextEditingController();
  TextEditingController countryCurrencyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  postCountryInfo(String countryName, String countryPhoneCode,
      String countryCode, String countryCurrency) async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryArray')
        .update({
      'countryArray': FieldValue.arrayUnion([countryName])
    });
    await FirebaseFirestore.instance
        .collection('master')
        .doc('country')
        .update({"country.$countryPhoneCode": "$countryName"});
    await FirebaseFirestore.instance
        .collection('master')
        .doc('countryNameCode')
        .update({"countryNameCode.$countryName": "$countryCode"});
    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .update({"currency.$countryName": "$countryCurrency"});
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
      title: Text("Country created successfully"),
      content: Text("You have created the Country successfully"),
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
    final countryName = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: countryNameController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        countryNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.flag,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter country name',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final countryPhoneCode = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: countryPhoneCodeController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        countryPhoneCodeController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.mobile_friendly,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter country phone code',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final countryNameCode = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: countryNameCodeController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        countryNameCodeController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.flag_outlined,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter country code ',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final countryCurrency = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: countryCurrencyController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        countryCurrencyController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.money,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter country currency',
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
        title: Text('Add a New Country'),
      ),
      body: Container(
        child: Padding(
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
                  child: countryName,
                ),
                SizedBox(
                  height: 80,
                  child: countryNameCode,
                ),
                SizedBox(
                  height: 80,
                  child: countryPhoneCode,
                ),
                SizedBox(
                  height: 80,
                  child: countryCurrency,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await postCountryInfo(
                            countryNameController.text,
                            countryPhoneCodeController.text,
                            countryNameCodeController.text,
                            countryCurrencyController.text);
                        showAlertDialog(context);
                      }
                    },
                    child: Text('Create'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
