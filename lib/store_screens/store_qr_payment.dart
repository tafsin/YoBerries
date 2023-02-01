import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'dart:io';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:yo_berry_2/payment_credentials.dart';
import 'package:yo_berry_2/widgets.dart';

class StoreQrPayment extends StatefulWidget {
  const StoreQrPayment({Key? key}) : super(key: key);

  @override
  State<StoreQrPayment> createState() => _StoreQrPaymentState();
}

class _StoreQrPaymentState extends State<StoreQrPayment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool qrScanned = false;
  String amount = "";
  String customerUid = "";

  Future getData() async {
    // await _db.collection('payment').doc(transactionIdGenerator()).set({
    //   "paymentMethod": "qr",
    //   "dateTime": DateTime.now(),
    //   "amount": amount,
    //   "customerId": customerUid,
    //   "storeId": _auth.currentUser?.uid
    // });
    return amount;
  }

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
        amount = scanData.code!.split('*').first;
        customerUid = scanData.code!.split('*').last;
      });
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
              Expanded(flex: 4, child: _buildQrView(context)),
              amount.length > 1
                  ? TextButton(
                      onPressed: () async {
                        if (amount.length > 1) {
                          Loader.show(context);
                          await _db
                              .collection('users')
                              .doc(customerUid)
                              .get()
                              .then((value) async {
                            if (double.parse(value['balance'].toString()) >
                                double.parse(amount)) {
                              print('sufficient Balance');
                              await _db.collection('payments').add({
                                "amount": amount,
                                "customer_id": customerUid,
                                "store_id": _auth.currentUser?.uid,
                                "transaction_id": transactionIdGenerator(),
                                "transaction_time": DateTime.now(),
                              }).then((a) async {
                                await _db
                                    .collection('users')
                                    .doc(customerUid)
                                    .update({
                                  "balance":
                                      value['balance'] - double.parse(amount),
                                }).then((value) {
                                  Loader.hide();
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
