import 'package:encrateia/models/power_zone.dart';
import 'package:encrateia/models/power_zone_schema.dart';
import 'package:encrateia/models/record_list.dart';
import 'package:encrateia/utils/PQText.dart';
import 'package:encrateia/utils/enums.dart';
import 'package:encrateia/utils/image_utils.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/interval.dart' as encrateia;
import 'package:encrateia/models/event.dart';
import 'package:encrateia/widgets/charts/lap_charts/lap_power_chart.dart';
import 'package:encrateia/utils/icon_utils.dart';

class IntervalPowerWidget extends StatefulWidget {
  const IntervalPowerWidget({this.interval});

  final encrateia.Interval interval;

  @override
  _IntervalPowerWidgetState createState() => _IntervalPowerWidgetState();
}

class _IntervalPowerWidgetState extends State<IntervalPowerWidget> {
  RecordList<Event> records = RecordList<Event>(<Event>[]);
  bool loading = true;
  PowerZoneSchema powerZoneSchema;
  List<PowerZone> powerZones;
  String screenShotButtonText = 'Save as .png-Image';
  GlobalKey widgetKey = GlobalKey();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void didUpdateWidget(IntervalPowerWidget oldWidget) {
    getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (records.isNotEmpty) {
      final List<Event> powerRecords = records
          .where((Event value) => value.power != null && value.power > 100)
          .toList();

      if (powerRecords.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.lightGreen,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              RepaintBoundary(
                key: widgetKey,
                child: LapPowerChart(
                  records: RecordList<Event>(powerRecords),
                  powerZones: powerZones,
                ),
              ),
              const Text('Only records where power > 100 W are shown.'),
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
                title: PQText(value: widget.interval.avgPower, pq: PQ.power),
                subtitle: const Text('average power'),
              ),
              ListTile(
                leading: MyIcon.minimum,
                title: PQText(value: widget.interval.minPower, pq: PQ.power),
                subtitle: const Text('minimum power'),
              ),
              ListTile(
                leading: MyIcon.maximum,
                title: PQText(value: widget.interval.maxPower, pq: PQ.power),
                subtitle: const Text('maximum power'),
              ),
              ListTile(
                leading: MyIcon.standardDeviation,
                title: PQText(value: widget.interval.sdevPower, pq: PQ.power),
                subtitle: const Text('standard deviation power'),
              ),
              ListTile(
                leading: MyIcon.amount,
                title: PQText(value: powerRecords.length, pq: PQ.integer),
                subtitle: const Text('number of measurements'),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No power data available.'),
        );
      }
    } else {
      return Center(
        child: Text(loading ? 'Loading' : 'No data available'),
      );
    }
  }

  Future<void> getData() async {
    records = RecordList<Event>(await widget.interval.records);
    powerZoneSchema = await widget.interval.powerZoneSchema;
    if (powerZoneSchema != null)
      powerZones = await powerZoneSchema.powerZones;
    else
      powerZones = <PowerZone>[];
    setState(() => loading = false);
  }
}
