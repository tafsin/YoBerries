import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/General.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

const String storeID = 'mstec602216c516812';
const String storePass = 'mstec602216c516812@ssl';

//SSL Commerz

Future<void> sslCommerzCustomizedCall(double amount, String trx) async {
  Sslcommerz sslcommerz = await Sslcommerz(
      initializer: SSLCommerzInitialization(
          ipn_url: "www.ipnurl.com",
          currency: SSLCurrencyType.BDT,
          product_category: "booking bill",
          sdkType: SSLCSdkType.TESTBOX,
          store_id: storeID,
          store_passwd: storePass,
          total_amount: amount,
          tran_id: trx));

  sslcommerz
      .addCustomerInfoInitializer(
          customerInfoInitializer: SSLCCustomerInfoInitializer(
              customerName: "Name",
              customerState: "Dhaka",
              customerEmail: "email",
              customerAddress1: "null",
              customerCity: "null",
              customerPostCode: "null",
              customerCountry: "null",
              customerPhone: ''))
      .addProductInitializer(
          sslcProductInitializer: SSLCProductInitializer(
              productName: "Yo Berries",
              productCategory: "Food",
              general: General(
                  general: "General Purpose",
                  productProfile: "Product Profile")));
  var result = await sslcommerz.payNow();
  if (result is PlatformException) {
    print("the response is: " + result.details + " code: " + result.code);
  } else {
    SSLCTransactionInfoModel model = result;
  }
}
//Transaction ID from Date Time

String transactionIdGenerator() {
  DateTime today = DateTime.now();
  const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLMmNnPpQqRrSsTtUuVvWwXxYyZz23456789';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String randomString = getRandomString(5);

  String uploadDate =
      "${today.hour.toString().padLeft(2, '0')}${today.minute.toString().padLeft(2, '0')}${today.second.toString().padLeft(2, '0')}${today.millisecond.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}${today.month.toString().padLeft(2, '0')}${today.year.toString().substring(today.year.toString().length - 2)}";

  String trxId = '$uploadDate$randomString';
  return trxId;
}
