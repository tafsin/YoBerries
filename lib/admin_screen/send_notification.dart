import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Send_Notification extends StatefulWidget {
  final String country;

  const Send_Notification(this.country);

  // const Send_Notification({Key? key}) : super(key: key);

  @override
  State<Send_Notification> createState() => _Send_NotificationState();
}

class _Send_NotificationState extends State<Send_Notification> {
  TextEditingController notificationController = TextEditingController();

  sendNotificationToCustomer(String country) async {
    print(country);
    final endpoint = "https://fcm.googleapis.com/fcm/send";

    final header = {
      'Authorization':
          'key=AAAA3gbk_qA:APA91bEoU2IvOCI_fV8n938Q1fjITt6XKY4xYWkJoQcm7RfPIfmiCcrcl0GwSCM9iN2WRj5vJY3yCnzlqrv0ibZ8FP2MBW13qFQdmNdisOrvp-Du7Bkcjwqmj0tzzrDDUg8QS6HLtMlV',
      'Content-Type': 'application/json'
    };

    http.Response response = await http.post(Uri.parse(endpoint),
        headers: header,
        body: jsonEncode({
          "to": "/topics/$country",
          "priority": "high",
          "notification": {
            "body": notificationController.text,
            "title": "YoBerries",
          }
        }));
    print(response.statusCode);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    final notificationField = TextFormField(
      //style: TextStyle(color: Colors.purple),
      autofocus: false,
      maxLines: 100,
      minLines: 10,

      controller: notificationController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        notificationController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.notification_important_outlined,
          color: Colors.purple[200],
        ),
        contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
        hintText: 'Type Notification...',
        hintStyle: TextStyle(color: Colors.black54),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: const BorderSide(color: Colors.purple, width: 1.5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      validator: (value) {
        if (value!.length == 0) {
          return "Field cannot be empty";
        } else {
          return null;
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Notification'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 40,
                  child: notificationField,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.purple),
                    onPressed: () async {
                      await sendNotificationToCustomer(widget.country);
                    },
                    child: Text('Send'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
