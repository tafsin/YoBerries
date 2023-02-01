import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

class Create_Item_Size extends StatefulWidget {
  const Create_Item_Size({Key? key}) : super(key: key);

  @override
  State<Create_Item_Size> createState() => _Create_Item_SizeState();
}

class _Create_Item_SizeState extends State<Create_Item_Size> {
  var size = [];
  final _formKey = GlobalKey<FormState>();

  getExistingSizes() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('size')
        .get()
        .then((value) => {size = value['size']});
  }

  // void initState()  {
  //   super.initState();
  //   getExistingSizes();
  //
  // }
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  TextEditingController newSize = TextEditingController();

  addNewSize(String s) async {
    await FirebaseFirestore.instance.collection('master').doc('size').update({
      'size': FieldValue.arrayUnion([s])
    });
    setState(() {});
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
      title: Text("Item Size Added Successfully"),
      content: Text("You have added a new size of items"),
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
        title: Text('Add New Size'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Text(
                      'Existing sizes',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.lightGreen,
                          fontWeight: FontWeight.bold),
                    ))),
            FutureBuilder(
                future: getExistingSizes(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 8, bottom: 8, right: 15),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: size.length,
                        itemBuilder: (BuildContext context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                                height: 30,
                                color: Colors.grey,
                                child: Center(
                                    child: Text(
                                  size[index],
                                  style: TextStyle(
                                      color: Colors.purple,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ))),
                          );
                        }),
                  );
                }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autofocus: false,

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      controller: newSize,
                      // keyboardType: TextInputType.emailAddress,
                      onSaved: (value) {
                        newSize.text = value!;
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        // prefixIcon: Icon(
                        //   Icons.phone,
                        //   color: Colors.purple,
                        // ),
                        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                        hintText: 'Enter New Size',
                        hintStyle: TextStyle(color: Colors.black54),
                        enabledBorder: const OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderSide: const BorderSide(
                              color: Colors.purple, width: 1.5),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.purple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            minimumSize: Size(120, 35)
                            //minimumSize: (100.0,40)
                            ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            addNewSize(newSize.text);
                            showAlertDialog(context);
                          }
                        },
                        child: Text('Add New Size'))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
