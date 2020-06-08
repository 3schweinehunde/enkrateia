import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/models/record_list.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/activity.dart';
import 'package:encrateia/models/event.dart';
import 'package:encrateia/utils/num_utils.dart';
import 'package:encrateia/widgets/charts/activity_charts/activity_power_ratio_chart.dart';
import 'package:encrateia/utils/icon_utils.dart';

class ActivityPowerRatioWidget extends StatefulWidget {
  const ActivityPowerRatioWidget({
    @required this.activity,
    @required this.athlete,
  });

  final Activity activity;
  final Athlete athlete;

  @override
  _ActivityPowerRatioWidgetState createState() =>
      _ActivityPowerRatioWidgetState();
}

class _ActivityPowerRatioWidgetState extends State<ActivityPowerRatioWidget> {
  RecordList<Event> records = RecordList<Event>(<Event>[]);
  String avgPowerRatioString = 'Loading ...';
  String sdevPowerRatioString = 'Loading ...';

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (records.isNotEmpty) {
      final List<Event> powerRecords = records
          .where((Event value) =>
              value.power != null &&
              value.power > 100 &&
              value.formPower != null &&
              value.formPower > 0 &&
              value.formPower < 200)
          .toList();

      if (powerRecords.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.deepOrange,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              ActivityPowerRatioChart(
                records: RecordList<Event>(powerRecords),
                activity: widget.activity,
                athlete: widget.athlete,
              ),
              const Text('power ratio (%) = (power - form power) / power * 100'),
              Text('${widget.athlete.recordAggregationCount} records are '
                  'aggregated into one point in the plot. Only records where '
                  'power > 100 W and 0 W < form power < 200 W are shown.'),
              const Divider(),
              ListTile(
                leading: MyIcon.formPower,
                title: Text(avgPowerRatioString),
                subtitle: const Text('average power ratio'),
              ),
              ListTile(
                leading: MyIcon.standardDeviation,
                title: Text(sdevPowerRatioString),
                subtitle: const Text('standard deviation power ratio '),
              ),
              ListTile(
                leading: MyIcon.amount,
                title: Text(powerRecords.length.toString()),
                subtitle: const Text('number of measurements'),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No power ratio data available.'),
        );
      }
    } else {
      return const Center(
        child: Text('Loading'),
      );
    }
  }

  Future<void> getData() async {
    final Activity activity = widget.activity;
    records = RecordList<Event>(await activity.records);
    avgPowerRatioString = activity.db.avgPowerRatio.toStringOrDashes(1) + ' %';
    sdevPowerRatioString =
        activity.db.sdevPowerRatio.toStringOrDashes(2) + ' %';
    setState(() {});
  }
}
