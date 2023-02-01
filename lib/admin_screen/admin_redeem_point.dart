import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:yo_berry_2/admin_screen/remove_redeeem_reward.dart';

class Admin_Redeem_Point extends StatefulWidget {
  const Admin_Redeem_Point({Key? key}) : super(key: key);

  @override
  State<Admin_Redeem_Point> createState() => _Admin_Redeem_PointState();
}

class _Admin_Redeem_PointState extends State<Admin_Redeem_Point> {
  TextEditingController point = TextEditingController();
  TextEditingController amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<dynamic> countryList = [];

  late Future futureCountry;
  String? countryValue;
  String country = '';

  @override
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

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  createRewardRedeem(String point, String amount, String country) async {
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('reward_redeem')
        .doc(country)
        .collection('point_redeem')
        .add({'point': int.parse(point), 'amount': int.parse(amount)});
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPoint = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: point,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        point.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.stars,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Point',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
    final selectedAmount = TextFormField(
      autofocus: false,
      style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: amount,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        amount.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.money,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: 'Enter Amount',
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
        title: Text('Redeem Point System'),
      ),
      body: FutureBuilder<dynamic>(
          future: futureCountry,
          builder: (context, stream) {
            return Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 55,
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: Colors.purple, width: 1.5),
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
                          selectedPoint,
                          SizedBox(
                            height: 10,
                          ),
                          selectedAmount,
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.purple),
                              onPressed: () async {
                                await createRewardRedeem(
                                    point.text, amount.text, country);
                                point.clear();
                                amount.clear();
                              },
                              child: Text('Submit'))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red[800],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Remove_Redeem_Reward(countryList)),
          );
        },
        label: Text(
          "Remove",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
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
