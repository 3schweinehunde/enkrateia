import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Future<void> deleteAthlete({
  @required BuildContext context,
  @required Athlete athlete,
  @required Flushbar<Object> flushbar,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('All the athlete\'s data including'),
              Text('activities will be deleted as well.'),
              Text('There is no undo function.'),
            ],
          ),
        ),
        actions: <Widget>[
          MyButton.cancel(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MyButton.delete(
            onPressed: () async {
              await athlete.delete();
              Navigator.of(context)
                  .popUntil((Route<dynamic> route) => route.isFirst);
            },
          ),
        ],
      );
    },
  );
}
