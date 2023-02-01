import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Upload_Promotion_Image extends StatefulWidget {
  final String country;

  const Upload_Promotion_Image(this.country);

  @override
  State<Upload_Promotion_Image> createState() => _Upload_Promotion_ImageState();
}

class _Upload_Promotion_ImageState extends State<Upload_Promotion_Image> {
  TextEditingController promotionExpiryDate = TextEditingController();
  late DateTime expiryDate;

  File? pickedItemCategoryImage;
  final _formKey = GlobalKey<FormState>();
  bool pickedImage = false;
  bool datePick = false;
  String fileName = '';

  void _pickedItemCategoryImage() async {
    final picker = ImagePicker();
    final pickedImg =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 10);
    final pickedImageFile = File(pickedImg!.path);

    setState(() {
      pickedItemCategoryImage = pickedImageFile;
      fileName = pickedImg.path.split('/').last;
      pickedImage = true;
    });
    print(fileName);
  }

  String promoImageUrl = '';

  _saveItemCategoryImage() async {
    print('save Image category');
    try {
      Loader.show(context);
      final ref = FirebaseStorage.instance
          .ref()
          .child('promotionImage')
          .child('$fileName' + '.jpg');
      await ref.putFile(pickedItemCategoryImage!);
      promoImageUrl = await ref.getDownloadURL();
      print(promoImageUrl);
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

  createPromotion(
    String url,
  ) async {
    if (_formKey.currentState!.validate()) {
      Loader.show(context);
      await FirebaseFirestore.instance
          .collection('promotion_image')
          .doc(widget.country)
          .collection('promo_img')
          .add({
        'img': url,
        'isActive': true,
        'promotionExpiryDate': promotionExpiryDate.text,
        'expiryDate': expiryDate
      });
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
      title: Text("Upload Successful"),
      content: Text("New promotion upload complete"),
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
      style: ElevatedButton.styleFrom(primary: Colors.purple),
      child: Text("OK"),
      onPressed: () async {
        Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Upload Failed!"),
      content: Text("Please select a image."),
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
          title: Text('Upload Promotion Image'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 80,
                      child: Container(
                        height: 70,
                        //height: 110,
                        child: TextFormField(
                          controller: promotionExpiryDate,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: Colors.purple[200],
                            ),
                            labelText: "Pick a promo code expiry date",
                            labelStyle: TextStyle(color: Colors.black54),
                            errorStyle: TextStyle(fontSize: 0),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 2.0, color: Colors.purple),
                                borderRadius: BorderRadius.circular(10)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2101));
                            if (pickedDate != null) {
                              print(pickedDate);
                              String formattedDate =
                                  DateFormat('dd-MM-yy').format(pickedDate);
                              print(formattedDate);
                              setState(() {
                                promotionExpiryDate.text = formattedDate;
                                expiryDate = pickedDate;
                                datePick = true;
                              });
                            } else {
                              setState(() {
                                promotionExpiryDate.text =
                                    'select a date please!';
                              });
                              print('date is not selected');
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
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
                      height: 10,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.purple),
                            onPressed: () {
                              _pickedItemCategoryImage();
                            },
                            child: Text('Pick a New Promotion Image')),
                        SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary:
                                    (pickedImage == true && datePick == true)
                                        ? Colors.purple
                                        : Colors.grey),
                            onPressed: () async {
                              if (pickedImage == true) {
                                await _saveItemCategoryImage();
                                await createPromotion(promoImageUrl);
                                showAlertDialog(context);
                              } else {
                                showAlertDialogNull(context);
                              }
                            },
                            child: Text('Upload Promotion')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
