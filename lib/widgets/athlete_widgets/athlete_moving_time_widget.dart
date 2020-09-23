import 'package:encrateia/models/activity_list.dart';
import 'package:encrateia/models/tag_group.dart';
import 'package:encrateia/utils/athlete_volume_chart.dart';
import 'package:encrateia/utils/enums.dart';
import 'package:encrateia/utils/image_utils.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/models/activity.dart';

class AthleteMovingTimeWidget extends StatefulWidget {
  const AthleteMovingTimeWidget({this.athlete});

  final Athlete athlete;

  @override
  _AthleteMovingTimeWidgetState createState() => _AthleteMovingTimeWidgetState();
}

class _AthleteMovingTimeWidgetState extends State<AthleteMovingTimeWidget> {
  ActivityList<Activity> activities = ActivityList<Activity>(<Activity>[]);
  List<TagGroup> tagGroups = <TagGroup>[];
  String loadingStatus = 'Loading ...';
  String screenShotButtonText = 'Save as .png-Image';
  GlobalKey widgetKey = GlobalKey();
  List<String> sports;
  String selectedSports = 'running';

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isNotEmpty) {
      final List<Activity> distanceActivities = activities
          .where((Activity activity) =>
      activity.distance != null && activity.distance > 0)
          .toList();

      if (distanceActivities.isNotEmpty) {
        return ListTileTheme(
          iconColor: Colors.deepOrange,
          child: ListView(
            padding: const EdgeInsets.only(left: 25),
            children: <Widget>[
              RepaintBoundary(
                key: widgetKey,
                child: AthleteVolumeChart(
                  athlete: widget.athlete,
                  chartTitleText: 'Moving Time over Time (h)',
                  activities: activities,
                  volumeAttr: ActivityAttr.movingTimeThisYear,
                ),
              ),
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
              Row(
                children: <Widget>[
                  const Spacer(),
                  const Text('Select Sport'),
                  const SizedBox(width: 20),
                  DropdownButton<String>(
                    items: sports.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: selectedSports,
                    onChanged: (String value) {
                      selectedSports = value;
                      getData();
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text('No volume data available.'),
        );
      }
    } else {
      return Center(child: Text(loadingStatus));
    }
  }

  Future<void> getData() async {
    final Athlete athlete = widget.athlete;
    final List<Activity> unfilteredActivities = await athlete.validActivities;
    int movingTimeSoFar = 0;
    int year = 1900;
    sports = unfilteredActivities
        .map((Activity activity) => activity.sport)
        .toSet()
        .toList();
    activities = ActivityList<Activity>(unfilteredActivities
        .where((Activity activity) => activity.sport == selectedSports)
        .toList());

    for (final Activity activity in activities.reversed) {
      if (activity.timeStamp.year != year) {
        year = activity.timeStamp.year;
        movingTimeSoFar = activity.movingTime;
      } else
        movingTimeSoFar += activity.movingTime;
      activity.movingTimeSoFar = movingTimeSoFar;
    }

    setState(() =>
    loadingStatus = activities.length.toString() + ' activities found');
  }
}