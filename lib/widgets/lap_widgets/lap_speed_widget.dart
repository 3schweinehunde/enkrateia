import 'package:encrateia/models/record_list.dart';
import 'package:encrateia/models/event.dart';
import 'package:encrateia/utils/PQText.dart';
import 'package:encrateia/utils/enums.dart';
import 'package:encrateia/utils/image_utils.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/lap.dart';
import 'package:encrateia/widgets/charts/lap_charts/lap_speed_chart.dart';
import 'package:encrateia/utils/icon_utils.dart';

class LapSpeedWidget extends StatefulWidget {
  const LapSpeedWidget({this.lap});

  final Lap lap;

  @override
  _LapSpeedWidgetState createState() => _LapSpeedWidgetState();
}

class _LapSpeedWidgetState extends State<LapSpeedWidget> {
  RecordList<Event> records = RecordList<Event>(<Event>[]);
  bool loading = true;
  String screenShotButtonText = 'Save as .png-Image';
  GlobalKey widgetKey = GlobalKey();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void didUpdateWidget(LapSpeedWidget oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (records.isNotEmpty) {
      final List<Event> paceRecords = records
          .where((Event value) => value.speed != null && value.speed > 0)
          .toList();

      if (paceRecords.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.lightGreen,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              RepaintBoundary(
                key: widgetKey,
                child: LapSpeedChart(
                  records: RecordList<Event>(paceRecords),
                  minimum: (widget.lap.avgSpeed - 3 * widget.lap.sdevSpeed) * 3.6,
                  maximum: (widget.lap.avgSpeed + 3 * widget.lap.sdevSpeed) * 3.6,
                ),
              ),
              const Text('Only records where speed > 0 m/s are shown.'),
              const Text('Swipe left/write to compare with other laps.'),
              Row(children: <Widget>[
                const Spacer(),
                MyButton.save(
                  child: Text(screenShotButtonText),
                  onPressed: () async {
                    await ImageUtils.capturePng(widgetKey: widgetKey);
                    screenShotButtonText = 'Image saved';
                    setState(() {});
                  },
                ),
                const SizedBox(width: 20),
              ]),
              ListTile(
                leading: MyIcon.average,
                title: PQText(value: widget.lap.avgSpeed, pq: PQ.speed),
                subtitle: const Text('average speed'),
              ),
              ListTile(
                leading: MyIcon.minimum,
                title: PQText(value: widget.lap.minSpeed, pq: PQ.speed),
                subtitle: const Text('minimum speed'),
              ),
              ListTile(
                leading: MyIcon.maximum,
                title: PQText(value: widget.lap.maxSpeed, pq: PQ.speed),
                subtitle: const Text('maximum speed'),
              ),
              ListTile(
                leading: MyIcon.standardDeviation,
                title: PQText(value: widget.lap.sdevSpeed, pq: PQ.speed),
                subtitle: const Text('standard deviation speed'),
              ),
              ListTile(
                leading: MyIcon.amount,
                title: PQText(value: paceRecords.length, pq: PQ.integer),
                subtitle: const Text('number of measurements'),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No heart rate data available.'),
        );
      }
    } else {
      return Center(
        child: Text(loading ? 'Loading' : 'No data available'),
      );
    }
  }

  Future<void> getData() async {
    records = RecordList<Event>(await widget.lap.records);
    setState(() => loading = false);
  }
}
