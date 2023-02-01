import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yo_berry_2/screens/add_to_cart.dart';

class Menu_Items extends StatefulWidget {
  //const Menu_Items({Key? key}) : super(key: key);
  final String itemCategory;
  final String itemCategoryImage;
  final String storeId;
  final String storeArea;
  final String storeAddress;
  final int vat;
  final String zipCode;
  final String country;

  const Menu_Items(this.itemCategory, this.itemCategoryImage, this.storeId,
      this.storeArea, this.storeAddress, this.vat, this.zipCode, this.country);

  @override
  State<Menu_Items> createState() => _Menu_ItemsState();
}

class _Menu_ItemsState extends State<Menu_Items> {
  @override
  String? userEmail = "";
  String? uid = "";

  void initState() {
    super.initState();

    currentUser();
  }

  void currentUser() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email;
      uid = currentUser.uid;
      print(currentUser.email);
    }
  }

  // addToCart(String item_name, price) async{
  //   await FirebaseFirestore.instance.collection('customer_cart').doc(userEmail).collection('menu').doc().set({
  //     'item_name': item_name,
  //     "item_price": price
  //   });
  // }
  //String itemCatgeoryImage ='';
  // getItemCategoryImage() async{
  //   await FirebaseFirestore.instance
  //       .collection('store_collection').doc(widget.storeId).collection('menu').where('item_category',isEqualTo: widget.itemCategory).get().then((value) => {
  //         setState((){
  //           itemCatgeoryImage = value['itemCatgeoryImage'];
  //         })
  //   });
  // }
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.itemCategoryImage),
                fit: BoxFit.fill,
                // scale: 50.0
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
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
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('country_menu')
                  .doc(widget.country)
                  .collection('menu')
                  .where('item_category', isEqualTo: widget.itemCategory)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return Container(
                  height: 520,
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map((document) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: 16, left: 8, right: 8),
                        child: GestureDetector(
                          onTap: () {
                            var docId = document.id;

                            // Navigator.push(context, MaterialPageRoute(builder: (context)=> AddToCart(docId,widget.storeId,widget.storeAddress,widget.storeArea,widget.itemCategory,widget.vat,widget.zipCode,widget.country,)));
                          },
                          child: Container(
                            height: 80,
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
                                      color: Colors.purple,
                                      blurRadius: 10.0,
                                      spreadRadius: 1,
                                      offset: Offset(0, 5)),
                                ],
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, top: 5, bottom: 5, right: 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(document['item_name'],
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      document['isMultiple']
                                          ? Row(
                                              children: [
                                                Text('from '),
                                                Text(document['price']
                                                    .toString()),
                                                Text(' Tk'),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                    document['price']
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 18.0,
                                                        color: Colors.black87)),
                                                Text(' Tk'),
                                              ],
                                            ),
                                    ],
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 8.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          color: Colors.black54,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Image.network(
                                              document['itemImage'],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 4.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
