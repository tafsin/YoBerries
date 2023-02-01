import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Create_Promo_Code extends StatefulWidget {
  const Create_Promo_Code({Key? key}) : super(key: key);

  @override
  State<Create_Promo_Code> createState() => _Create_Promo_CodeState();
}

class _Create_Promo_CodeState extends State<Create_Promo_Code> {
  TextEditingController promoCode = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  TextEditingController minimumPurchaseController = TextEditingController();
  TextEditingController promoCodeQuantity = TextEditingController();
  TextEditingController promoExpiryDate = TextEditingController();

  late DateTime expiryDate;

  final _formKey = GlobalKey<FormState>();
  List<dynamic> countryList = [];

  late Future futureCountry;
  String? countryValue;
  String country = '';
  int initialIndex = 0;
  List<String> options = ['fixed percentage', 'fixed amount'];
  late String selectedOption = options[0];

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
  }

  createPromoCode(String country, String selectedOption) async {
    if (_formKey.currentState!.validate()) {
      Loader.show(context);
      await FirebaseFirestore.instance
          .collection('promo')
          .doc(country)
          .collection('promo_codes')
          .add({
        'code': promoCode.text,
        'promoExpiryDate': promoExpiryDate.text,
        'expiryDate': expiryDate,
        'discount': int.parse(discountAmount.text),
        'minimumPurchase': int.parse(minimumPurchaseController.text),
        'quantity': int.parse(promoCodeQuantity.text),
        'country': country,
        'selectedOption': selectedOption,
        'isActive': true
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
      title: Text("Promo Code Created Successfully"),
      content: Text("You have created a new promo code"),
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
    final code = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: promoCode,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        promoCode.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.qr_code_sharp,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter promo code',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final discount = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: discountAmount,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        discountAmount.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.money,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter discount amount',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final minimumPurchase = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: minimumPurchaseController,
      // keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        minimumPurchaseController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.monetization_on,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter minimum purchase amount',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final quantity = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: promoCodeQuantity,
      // keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        promoCodeQuantity.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          //Icons,
          Icons.confirmation_num,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter promo code quantity',
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
        title: Text("Create a New Promo Code"),
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
                            Container(
                              height: 55,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                //errorStyle: TextStyle(fontSize: 0),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                    color: Colors.purple, width: 1.5),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: countryValue,
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.lightGreen),
                                hint: Text(
                                  'Select Store Country',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.black54
                                      // fontWeight: FontWeight.bold,
                                      ),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  errorStyle: TextStyle(fontSize: 0),
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
                            ToggleSwitch(
                              minWidth: 250.0,
                              initialLabelIndex: initialIndex,
                              cornerRadius: 20.0,
                              activeFgColor: Colors.white,
                              inactiveBgColor: Colors.grey,
                              inactiveFgColor: Colors.white,
                              totalSwitches: 2,
                              labels: options,
                              activeBgColor: [Colors.purple],

                              // activeBgColors: [[Colors.red],[Colors.purple]],
                              onToggle: (index) {
                                print(options[index!]);

                                setState(() {
                                  selectedOption = options[index];
                                  initialIndex = index;
                                });
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 80,
                              child: code,
                            ),
                            SizedBox(
                              height: 80,
                              child: discount,
                            ),
                            SizedBox(
                              height: 80,
                              child: minimumPurchase,
                            ),
                            SizedBox(
                              height: 80,
                              child: quantity,
                            ),
                            SizedBox(
                              height: 80,
                              child: Container(
                                height: 70,
                                //height: 110,
                                child: TextFormField(
                                  controller: promoExpiryDate,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_month,
                                      color: Colors.purple[200],
                                    ),
                                    labelText: "Pick a promo code expiry date",
                                    labelStyle:
                                        TextStyle(color: Colors.black54),
                                    errorStyle: TextStyle(fontSize: 0),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0, color: Colors.purple),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
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
                                          DateFormat('dd-MM-yy')
                                              .format(pickedDate);
                                      print(formattedDate);
                                      setState(() {
                                        promoExpiryDate.text = formattedDate;
                                        expiryDate = pickedDate;
                                      });
                                    } else {
                                      setState(() {
                                        promoExpiryDate.text =
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
                              height: 10,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.purple,
                                    minimumSize: Size(100, 35)),
                                onPressed: () async {
                                  print(selectedOption);

                                  await createPromoCode(
                                      country, selectedOption);
                                  promoCode.clear();
                                  promoExpiryDate.clear();
                                  minimumPurchaseController.clear();
                                  promoCodeQuantity.clear();
                                  discountAmount.clear();
                                  setState(() {
                                    countryValue = null;
                                  });

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
