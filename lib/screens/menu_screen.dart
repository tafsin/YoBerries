import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yo_berry_2/screens/cart_items.dart';
import 'package:yo_berry_2/screens/display_menu_items.dart';

class Menu_Screen extends StatefulWidget {
  //const Menu_Screen({Key? key}) : super(key: key);
  final String docId, storeArea, storeAddress;
  final int vat;
  final String country;

  const Menu_Screen(
      this.docId, this.storeArea, this.storeAddress, this.vat, this.country);

  @override
  _Menu_ScreenState createState() => _Menu_ScreenState();
}

class _Menu_ScreenState extends State<Menu_Screen> {
  String store_address = '';
  String store_zipCode = '';
  String store_area = '';
  String store_phone_num = '';

  void initState() {
    super.initState();
    //getStoreInfo();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  getStoreInfo() async {
    final store = await FirebaseFirestore.instance
        .collection('store_collection')
        .doc(widget.docId)
        .get();
    Loader.show(context);

    // setState(() {
    store_area = store['areaName'];
    store_address = store['address'];
    store_phone_num = store['storePhoneNum'];
    store_zipCode = store['zipCode'];
    Loader.hide();
    // });
    print(store_area);
    print(store_address);
    print(store_zipCode);
    print(store_phone_num);
  }

  @override
  void dispose() {
    super.dispose();
    Loader.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white70,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    //getMenu();
                    //NavigationDrawer();

                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.purple,
                    size: 30,
                  ),
                ),
                Text(
                  "MENU",
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CartItems(widget.vat, widget.country)));
                    },
                    icon: Icon(
                      Icons.shopping_cart_sharp,
                      color: Colors.purple,
                      size: 30,
                    ))
              ],
            ),
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/image1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            FutureBuilder(
                future: getStoreInfo(),
                builder: (context, stream) {
                  return Container(
                    margin: EdgeInsets.only(top: 5),
                    width: 380,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.grey,
                          blurRadius: 8.0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$store_area',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                '$store_address',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black54),
                              ),
                              Text(','),
                              Text(
                                '$store_zipCode',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black54),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '$store_phone_num',
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 15),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    _makePhoneCall(store_phone_num);
                                  },
                                  icon: Icon(
                                    Icons.phone_enabled,
                                    color: Colors.purple,
                                    size: 25,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('country_menu')
                    .doc(widget.country)
                    .collection('menu')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  Loader.show(context);
                  if (!snapshot.hasData) {
                    Loader.hide();
                    print('hh');
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    Loader.hide();
                    print(snapshot.data!.size);
                    print(snapshot.data!.docs);

                    //******
                    List itemCategory1 = [];
                    List itemImage = [];
                    snapshot.data?.docs.forEach((element) {
                      if (!itemCategory1.contains(element['item_category'])) {
                        itemCategory1.add(element['item_category']);
                      }
                      ;
                      if (!itemImage.contains(element['itemCategoryImage'])) {
                        itemImage.add(element['itemCategoryImage']);
                      }
                      ;
                    });
                    print('my category $itemCategory1');
                    //return Container();
                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        //childAspectRatio: 1.0,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 10,
                        //mainAxisExtent: 264,
                      ),
                      children: List.generate(
                        itemCategory1.length,
                        (index) {
                          return GestureDetector(
                            onTap: () {
                              var itemCategory = itemCategory1[index];
                              var itemCatgoryImage = itemImage[index];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Menu_Items(
                                          itemCategory,
                                          itemCatgoryImage,
                                          widget.docId,
                                          widget.storeAddress,
                                          widget.storeArea,
                                          widget.vat,
                                          store_zipCode,
                                          widget.country)));
                            },
                            child: Container(
                              height: 250,
                              margin:
                                  EdgeInsets.only(left: 12, right: 12, top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  new BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 8.0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Image.asset('assets/images/menu.jpeg',
                                  // height: 150,),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          itemImage[index],
                                          height: 120,
                                          width: 100,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    itemCategory1[index],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
