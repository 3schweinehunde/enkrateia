import 'package:encrateia/models/strava_fit_download.dart';
import 'package:encrateia/utils/my_button.dart';
import 'package:encrateia/utils/my_color.dart';
import 'package:encrateia/widgets/athlete_widgets/edit_strava_athlete_widget.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/utils/icon_utils.dart';

import 'onboarding_power_zone_schema_screen.dart';

class OnBoardingStravaCredentialsScreen extends StatelessWidget {
  const OnBoardingStravaCredentialsScreen({
    Key key,
    @required this.athlete,
  }) : super(key: key);

  final Athlete athlete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.athlete,
        title: const Text('Athlete Credentials'),
      ),
      body: EditStravaAthleteWidget(athlete: athlete),
    );
  }
}
