import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/activity.dart';
import 'package:encrateia/models/event.dart';
import 'package:encrateia/models/lap.dart';
import 'package:encrateia/models/plot_point.dart';

class ActivityStrydCadenceChart extends StatelessWidget {
  final List<Event> records;
  final Activity activity;
  final colorArray = [
    MaterialPalette.white,
    MaterialPalette.gray.shade200,
  ];

  ActivityStrydCadenceChart({this.records, @required this.activity});

  @override
  Widget build(BuildContext context) {
    var nonZero = records.where((value) => value.db.strydCadence > 0);
    var smoothedRecords = Event.toDoubleDataPoints(
      attribute: "strydCadence",
      records: nonZero,
      amount: 30,
    );

    List<Series<dynamic, num>> data = [
      new Series<DoublePlotPoint, int>(
        id: 'Cadence',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (DoublePlotPoint record, _) => record.domain,
        measureFn: (DoublePlotPoint record, _) => record.measure,
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
            child: LineChart(
              data,
              domainAxis: NumericAxisSpec(
                viewport: NumericExtents(0, nonZero.last.db.distance + 500),
                tickProviderSpec: BasicNumericTickProviderSpec(
                  desiredTickCount: 6,
                ),
              ),
              primaryMeasureAxis: NumericAxisSpec(
                tickProviderSpec: BasicNumericTickProviderSpec(
                  zeroBound: false,
                  dataIsInWholeNumbers: false,
                  desiredTickCount: 5,
                ),
              ),
              animate: false,
              layoutConfig: LayoutConfig(
                leftMarginSpec: MarginSpec.fixedPixel(60),
                topMarginSpec: MarginSpec.fixedPixel(20),
                rightMarginSpec: MarginSpec.fixedPixel(20),
                bottomMarginSpec: MarginSpec.fixedPixel(40),
              ),
              behaviors: [
                RangeAnnotation(rangeAnnotations(laps: laps)),
                ChartTitle(
                  'Cadence (s/min)',
                  titleStyleSpec: TextStyleSpec(fontSize: 13),
                  behaviorPosition: BehaviorPosition.start,
                  titleOutsideJustification: OutsideJustification.end,
                ),
                ChartTitle(
                  'Distance (m)',
                  titleStyleSpec: TextStyleSpec(fontSize: 13),
                  behaviorPosition: BehaviorPosition.bottom,
                  titleOutsideJustification: OutsideJustification.end,
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: 100,
            child: Center(child: Text("Loading")),
          );

        }
      },
    );
  }

  rangeAnnotations({List<Lap> laps}) {
    return [
      for (int index = 0; index < laps.length; index++)
        RangeAnnotationSegment(
          laps
              .sublist(0, index + 1)
              .map((lap) => lap.db.totalDistance)
              .reduce((a, b) => a + b) -
              laps[index].db.totalDistance,
          laps
              .sublist(0, index + 1)
              .map((lap) => lap.db.totalDistance)
              .reduce((a, b) => a + b),
          RangeAnnotationAxisType.domain,
          color: colorArray[index % 2],
          endLabel: 'Lap ${laps[index].index}',
        )
    ];
  }
}