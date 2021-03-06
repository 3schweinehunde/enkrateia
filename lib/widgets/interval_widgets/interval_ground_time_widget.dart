import 'package:encrateia/models/record_list.dart';
import 'package:encrateia/utils/PQText.dart';
import 'package:encrateia/utils/enums.dart';
import 'package:encrateia/utils/image_utils.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/interval.dart' as encrateia;
import 'package:encrateia/models/event.dart';
import 'package:encrateia/widgets/charts/lap_charts/lap_ground_time_chart.dart';
import 'package:encrateia/utils/icon_utils.dart';

class IntervalGroundTimeWidget extends StatefulWidget {
  const IntervalGroundTimeWidget({this.interval});

  final encrateia.Interval interval;

  @override
  _IntervalGroundTimeWidgetState createState() => _IntervalGroundTimeWidgetState();
}

class _IntervalGroundTimeWidgetState extends State<IntervalGroundTimeWidget> {
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
  void didUpdateWidget(IntervalGroundTimeWidget oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (records.isNotEmpty) {
      final List<Event> groundTimeRecords = records
          .where(
              (Event value) => value.groundTime != null && value.groundTime > 0)
          .toList();

      if (groundTimeRecords.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.lightGreen,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              RepaintBoundary(
                key: widgetKey,
                child: LapGroundTimeChart(
                  records: RecordList<Event>(groundTimeRecords),
                  minimum: widget.interval.avgGroundTime / 1.25,
                  maximum: widget.interval.avgGroundTime * 1.25,
                ),
              ),
              const Text('Only records where ground time > 0 ms are shown.'),
              const Text('Swipe left/write to compare with other intervals.'),
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
                title: PQText(
                  value: widget.interval.avgGroundTime,
                  pq: PQ.groundTime,
                ),
                subtitle: const Text('average ground time'),
              ),
              ListTile(
                leading: MyIcon.standardDeviation,
                title: PQText(
                  value: widget.interval.sdevGroundTime,
                  pq: PQ.groundTime,
                ),
                subtitle: const Text('standard deviation ground time'),
              ),
              ListTile(
                leading: MyIcon.amount,
                title: PQText(value: groundTimeRecords.length, pq: PQ.integer),
                subtitle: const Text('number of measurements'),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No ground time available.'),
        );
      }
    } else {
      return Center(
        child: Text(loading ? 'Loading' : 'No data available'),
      );
    }
  }

  Future<void> getData() async {
    final encrateia.Interval interval = widget.interval;
    records = RecordList<Event>(await interval.records);
    setState(() => loading = false);
  }
}
