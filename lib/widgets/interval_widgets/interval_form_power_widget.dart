import 'package:encrateia/models/record_list.dart';
import 'package:encrateia/utils/PQText.dart';
import 'package:encrateia/utils/enums.dart';
import 'package:encrateia/utils/image_utils.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/interval.dart' as encrateia;
import 'package:encrateia/widgets/charts/lap_charts/lap_form_power_chart.dart';
import 'package:encrateia/utils/icon_utils.dart';
import 'package:encrateia/models/event.dart';

class IntervalFormPowerWidget extends StatefulWidget {
  const IntervalFormPowerWidget({this.interval});

  final encrateia.Interval interval;

  @override
  _IntervalFormPowerWidgetState createState() => _IntervalFormPowerWidgetState();
}

class _IntervalFormPowerWidgetState extends State<IntervalFormPowerWidget> {
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
  void didUpdateWidget(IntervalFormPowerWidget oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (records.isNotEmpty) {
      final List<Event> formPowerRecords = records
          .where(
              (Event value) => value.formPower != null && value.formPower > 0)
          .toList();

      if (formPowerRecords.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.lightGreen,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              RepaintBoundary(
                key: widgetKey,
                child: LapFormPowerChart(
                  records: RecordList<Event>(formPowerRecords),
                  minimum: widget.interval.avgFormPower / 1.1,
                  maximum: widget.interval.avgFormPower * 1.25,
                ),
              ),
              const Text(
                  'Only records where 0 W < form power < 200 W are shown.'),
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
                title: PQText(value: widget.interval.avgFormPower, pq: PQ.power),
                subtitle: const Text('average form power'),
              ),
              ListTile(
                leading: MyIcon.standardDeviation,
                title: PQText(value: widget.interval.sdevFormPower, pq: PQ.power),
                subtitle: const Text('standard deviation form power'),
              ),
              ListTile(
                leading: MyIcon.amount,
                title: PQText(value: formPowerRecords.length, pq: PQ.integer),
                subtitle: const Text('number of measurements'),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No form power data available.'),
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
