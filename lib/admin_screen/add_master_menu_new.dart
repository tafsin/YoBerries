import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';

class Add_To_Master_Menu_New extends StatefulWidget {
  const Add_To_Master_Menu_New({Key? key}) : super(key: key);

  @override
  State<Add_To_Master_Menu_New> createState() => _Add_To_Master_Menu_NewState();
}

class _Add_To_Master_Menu_NewState extends State<Add_To_Master_Menu_New> {
  TextEditingController itemNameController = TextEditingController();

  //TextEditingController itemCategoryController = TextEditingController();
  TextEditingController sizePrice = TextEditingController();
  TextEditingController sizeValue = TextEditingController();
  TextEditingController singleSizePrice = TextEditingController();

  //List <String> size = [];
  List<int> price = [];
  String itemCategoryName = "";
  bool isMultiple = false;
  bool isSingleSize = false;
  int indexNum = 0;
  String? value;
  String? sizeV;
  List<String> itemCategory = [];
  Map<String, dynamic> itc = {};
  List<String> countryList = [];
  Map<String, dynamic> countryMap = {};
  String? countryValue;
  String country = '';

  late Future<dynamic> _future;

  void initState() {
    super.initState();

    _future = getItemCat();
    //getSize();
  }

  getItemCat() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('itemCategory')
        .get()
        .then((value) => {itc.addAll(value['itemCategory'])});
    // itc.forEach((key, value) {
    itemCategory.addAll(itc.keys);
    // });
    print('Item Cat List $itemCategory');

    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryMap.addAll(value['currency']);
      countryList.addAll(countryMap.keys);
    });
  }

  // List <dynamic> sizeList =[];
  // getSize()async{
  //   print('clicked');
  //   final s = await FirebaseFirestore.instance.collection('master').doc('size').get();
  //
  //   // sizeList = s['size'];
  //   print(sizeList);
  //   // sizell = convertSize(sizeList);
  // }

  createItem(
      String item_name, String item_category, String itemCategoryImage) async {
    await FirebaseFirestore.instance.collection('master_menu').doc().set({
      'item_name': item_name,
      'item_category': item_category,
      'isDeleted': false,
      'itemCategoryImage': itemCategoryImage,
      'itemImage': itemImageUrl
    });
  }

  File? pickedItemCategoryImage;

  Future pickedItemCategoryImageGallery() async {
    print('pickedItemCategoryImageGallery');
    // final picker = ImagePicker();
    // final pickedImage =
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 10);
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

  bool pickedItemImageBool = false;
  File? _pickedItemImage;

  void _pickedItemImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 10,
      maxHeight: 480,
      maxWidth: 640,
    );
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      pickedItemImageBool = true;

      _pickedItemImage = pickedImageFile;
    });
    // Navigator.pop(context);
  }

  String itemCategoryImageUrl = '';
  String itemImageUrl = '';

  _saveItemImage() async {
    print('save item Image ');
    try {
      Loader.show(context);
      final ref = FirebaseStorage.instance
          .ref()
          .child('itemImage')
          .child(itemNameController.text + '.jpg');
      await ref.putFile(_pickedItemImage!);
      itemImageUrl = await ref.getDownloadURL();
      print(itemImageUrl);

      Loader.hide();
    } catch (e) {
      Loader.show(context);
      print(e);
      Loader.hide();
    }
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
      title: Text("Item added successfully"),
      content: Text("You have added a new item to master menu"),
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
    final itemName = TextFormField(
      autofocus: false,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: itemNameController,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        itemNameController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        // prefixIcon: Icon(
        //   Icons.mail,
        //   color: Colors.purple,
        // ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Item Name',
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
        title: Text('Create a new Item'),
      ),
      body: FutureBuilder<dynamic>(
          future: _future,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 55,
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          //errorStyle: TextStyle(fontSize: 0),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.purple, width: 1.5),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: value,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.lightGreen),
                          hint: Text(
                            'Select a Item Category',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.black54
                                    // fontWeight: FontWeight.bold,
                                    ),
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            errorStyle: TextStyle(fontSize: 0),
                          ),
                          items: itemCategory.map(buildMenuItem).toList(),
                          onChanged: (value) => {
                            setState(() {
                              this.value = value;
                              itemCategoryName = value!;
                              //leaveType = value;
                              //checkleaveType();
                            }),
                          },
                          validator: (value) => value == null ? '' : null,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 55,
                        //margin: EdgeInsets.all(8.0),
                        // margin: EdgeInsets.fromLTRB(5, 4, 5, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          //errorStyle: TextStyle(fontSize: 0),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.purple, width: 1.5),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: countryValue,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.lightGreen),
                          hint: Text(
                            'Select Country',
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.black54
                                    // fontWeight: FontWeight.bold,
                                    ),
                          ),
                          decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 0),
                              border: InputBorder.none),
                          items: countryList.map(buildCountry).toList(),
                          onChanged: (value) => {
                            setState(() {
                              this.countryValue = value;
                              country = value!;
                              //leaveType = value;
                              //checkleaveType();
                            }),
                          },
                          validator: (value) => value == null ? '' : null,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 60,
                        child: itemName,
                      ),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.purple),
                          onPressed: () {
                            _pickedItemImageGallery();
                          },
                          child: Text('Picked Item Image')),
                      Container(
                        height: pickedItemImageBool == true ? 150 : 0,
                        child: _pickedItemImage != null
                            ? Image.file(
                                _pickedItemImage!,
                                width: 120,
                                height: 120,
                              )
                            : Container(
                                height: 0,
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.purple),
                          onPressed: () async {
                            print(itc[itemCategoryName]);
                            itemCategoryImageUrl = itc[itemCategoryName];

                            await _saveItemImage();

                            await createItem(itemNameController.text,
                                itemCategoryName, itemCategoryImageUrl);

                            showAlertDialog(context);
                            // itemNameController.clear();
                          },
                          child: Text('Submit')),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );

  DropdownMenuItem<String> buildCountry(dynamic item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      );
}
