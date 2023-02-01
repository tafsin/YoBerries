import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Slider_promo extends StatefulWidget {
  const Slider_promo({Key? key}) : super(key: key);

  @override
  State<Slider_promo> createState() => _Slider_promoState();
}

class _Slider_promoState extends State<Slider_promo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var images = [];
  //getPromotionImages()async{
  //  await FirebaseFirestore.instance
  //       .collection('promotion_image')
  //       .doc("Bangladesh")
  //       .collection('promo_img')
  //       .where('isActive', isEqualTo: true)
  //       .where('expiryDate', isGreaterThanOrEqualTo: todayF)
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      // key: _scaffoldKey,
      // drawer: Drawer(
      //   backgroundColor: Colors.white,
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       SizedBox(
      //         height: 50,
      //       ),
      //       ListTile(
      //         title: Text('Log Out',style: TextStyle(color: Colors.black54,fontSize:20),),
      //         onTap: () {
      //           //_signOut();
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  //getMenu();
                  //NavigationDrawer();
                  _scaffoldKey.currentState?.openDrawer();
                  print('menu');
                },
                icon: Icon(
                  Icons.menu,
                  color: Colors.purple,
                  size: 30,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Welcome,Promo",
                    style: TextStyle(
                        color: Colors.purple,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Container(
            child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1,
                  aspectRatio: 0.5,
                  initialPage: 0,
                  height: ((MediaQuery.of(context).size.width) * 1.5) / 3,
                ),
                itemCount: images.length,
                itemBuilder: (context, index, realIndex) {
                  final sliderImage = images[index];
                  return buildImage(sliderImage, index);
                }),
          )
        ],
      ),
    );
  }

  Widget buildImage(String sliderImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width,
        color: Colors.grey,
        child: Image.asset(
          sliderImage,
          fit: BoxFit.cover,
        ),
      );
}
