import 'dart:ui' as ui;
import 'package:encrateia/models/heart_rate_zone.dart';
import 'package:encrateia/models/lap.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:encrateia/models/power_zone.dart';
import 'package:flutter/material.dart';

// ignore: avoid_classes_with_only_static_members
class GraphUtils {
  static List<RangeAnnotationSegment<int>> rangeAnnotations({List<Lap> laps}) {
    final List<Color> colorArray = <Color>[
      MaterialPalette.white,
      MaterialPalette.gray.shade200,
    ];

    return <RangeAnnotationSegment<int>>[
      for (int index = 0; index < laps.length; index++)
        RangeAnnotationSegment<int>(
          laps
                  .sublist(0, index + 1)
                  .map((Lap lap) => lap.db.totalDistance)
                  .reduce((int a, int b) => a + b) -
              laps[index].db.totalDistance,
          laps
              .sublist(0, index + 1)
              .map((Lap lap) => lap.db.totalDistance)
              .reduce((int a, int b) => a + b),
          RangeAnnotationAxisType.domain,
          color: colorArray[index % 2],
          endLabel: 'Lap ${laps[index].index}',
        )
    ];
  }

  static LayoutConfig layoutConfig = LayoutConfig(
    leftMarginSpec: MarginSpec.fixedPixel(60),
    topMarginSpec: MarginSpec.fixedPixel(20),
    rightMarginSpec: MarginSpec.fixedPixel(20),
    bottomMarginSpec: MarginSpec.fixedPixel(40),
  );

  static Container loadingContainer = Container(
    height: 100,
    child: const Center(child: Text('Loading')),
  );

  static List<ChartTitle> axis({String measureTitle}) {
    return <ChartTitle>[
      ChartTitle(
        measureTitle,
        titleStyleSpec: const TextStyleSpec(fontSize: 13),
        behaviorPosition: BehaviorPosition.start,
        titleOutsideJustification: OutsideJustification.end,
      ),
      ChartTitle(
        'Distance (m)',
        titleStyleSpec: const TextStyleSpec(fontSize: 13),
        behaviorPosition: BehaviorPosition.bottom,
        titleOutsideJustification: OutsideJustification.end,
      ),
    ];
  }

  static List<RangeAnnotationSegment<int>> powerZoneAnnotations(
      {List<PowerZone> powerZones}) {
    List<RangeAnnotationSegment<int>> rangeAnnotationSegmentList =
        <RangeAnnotationSegment<int>>[];

    if (powerZones != null) {
      rangeAnnotationSegmentList = <RangeAnnotationSegment<int>>[
        for (PowerZone powerZone in powerZones)
          RangeAnnotationSegment<int>(
            powerZone.lowerLimit,
            powerZone.upperLimit,
            RangeAnnotationAxisType.measure,
            startLabel: powerZone.name,
            color: convertedColor(dbColor: powerZone.color),
          )
      ];
    }
    return rangeAnnotationSegmentList;
  }

  static List<RangeAnnotationSegment<int>> heartRateZoneAnnotations(
      {List<HeartRateZone> heartRateZones}) {
    List<RangeAnnotationSegment<int>> rangeAnnotationSegmentList =
        <RangeAnnotationSegment<int>>[];

    if (heartRateZones != null) {
      rangeAnnotationSegmentList = <RangeAnnotationSegment<int>>[
        for (HeartRateZone heartRateZone in heartRateZones)
          RangeAnnotationSegment<int>(
            heartRateZone.db.lowerLimit,
            heartRateZone.db.upperLimit,
            RangeAnnotationAxisType.measure,
            startLabel: heartRateZone.db.name,
            color: convertedColor(dbColor: heartRateZone.db.color),
          )
      ];
    }
    return rangeAnnotationSegmentList;
  }

  static Color convertedColor({int dbColor}) {
    return Color(
      r: ui.Color(dbColor).red,
      g: ui.Color(dbColor).green,
      b: ui.Color(dbColor).blue,
      a: (ui.Color(dbColor).alpha / 2).round(),
    );
  }
}
