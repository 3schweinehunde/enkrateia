import 'package:encrateia/models/activity.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'show_activity_screen.dart';

class ListActivitiesScreen extends StatefulWidget {
  final Athlete athlete;

  const ListActivitiesScreen({
    Key key,
    this.athlete,
  }) : super(key: key);

  @override
  _ListActivitiesScreenState createState() => _ListActivitiesScreenState();
}

class _ListActivitiesScreenState extends State<ListActivitiesScreen> {
  Future<List<Activity>> activities;

  @override
  Widget build(BuildContext context) {
    activities = Activity.all();

    return Scaffold(
      appBar: AppBar(
        title: Text('Activities'),
      ),
      body: FutureBuilder<List<Activity>>(
        future: activities,
        builder: (context, snapshot) {
          return ListView(
            padding: EdgeInsets.all(20),
            children: <Widget>[
              if (widget.athlete.email != null &&
                  widget.athlete.password != null)
                ListTile(
                    leading: Icon(Icons.cloud_download),
                    title: Text("Download Activities from Strava"),
                    onTap: () => queryStrava()),
              if (widget.athlete.password == null)
                ListTile(
                  leading: Icon(Icons.error),
                  title: Text("Strava password not provided yet!"),
                ),
              if (widget.athlete.email == null)
                ListTile(
                  leading: Icon(Icons.error),
                  title: Text("Strava email not provided yet!"),
                ),
              if (snapshot.hasData)
                for (Activity activity in snapshot.data)
                  ListTile(
                    leading: Icon(Icons.directions_run),
                    title: Text("${activity.db.type} "
                        "${activity.db.stravaId}"),
                    subtitle: Text(activity.db.name ?? "Activity"),
                    trailing: ChangeNotifierProvider.value(
                      value: activity,
                      child: Consumer<Activity>(
                        builder: (context, activity, _child) =>
                            stateIcon(activity: activity),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future queryStrava() async {
    await Activity.queryStrava(athlete: widget.athlete);
    setState(() => {});
  }

  Future delete({Activity activity}) async {
    await activity.delete();
    setState(() => {});
  }

  stateIcon({Activity activity}) {
    switch (activity.db.state) {
      case "new":
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.cloud_download),
              onPressed: () => activity.download(athlete: widget.athlete),
              tooltip: 'Download',
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => delete(activity: activity),
              tooltip: 'Delete',
            ),
          ],
        );
        break;
      case "downloaded":
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.build),
              onPressed: () => activity.parse(athlete: widget.athlete),
              tooltip: 'Parse .fit-file',
            ),
            IconButton(
              icon: Icon(Icons.cloud_download),
              onPressed: () => activity.download(athlete: widget.athlete),
              tooltip: 'Download',
            ),
          ],
        );
        break;
      case "persisted":
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove_red_eye),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowActivityScreen(
                      activity: activity,
                    ),
                  ),
                )
              },
              tooltip: 'Show details',
            ),
            IconButton(
              icon: Icon(Icons.build),
              onPressed: () => activity.parse(athlete: widget.athlete),
              tooltip: 'Parse .fit-file',
            ),
          ],
        );
        break;
      default:
        return Text(activity.db.state);
    }
  }
}
