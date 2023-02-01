import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:intl/intl.dart';

class Vouchers extends StatefulWidget {
  //const Vouchers({Key? key}) : super(key: key);
  final String? country;

  const Vouchers(this.country);

  @override
  State<Vouchers> createState() => _VouchersState();
}

class _VouchersState extends State<Vouchers> {
  Map<String, dynamic> countryCurrency = {};
  String currency = '';

  void initState() {
    super.initState();
    getDate();
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  late DateTime todayF;

  late DateTime today;

  getDate() {
    today = DateTime.now();
    todayF = today.subtract(Duration(days: 1));
  }

  Future getCurrency() async {
    Loader.show(context);
    await FirebaseFirestore.instance
        .collection('master')
        .doc('currency')
        .get()
        .then((value) {
      countryCurrency = value['currency'];
      currency = countryCurrency[widget.country];
    });
    Loader.hide();
    return currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.purple,
          title: Center(child: Text('Available Vouchers')),
        ),
        body: FutureBuilder(
            future: getCurrency(),
            builder: (context, stream) {
              return Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('promo')
                      .doc(widget.country)
                      .collection('promo_codes')
                      .where('isActive', isEqualTo: true)
                      .where('expiryDate', isGreaterThanOrEqualTo: todayF)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height - 10,
                      child: ListView(
                        shrinkWrap: true,
                        children: snapshot.data!.docs.map((document) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 8, right: 8),
                            child: Container(
                              height: 100,
                              //width: 200,
                              decoration: BoxDecoration(
                                  //\color: Colors.cyan[900],
                                  color: Colors.white,
                                  // border: Border.all(
                                  //   color: Colors.purple,
                                  //   width: 4.0,
                                  // ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey,
                                        blurRadius: 5.0,
                                        spreadRadius: .5,
                                        offset: Offset(0, 3)),
                                  ],
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 5, bottom: 5, right: 0),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Text(document['code'],
                                                style: TextStyle(
                                                  color: Colors.purple,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Expired on: ',
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                                Text(
                                                  document['promoExpiryDate'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Get ',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.purple),
                                            ),
                                            Text(
                                              document['discount'].toString(),
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.lightGreen),
                                            ),
                                            document['selectedOption'] ==
                                                    'fixed amount'
                                                ? Text(" $currency",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.purple))
                                                : Text(" %",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.purple)),
                                            Text(
                                              ' discount on minimum purchase ',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.purple),
                                            ),
                                            Text(
                                                document['minimumPurchase']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    color: Colors.lightGreen)),
                                            Text(
                                              ' $currency',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.purple),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Expanded(
                                    //   child: SizedBox(
                                    //     height: 8.0,
                                    //   ),
                                    // ),

                                    SizedBox(
                                      height: 4.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              );
            }));
  }
}
