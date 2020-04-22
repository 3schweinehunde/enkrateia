import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/models/weight.dart';
import 'package:encrateia/utils/icon_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class AthleteBodyWeightWidget extends StatefulWidget {
  final Athlete athlete;

  AthleteBodyWeightWidget({this.athlete});

  @override
  _AthleteBodyWeightWidgetState createState() =>
      _AthleteBodyWeightWidgetState();
}

class _AthleteBodyWeightWidgetState extends State<AthleteBodyWeightWidget> {
  List<Weight> weights = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(context) {
    if (weights != null) {
      if (weights.length > 0) {
        return Text(weights.length.toString());
      } else {
        return ListView(
          children: <Widget>[
            Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: Text('''
                    No weight data available.
                
You can import your historic weight data by putting a weights.csv-file in the App's document directory.
It's the one with a file named "put_your_fit_files_here.txt" inside.

Put one date and weight per line in the following format:
2020-04-28,75.3
                ''')),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: ListTile(
                leading: MyIcon.downloadLocal,
                title: Text("Import Weights"),
                onTap: () => importWeights(),
              ),
            ),
          ],
        );
      }
    } else {
      return Center(
        child: Text("loading"),
      );
    }
  }

  getData() async {
    Athlete athlete = widget.athlete;
    weights = await athlete.weights;
    setState(() {});
  }

  importWeights() async {
    Directory directory;
    Weight weight;

    if (Platform.isAndroid) {
      var directories = await getExternalStorageDirectories();
      directory = directories[0];
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    var pathToFile = directory.path + "/weights.csv";
    var isFile = await FileSystemEntity.isFile(pathToFile);
    if (isFile == true) {
      var input = File(pathToFile).openRead();
      final weightings = await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter(eol: "\n"))
          .toList();
      for (List weighting in weightings) {
        weight = Weight();
        weight.db.athletesId = widget.athlete.db.id;
        weight.db.date = DateTime.utc(
          int.parse(weighting[0].split("-")[0]),
          int.parse(weighting[0].split("-")[1]),
          int.parse(weighting[0].split("-")[2]),
        );
        weight.db.value = weighting[1].toDouble();
        await weight.db.save();
      }
      await getData();
    }
  }
}
