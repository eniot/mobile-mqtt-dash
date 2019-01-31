import 'package:flutter/material.dart';

void confirmDialog(BuildContext context, String msg,
    {Function onConfirm, String confirmationText}) {
  showDialog(
    context: context,
    builder: (alertContext) => AlertDialog(
          title: new Text(msg),
          content: new Text(confirmationText ?? "Are you sure?"),
          actions: <Widget>[
            new FlatButton(
              textColor: Colors.grey,
              child: new Text("Yes"),
              onPressed: () {
                if (onConfirm != null) onConfirm();
                Navigator.of(alertContext).pop();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
          ],
        ),
  );
}
