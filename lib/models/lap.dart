import 'package:encrateia/model/model.dart';
import 'package:fit_parser/fit_parser.dart';
import 'package:encrateia/utils/date_time_utils.dart';
import 'package:encrateia/utils/list_utils.dart';
import 'package:encrateia/models/event.dart';
import 'activity.dart';
import 'dart:math';

class Lap {
  DbLap db;
  Activity activity;
  int index;

  Lap({DataMessage dataMessage, this.activity, int eventId}) {
    db = DbLap()
      ..activitiesId = activity.db.id
      ..eventsId = eventId
      ..timeStamp = dateTimeFromStrava(dataMessage.get('timestamp'))
      ..startTime = dateTimeFromStrava(dataMessage.get('start_time'))
      ..startPositionLat = dataMessage.get('start_position_lat')
      ..startPositionLong = dataMessage.get('start_position_long')
      ..endPositionLat = dataMessage.get('end_position_lat')
      ..endPositionLong = dataMessage.get('end_position_long')
      ..startPositionLat = dataMessage.get('end_position_lat')
      ..avgHeartRate = dataMessage.get('avg_heart_rate')?.round()
      ..maxHeartRate = dataMessage.get('max_heart_rate')?.round()
      ..avgRunningCadence = dataMessage.get('avg_running_cadence')
      ..event = dataMessage.get('event')
      ..eventType = dataMessage.get('event_type')
      ..eventGroup = dataMessage.get('event_group')?.round()
      ..sport = dataMessage.get('sport')
      ..subSport = dataMessage.get('sub_sport')
      ..avgVerticalOscillation = dataMessage.get('avg_vertical_oscillation')
      ..totalElapsedTime = dataMessage.get('total_elapsed_time')?.round()
      ..totalTimerTime = dataMessage.get('total_timer_time')?.round()
      ..totalDistance = dataMessage.get('total_distance')?.round()
      ..totalStrides = dataMessage.get('total_strides')?.round()
      ..totalCalories = dataMessage.get('total_calories')?.round()
      ..avgSpeed = dataMessage.get('avg_speed')
      ..maxSpeed = dataMessage.get('max_speed')
      ..totalAscent = dataMessage.get('total_ascent')?.round()
      ..totalDescent = dataMessage.get('total_descent')?.round()
      ..avgStanceTimePercent = dataMessage.get('avg_stance_time_percent')
      ..avgStanceTime = dataMessage.get('avg_stance_time')
      ..maxRunningCadence = dataMessage.get('max_running_cadence')?.round()
      ..intensity = dataMessage.get('intensity')?.round()
      ..lapTrigger = dataMessage.get('lap_trigger')
      ..avgTemperature = dataMessage.get('avg_temperature')?.round()
      ..maxTemperature = dataMessage.get('max_temperature')?.round()
      ..avgFractionalCadence = dataMessage.get('avg_fractional_cadence')
      ..maxFractionalCadence = dataMessage.get('max_fractional_cadence')
      ..totalFractionalCycles = dataMessage.get('total_fractional_cycles')
      ..save();
  }
  Lap.fromDb(this.db);

  Future<int> firstEventId() async {
    if (index > 1) {
      var lapList = await Lap.by(activity: activity);
      DbEvent firstEvent = await lapList
          .firstWhere((lap) => lap.index == index - 1)
          .db
          .getDbEvent();
      return firstEvent.id;
    } else {
      return 0;
    }
  }

  static Future<List<Lap>> by({Activity activity}) async {
    int counter = 1;

    List<DbLap> dbLapList = await activity.db.getDbLaps().toList();
    var lapList = dbLapList.map((dbLap) => Lap.fromDb(dbLap)).toList();

    for (Lap lap in lapList) {
      lap
        ..activity = activity
        ..index = counter;
      counter = counter + 1;
    }
    return lapList;
  }

  static String averageHeartRate({List<Event> records}) {
    var heartRates = records.map((record) => record.db.heartRate);
    return heartRates.mean().toStringAsFixed(1);
  }

  static String sdevHeartRate({List<Event> records}) {
    var heartRates = records.map((record) => record.db.heartRate);
    return heartRates.sdev().toStringAsFixed(2);
  }

  static String minHeartRate({List<Event> records}) {
    var heartRates = records.map((record) => record.db.heartRate);
    return heartRates.reduce(min).toStringAsFixed(1);
  }

  static String maxHeartRate({List<Event> records}) {
    var heartRates = records.map((record) => record.db.heartRate);
    return heartRates.reduce(max).toStringAsFixed(1);
  }

  static String averagePower({List<Event> records}) {
    var powers = records.map((record) => record.db.power);
    return powers.mean().toStringAsFixed(1);
  }

  static String sdevPower({List<Event> records}) {
    var powers = records.map((record) => record.db.power);
    return powers.sdev().toStringAsFixed(2);
  }

  static String minPower({List<Event> records}) {
    var powers = records.map((record) => record.db.power);
    return powers.reduce(min).toStringAsFixed(1);
  }

  static String maxPower({List<Event> records}) {
    var powers = records.map((record) => record.db.power);
    return powers.reduce(max).toStringAsFixed(1);
  }
}
