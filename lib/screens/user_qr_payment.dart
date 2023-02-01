import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserQrPayment extends StatefulWidget {
  const UserQrPayment({Key? key}) : super(key: key);

  @override
  State<UserQrPayment> createState() => _UserQrPaymentState();
}

class _UserQrPaymentState extends State<UserQrPayment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late String currentBalance;
  String paymentAmount = "0";
  bool qrGenerated = false;

  Future getData() async {
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) {
      currentBalance = value['balance'].toString();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('QR Payments'),
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
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Current Balance: ',
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Ubuntu",
                                ),
                              ),
                              TextSpan(
                                text: ' $currentBalance',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Ubuntu",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        child: TextFormField(
                          style: TextStyle(height: 2),
                          decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.black54,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                              ),
                              hintText: 'Enter Amount To Pay',
                              hintStyle: TextStyle(color: Colors.black54),
                              errorStyle: TextStyle(fontSize: 15)),
                          validator: (value) {
                            if (value?.length == 0) {
                              return "Field Cannot be Empty";
                            }
                            if (!RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$')
                                .hasMatch(value!)) {
                              return "Enter Valid Amount";
                            }
                            if (double.parse(value) >
                                double.parse(currentBalance)) {
                              return "Insufficient Balance";
                            }
                            return null;
                          },
                          onChanged: (String value) {
                            paymentAmount =
                                double.parse(value).toStringAsFixed(2);
                          },
                        ),
                      ),
                      ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.purple),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() == true) {
                              setState(() {
                                qrGenerated = true;
                              });
                            }
                          },
                          child: Text('Generate QR')),
                      SizedBox(
                        height: 50,
                      ),
                      qrGenerated
                          ? QrImage(
                              data: "$paymentAmount*${_auth.currentUser?.uid}",
                              version: QrVersions.auto,
                              size: 200.0,
                            )
                          : Container(),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
