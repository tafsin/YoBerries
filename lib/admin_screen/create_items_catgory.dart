import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';

class Create_Items_Category extends StatefulWidget {
  const Create_Items_Category({Key? key}) : super(key: key);

  @override
  State<Create_Items_Category> createState() => _Create_Items_CategoryState();
}

class _Create_Items_CategoryState extends State<Create_Items_Category> {
  TextEditingController itemCategoryController = TextEditingController();
  File? pickedItemCategoryImage;
  List<String> itemCategoryList = [];
  Map<String, dynamic> itc = {};

  @override
  void initState() {
    super.initState();
    getItemCatList();
  }

  Future pickedItemCategoryImageGallery() async {
    print('pickedItemCategoryImageGallery');

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    print('image $image');
    if (image == null) return;
    final pickedImageFile = File(image.path);
    print('pickedImageFile $pickedImageFile');
    setState(() {
      pickedItemCategoryImage = pickedImageFile;
    });
    print(pickedItemCategoryImage);
    //Navigator.pop(context);
  }

  bool pickedImage = false;
  final _formKey = GlobalKey<FormState>();

  getItemCatList() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('itemCategory')
        .get()
        .then((value) => {itc.addAll(value['itemCategory'])});
    // itc.forEach((key, value) {
    itemCategoryList.addAll(itc.keys);
    // });
    print('Item Cat List $itemCategoryList');
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
      title: Text("Item Category Created Successfully"),
      content: Text("You have created a new item category"),
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

  showAlreadyExistsAlertDialog(BuildContext context) {
    // Create button
    Widget okButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Sorry!"),
      content: Text("Item Category Already Exists"),
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

  void _pickedItemCategoryImage() async {
    final picker = ImagePicker();
    final pickedIamge =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedIamge!.path);

    //_imageFileList!.add(pickedImageFile);
    //print(_imageFileList!.length);

    setState(() {
      pickedItemCategoryImage = pickedImageFile;
      pickedImage = true;
    });
    // Navigator.pop(context);
  }

  String itemCategoryImageUrl = '';

  _saveItemCategoryImage() async {
    print('save Image category');
    try {
      Loader.show(context);
      final ref = FirebaseStorage.instance
          .ref()
          .child('itemCategoryImage')
          .child(itemCategoryController.text + '.jpg');
      await ref.putFile(pickedItemCategoryImage!);
      itemCategoryImageUrl = await ref.getDownloadURL();
      print(itemCategoryImageUrl);
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(uid)
      //     .update({'imageUrl': url});

      Loader.hide();
    } catch (e) {
      Loader.show(context);
      print(e);
      Loader.hide();
    }
  }

  createItemCategory(String itemCat, String itemCategoryImageU) async {
    print(itemCat);
    print(itemCategoryImageU);
    Map<String, dynamic> itemCatgoryWithImage = {};

    itemCatgoryWithImage.addAll({itemCat: itemCategoryImageU});
    print(itemCatgoryWithImage);

    await FirebaseFirestore.instance
        .collection('master')
        .doc('itemCategory')
        .update({"itemCategory.$itemCat": "$itemCategoryImageUrl"});
  }

  @override
  Widget build(BuildContext context) {
    final itemCategory = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: itemCategoryController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        itemCategoryController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        // prefixIcon: Icon(
        //   Icons.mail,
        //   color: Colors.purple,
        // ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Item Category ',
        hintStyle: TextStyle(color: Colors.grey),
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
          title: Text('Create Item Category'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.purple),
                        onPressed: () {
                          _pickedItemCategoryImage();
                        },
                        child: Text('Picked Item Category Image')),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      height: pickedImage == true ? 150 : 0,
                      child: pickedItemCategoryImage != null
                          ? Image.file(
                              pickedItemCategoryImage!,
                              width: 120,
                              height: 120,
                            )
                          : Text('aasa'),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    itemCategory,
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.purple),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            if (itemCategoryList
                                .contains(itemCategoryController.text)) {
                              showAlreadyExistsAlertDialog(context);
                            } else {
                              await _saveItemCategoryImage();
                              await createItemCategory(
                                  itemCategoryController.text,
                                  itemCategoryImageUrl);
                              showAlertDialog(context);
                            }
                          }
                        },
                        child: Text('create item category'))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
