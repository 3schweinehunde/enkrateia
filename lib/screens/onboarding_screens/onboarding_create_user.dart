import 'package:encrateia/actions/setupDemoAthlete.dart';
import 'package:encrateia/screens/onboarding_screens/onboarding_finished_screen.dart';
import 'package:encrateia/screens/onboarding_screens/onboarding_strava_credentials_screen.dart';
import 'package:encrateia/utils/my_button_style.dart';
import 'package:encrateia/utils/my_color.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:encrateia/utils/icon_utils.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/screens/strava_get_user.dart';

import 'onboarding_standalone_credentials_screen.dart';

class OnboardingCreateUserScreen extends StatefulWidget {
  const OnboardingCreateUserScreen();

  @override
  _OnboardingCreateUserScreenState createState() =>
      _OnboardingCreateUserScreenState();
}

class _OnboardingCreateUserScreenState
    extends State<OnboardingCreateUserScreen> {
  Athlete athlete = Athlete();
  Flushbar<Object> flushbar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.primary,
        title: const Text('Creating an Athlete'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: <Widget>[
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: MyIcon.create,
                      title: Text('Option 1: Demo Setup'),
                      subtitle: Text(
                        'Choose this option to create a demo user with demo setup.'
                        'It will download and analyse 4 activities provided '
                        'by the Encrateia team. '
                        'This is the quickest option to explore Encrateia.',
                      ),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        ElevatedButton(
                          style: MyButtonStyle.raisedButtonStyle(color: MyColor.primary),
                          child: const Text('Create Demo User'),
                          onPressed: () async {
                            await setupDemoAthlete(
                              context: context,
                              flushbar: flushbar,
                            );
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<BuildContext>(
                                builder: (BuildContext _) =>
                                    const OnboardingFinishedScreen(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: MyIcon.download,
                      title:
                          Text('Option 2: Athlete with Strava Account'),
                      subtitle: Text(
                          'Choose this option, if you want to download activities '
                          'from Strava'),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        ElevatedButton(
                          style: MyButtonStyle.raisedButtonStyle(color: MyColor.primary),
                          child: const Text('Connect to Strava'),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute<BuildContext>(
                                builder: (BuildContext context) =>
                                    StravaGetUser(athlete: athlete),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<BuildContext>(
                                builder: (BuildContext _) =>
                                    OnBoardingStravaCredentialsScreen(
                                        athlete: athlete),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const ListTile(
                      leading: MyIcon.upload,
                      title: Text('Option 3: Standalone Athlete'),
                      subtitle: Text(
                          'Choose this option, if you want to upload all'
                          ' .fit-files manually'),
                    ),
                    ButtonBar(
                      children: <Widget>[
                        ElevatedButton(
                          style: MyButtonStyle.raisedButtonStyle(color: MyColor.primary),
                          child: const Text('Create standalone User'),
                          onPressed: () {
                            athlete.setupStandaloneAthlete();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute<BuildContext>(
                                builder: (BuildContext _) =>
                                    OnBoardingStandaloneCredentialsScreen(
                                        athlete: athlete),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
