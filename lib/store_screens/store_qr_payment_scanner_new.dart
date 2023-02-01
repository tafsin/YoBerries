import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../payment_credentials.dart';
import '../widgets.dart';

class Store_Payment_Scanner_New extends StatefulWidget {
  const Store_Payment_Scanner_New({Key? key}) : super(key: key);

  @override
  State<Store_Payment_Scanner_New> createState() =>
      _Store_Payment_Scanner_NewState();
}

class _Store_Payment_Scanner_NewState extends State<Store_Payment_Scanner_New> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController inputAmount = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool qrScanned = false;

  //String amount = "";
  String customerUid = "";

  // Future getData() async {
  //   // await _db.collection('payment').doc(transactionIdGenerator()).set({
  //   //   "paymentMethod": "qr",
  //   //   "dateTime": DateTime.now(),
  //   //   "amount": amount,
  //   //   "customerId": customerUid,
  //   //   "storeId": _auth.currentUser?.uid
  //   // });
  //   return amount;
  // }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        //amount = scanData.code!.split('*').first;
        customerUid = scanData.code!;
        qrScanned = true;
      });
      print('reselt $result');
      print('customer uid $customerUid');
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void initState() {
    controller?.resumeCamera();
    // TODO: implement initState
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    Loader.hide();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeAmountInput = TextFormField(
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
        title: Text('QR Payments'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 80,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: storeAmountInput,
                ),
              ),
              Expanded(flex: 4, child: _buildQrView(context)),
              (inputAmount.text.length > 1 && qrScanned ==true)
                  ? TextButton(
                      onPressed: () async {
                        if (inputAmount.text.length > 1) {
                          print(inputAmount.text);

                          Loader.show(context);
                          await _db
                              .collection('users')
                              .doc(customerUid)
                              .get()
                              .then((value) async {
                            if (double.parse(value['balance'].toString()) >
                                double.parse(inputAmount.text)) {
                              print('sufficient Balance');
                              await _db.collection('payments').add({
                                "amount": inputAmount.text,
                                "customer_id": customerUid,
                                "store_id": _auth.currentUser?.uid,
                                "transaction_id": transactionIdGenerator(),
                                "transaction_time": DateTime.now(),
                              }).then((a) async {
                                await _db
                                    .collection('users')
                                    .doc(customerUid)
                                    .update({
                                  "balance": value['balance'] -
                                      double.parse(inputAmount.text),
                                  'reward_point': value['reward_point'] +
                                      ((double.parse(inputAmount.text)) / 100)
                                          .toInt()
                                }).then((value) {
                                  Loader.hide();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  errorAlert(context, 'Payment Successful');
                                });
                              });
                            } else {
                              Loader.hide();
                              errorAlert(context, 'Insufficient Balance');
                            }
                          });
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          padding: EdgeInsets.all(15),
                          color: Colors.greenAccent,
                          child: Center(
                              child: Text('Proceed Payment',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)))),
                    )
                  : TextButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                      },
                      child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          padding: EdgeInsets.all(15),
                          color: Colors.redAccent,
                          child: Center(
                              child: Text('Scan',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)))),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
