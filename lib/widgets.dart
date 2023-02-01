import 'package:flutter/material.dart';

errorAlert(context, String e) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Padding(padding: EdgeInsets.all(5), child: Text(e)),
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 5, 5),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.purple),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Ok',
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        );
      });
}
