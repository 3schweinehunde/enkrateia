import 'package:charts_flutter/flutter.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/models/power_zone.dart';
import 'package:encrateia/models/record_list.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/activity.dart';
import 'package:encrateia/models/event.dart';
import 'package:encrateia/models/lap.dart';
import 'package:encrateia/models/plot_point.dart';
import 'package:encrateia/utils/graph_utils.dart';
import 'package:encrateia/utils/my_line_chart.dart';
import 'package:encrateia/utils/enums.dart';

class ActivityPowerChart extends StatelessWidget {
  final RecordList<Event> records;
  final Activity activity;
  final Athlete athlete;
  final List<PowerZone> powerZones;

  ActivityPowerChart({
    this.records,
    @required this.activity,
    @required this.athlete,
    this.powerZones,
  });

  @override
  Widget build(BuildContext context) {
    var smoothedRecords = records.toIntDataPoints(
      attribute: LapIntAttr.power,
      amount: athlete.db.recordAggregationCount,
    );

    List<Series<dynamic, num>> data = [
      Series<IntPlotPoint, int>(
        id: 'Power',
        colorFn: (_, __) => MaterialPalette.gray.shade700,
        domainFn: (IntPlotPoint record, _) => record.domain,
        measureFn: (IntPlotPoint record, _) => record.measure,
        data: smoothedRecords,
      )
    ];

    return FutureBuilder<List<Lap>>(
      future: activity.laps,
      builder: (BuildContext context, AsyncSnapshot<List<Lap>> snapshot) {
        if (snapshot.hasData) {
          var laps = snapshot.data;

          return Container(
            height: 300,
            child: MyLineChart(
              data: data,
              maxDomain: records.last.db.distance,
              laps: laps,
              powerZones: powerZones,
              domainTitle: 'Power (W)',
              measureTickProviderSpec: BasicNumericTickProviderSpec(
                  zeroBound: false,
                  desiredTickCount: 6),
              domainTickProviderSpec:
                  BasicNumericTickProviderSpec(desiredTickCount: 6),
            ),
          );
        } else
          return GraphUtils.loadingContainer;
      },
    );
  }
}