import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:yo_berry_2/screens/recharge_wallet.dart';

class User_QR_Payment_New extends StatefulWidget {
  // const User_QR_Payment_New({Key? key}) : super(key: key);
  final String? country;

  const User_QR_Payment_New(this.country);

  @override
  State<User_QR_Payment_New> createState() => _User_QR_Payment_NewState();
}

class _User_QR_Payment_NewState extends State<User_QR_Payment_New> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late String currentBalance;
  String paymentAmount = "0";
  bool qrGenerated = false;
  Map<String, dynamic> countryCurrency = {};
  String currency = '';

  Future getData() async {
    print('data');
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) {
      currentBalance = value['balance'].toString();
    });
    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryCurrency = value['currency'];
      currency = countryCurrency[widget.country];
    });
    print('current b $currentBalance');
    return currentBalance;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  getCurrency() async {
    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryCurrency = value['currency'];
      currency = countryCurrency[widget.country];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
        backgroundColor: Colors.purple,
        title: Center(child: Text('QR Payments')),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                      ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Center(
                          child: QrImage(
                            //data: "$paymentAmount*${_auth.currentUser?.uid}",
                            data: "${_auth.currentUser?.uid}",
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add your onPressed code here!
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Recharge_Wallet(currency)));
        },
        backgroundColor: Colors.lightGreen,
        label: Text('Recharge'),
      ),
    );
  }
}
