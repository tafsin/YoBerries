import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';

import '../payment_credentials.dart';

class Recharge_Wallet extends StatefulWidget {
  final String currency;

  const Recharge_Wallet(this.currency);

  @override
  State<Recharge_Wallet> createState() => _Recharge_WalletState();
}

class _Recharge_WalletState extends State<Recharge_Wallet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  TextEditingController inputAmount = TextEditingController();

  String currentBalance = '';
  void dispose(){
    super.dispose();
    Loader.hide();
  }

  Future getData() async {
    print('data');
    await _db
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .get()
        .then((value) {
      currentBalance = value['balance'].toString();
    });
    print('current b $currentBalance');
    return currentBalance;
  }

  walletCal() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) async {
      print(value['balance']);
      print('bbbbb');

      //if (value['balance'] >= widget.total) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({'balance': value['balance'] + int.parse(inputAmount.text)});
      // await FirebaseFirestore.instance.collection('payments').add({
      //   "amount": widget.total.toString(),
      //   "customer_id": uid,
      //   "store_id": storeId,
      //   "transaction_id": transactionIdGenerator(),
      //   "transaction_time": DateTime.now(),
      // });
      // setState((){
      //   complete = true;
      // });
      //}
      // else{
      //   errorAlert(context, 'Insufficient Balance');
      //   //Navigator.pop(context);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final rechargeAmountInput = TextFormField(
      autofocus: false,
      //style: TextStyle(color: Colors.purple),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
      controller: inputAmount,
      //keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        inputAmount.text = value!;
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
        title: Text('Recharge Wallet'),
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
                        child: Center(
                          child: RichText(
                            // textAlign: TextAlign.start,
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
                                  text: widget.currency,
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
                      ),
                      SizedBox(
                        height: 80,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: rechargeAmountInput,
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
      bottomSheet: Container(
        margin: EdgeInsets.only(left: 18, bottom: 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size(350, 45)
              //minimumSize: (100.0,40)
              ),
          onPressed: () async {
            String trx = transactionIdGenerator();
            await sslCommerzCustomizedCall(double.parse(inputAmount.text), trx)
                .then((value) async {
                  Loader.show(context);
              await walletCal();
              Loader.hide();
            });
            setState(() {});
            inputAmount.clear();
          },
          child: Text('Recharge',
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    );
  }
}
