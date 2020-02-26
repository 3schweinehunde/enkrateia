import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/activity.dart';

class AthletePowerChart extends StatelessWidget {
  final List<Activity> activities;

  AthletePowerChart({@required this.activities});

  @override
  Widget build(BuildContext context) {
    int fullDecay = 30;
    int xAxesDays = 60;

    List<Activity> nonZeroActivities = activities
        .where((activity) =>
            activity.db.avgPower != null && activity.db.avgPower > 0)
        .toList();

    nonZeroActivities.asMap().forEach((index, activity) {
      double sumOfAvgPower = activity.db.avgPower * fullDecay;
      double sumOfWeightings = fullDecay * 1.0;
      for (var olderIndex = index + 1;
          olderIndex < nonZeroActivities.length;
          olderIndex++) {
        double daysAgo = activity.db.timeCreated
                .difference(nonZeroActivities[olderIndex].db.timeCreated)
                .inHours /
            24;
        if (daysAgo > fullDecay) break;
        sumOfAvgPower +=
            (fullDecay - daysAgo) * nonZeroActivities[olderIndex].db.avgPower;
        sumOfWeightings += (fullDecay - daysAgo);
      }

      activity.glidingAvgPower = sumOfAvgPower / sumOfWeightings;
    });

    var nonZeroDateLimited = nonZeroActivities
        .where((activity) =>
            DateTime.now().difference(activity.db.timeCreated).inDays <
            xAxesDays)
        .toList();

    var data = [
      Series<Activity, DateTime>(
        id: 'Average Power',
        colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
        domainFn: (Activity activity, _) => activity.db.timeCreated,
        measureFn: (Activity activity, _) => activity.db.avgPower,
        data: nonZeroDateLimited,
      ),
      Series<Activity, DateTime>(
        id: 'Gliding Average Power',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (Activity activity, _) => activity.db.timeCreated,
        measureFn: (Activity activity, _) => activity.glidingAvgPower,
        data: nonZeroDateLimited,
      )..setAttribute(rendererIdKey, 'glidingAverageRenderer'),
    ];

    return new Container(
      height: 300,
      child: TimeSeriesChart(
        data,
        animate: false,
        defaultRenderer: LineRendererConfig(
          includePoints: true,
          includeLine: false,
        ),
        customSeriesRenderers: [
          LineRendererConfig(
            customRendererId: 'glidingAverageRenderer',
            dashPattern: [1, 2],
          ),
        ],
        primaryMeasureAxis: NumericAxisSpec(
          tickProviderSpec: BasicNumericTickProviderSpec(
            zeroBound: false,
            dataIsInWholeNumbers: false,
            desiredTickCount: 6,
          ),
        ),
        behaviors: [
          ChartTitle(
            'Power (W)',
            titleStyleSpec: TextStyleSpec(fontSize: 13),
            behaviorPosition: BehaviorPosition.start,
            titleOutsideJustification: OutsideJustification.end,
          ),
          ChartTitle(
            'Date',
            titleStyleSpec: TextStyleSpec(fontSize: 13),
            behaviorPosition: BehaviorPosition.bottom,
            titleOutsideJustification: OutsideJustification.end,
          ),
        ],
      ),
    );
  }
}