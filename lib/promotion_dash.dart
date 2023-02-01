import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yo_berry_2/slider_promo.dart';

class Promotion_dash extends StatefulWidget {
  const Promotion_dash({Key? key}) : super(key: key);

  @override
  State<Promotion_dash> createState() => _Promotion_dashState();
}

class _Promotion_dashState extends State<Promotion_dash> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var images = [
    'assets/images/list_rh2.png', //1200x600
    'assets/images/qq.jpeg',
    'assets/images/exp-des.jpeg', //640X320
    'assets/images/g_flag.png' //640X320
  ];
  String todayF = '';
  late DateTime today;

  getDate() {
    today = DateTime.now();
    todayF = DateFormat('dd-MM-yy').format(today);
  }

  @override
  void initState() {
    super.initState();
    getDate();
  }

  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('list'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('promotion_image')
              .doc('Bangladesh')
              .collection('promo_img')
              .where('isActive', isEqualTo: true)
              .where('promotionExpiryDate', isGreaterThanOrEqualTo: todayF)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              print(snapshot.data!.size);
              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((document) {
                  return Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10.0,
                              spreadRadius: 03,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: FittedBox(
                        child: Image.network(
                          document['img'],
                          fit: BoxFit.fill,
                          width: 640,
                          height: 400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Slider_promo()));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.navigation),
      ),
    );
  }
}
// Padding(
// padding: EdgeInsets.all(20),
// child: Container(
// decoration: BoxDecoration(
// border: Border.all(color: Colors.black)
// ),
// child: FittedBox(
// child: Image.asset(
// images[1],
// fit: BoxFit.fill,
// width: MediaQuery.of(context).size.width-40,
// height: ((MediaQuery.of(context).size.width-40) * 1.5)/3,
// ),
// ),
// ),
// ),
