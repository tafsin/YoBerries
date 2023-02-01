import 'dart:io';
import 'package:group_button/group_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Add_Items_In_Store_Menu extends StatefulWidget {
  //const Create_New_Menu_Category({Key? key}) : super(key: key);
  // final String docId;
  //
  // const Add_Items_In_Store_Menu(this.docId);

  @override
  State<Add_Items_In_Store_Menu> createState() =>
      _Add_Items_In_Store_MenuState();
}

class _Add_Items_In_Store_MenuState extends State<Add_Items_In_Store_Menu> {
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
  List<dynamic> sizeList = [];
  Map<String, dynamic> countryMap = {};
  String? countryValue;
  String country = '';

  late Future<dynamic> _future;

  void initState() {
    super.initState();

    _future = getItemCat();
    // getSize();
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

    //Load Category Master
    await FirebaseFirestore.instance
        .collection('master')
        .doc('size')
        .get()
        .then((value) {
      sizeList = value['size'];
    });
    price = [];
    sizeList.forEach((element) {
      price.add(0);
    });
    print('newPrice =  $price');
    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryMap.addAll(value['currency']);
      countryList.addAll(countryMap.keys);
    });
  }

  //   getSize()async{
  //   print('clicked');
  //   final s = await FirebaseFirestore.instance.collection('master').doc('size').get();
  //
  //    // sizeList = s['size'];
  //   print(sizeList);
  //  // sizell = convertSize(sizeList);
  // }

  createItemWithSize(String item_name, String item_category, List<dynamic> size,
      List<int> price, bool isMultiple, String itemCategoryImage) async {
    Map<String, dynamic> sizeWithPrice = {};
    for (int i = 0; i < size.length; i++) {
      sizeWithPrice.addAll({size[i]: price[i]});
    }
    print(sizeWithPrice);
    // print(itemCategoryImageUrl);
    price.sort();
    List<int> priceWithoutZero = [];
    price.forEach((element) {
      if (element > 0) {
        priceWithoutZero.add(element);
      }
    });
    print("price Without Zero $priceWithoutZero");
    int lowPrice = priceWithoutZero[0];
    print(lowPrice);
    //print(price);

    await FirebaseFirestore.instance.collection('master_menu').doc().set({
      'item_name': item_name,
      'item_category': item_category,
      'sizeWithPrice': sizeWithPrice,
      'isMultiple': isMultiple,
      'price': lowPrice,
      'isDeleted': false,
      'itemCategoryImage': itemCategoryImage,
      'itemImage': itemImageUrl
    });
  }

  createItemWithoutSize(String item_name, String item_category, List<int> price,
      isMultiple, String itemCategoryImage) async {
    //print(itemCategoryImageUrl);
    int singlePrice = 0;
    price.forEach((element) {
      if (element > 0) {
        singlePrice = element;
      }
    });
    print(singlePrice);

    await FirebaseFirestore.instance.collection('master_menu').doc().set({
      'item_name': item_name,
      'item_category': item_category,
      'price': singlePrice,
      'isMultiple': isMultiple,
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

  bool pickedItemImageBool = false;
  File? _pickedItemImage;

  void _pickedItemImageGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
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
      style: TextStyle(color: Colors.purple),
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
                        height: 80,
                        //margin: EdgeInsets.all(8.0),
                        margin: EdgeInsets.fromLTRB(5, 4, 5, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          //errorStyle: TextStyle(fontSize: 0),
                          borderRadius: BorderRadius.circular(8),
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
                            filled: true,
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
                        height: 5,
                      ),
                      Container(
                        height: 80,
                        //margin: EdgeInsets.all(8.0),
                        margin: EdgeInsets.fromLTRB(5, 4, 5, 1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          //errorStyle: TextStyle(fontSize: 0),
                          borderRadius: BorderRadius.circular(8),
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
                            filled: true,
                            errorStyle: TextStyle(fontSize: 0),
                          ),
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
                        height: 5,
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
                      SizedBox(
                        height: 80,
                        child: itemName,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                          itemCount: sizeList.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: Text('${sizeList[index].toString()}'),
                              trailing: Container(
                                width: 50,
                                child: TextFormField(
                                  decoration: InputDecoration(hintText: "TK"),
                                  onChanged: (String value) {
                                    if (value.length < 1) {
                                      value = "0";
                                    }
                                    price.removeAt(index);
                                    price.insert(index, int.parse(value));
                                  },
                                ),
                              ),
                            );
                          }),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.purple),
                          onPressed: () async {
                            //await _saveItemCategoryImage();
                            print(Image);
                            print(itc[itemCategoryName]);
                            itemCategoryImageUrl = itc[itemCategoryName];
                            int countPrice = 0;
                            price.forEach((element) {
                              if (element > 0) {
                                countPrice++;
                              }
                            });
                            if (countPrice > 1) {
                              isMultiple = true;
                            }
                            await _saveItemImage();
                            if (isMultiple == true) {
                              await createItemWithSize(
                                  itemNameController.text,
                                  itemCategoryName,
                                  sizeList,
                                  price,
                                  isMultiple,
                                  itemCategoryImageUrl);
                            }
                            if (isMultiple == false) {
                              await createItemWithoutSize(
                                  itemNameController.text,
                                  itemCategoryName,
                                  price,
                                  isMultiple,
                                  itemCategoryImageUrl);
                            }
                            showAlertDialog(context);
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
