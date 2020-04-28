import 'package:encrateia/screens/add_power_zone_schema_screen.dart';
import 'package:flutter/material.dart';
import 'package:encrateia/models/athlete.dart';
import 'package:encrateia/models/power_zone_schema.dart';
import 'package:encrateia/utils/icon_utils.dart';
import 'package:intl/intl.dart';

class AthletePowerZoneSchemaWidget extends StatefulWidget {
  final Athlete athlete;

  AthletePowerZoneSchemaWidget({this.athlete});

  @override
  _AthletePowerZoneSchemaWidgetState createState() =>
      _AthletePowerZoneSchemaWidgetState();
}

class _AthletePowerZoneSchemaWidgetState
    extends State<AthletePowerZoneSchemaWidget> {
  List<PowerZoneSchema> powerZoneSchemas = [];
  int offset = 0;
  int rows;

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(context) {
    if (powerZoneSchemas != null) {
      if (powerZoneSchemas.length > 0) {
        rows = (powerZoneSchemas.length < 8) ? powerZoneSchemas.length : 8;
        return ListView(
          children: <Widget>[
            Center(
              child: Text("\nPowerZoneSchemas ${offset + 1} - ${offset + rows} "
                  "of ${powerZoneSchemas.length}"),
            ),
            DataTable(
              columnSpacing: 10,
              columns: <DataColumn>[
                DataColumn(
                  label: Text("Date"),
                ),
                DataColumn(
                  label: Text("Name"),
                ),
                DataColumn(
                  label: Text("Base\nW"),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(""),
                ),
                DataColumn(
                  label: Text(""),
                )
              ],
              rows: powerZoneSchemas
                  .sublist(offset, offset + rows)
                  .map((PowerZoneSchema powerZoneSchema) {
                return DataRow(
                  key: Key(powerZoneSchema.db.id.toString()),
                  cells: [
                    DataCell(Text(DateFormat("d MMM yyyy")
                        .format(powerZoneSchema.db.date))),
                    DataCell(Text(powerZoneSchema.db.name)),
                    DataCell(Text(powerZoneSchema.db.base.toString())),
                    DataCell(MyIcon.delete,
                        onTap: () => deletePowerZoneSchema(
                            powerZoneSchema: powerZoneSchema)),
                    DataCell(
                      MyIcon.edit,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPowerZoneSchemaScreen(
                            athlete: widget.athlete,
                            powerZoneSchema: powerZoneSchema,
                          ),
                        ),
                      ).then((_) => getData()()),
                    )
                  ],
                );
              }).toList(),
            ),
            Row(
              children: <Widget>[
                Spacer(),
                RaisedButton(
                  color: Colors.green,
                  child: Text("New schema"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPowerZoneSchemaScreen(
                        athlete: widget.athlete,
                        powerZoneSchema: PowerZoneSchema(),
                      ),
                    ),
                  ).then((_) => getData()()),
                ),
                Spacer(),
                RaisedButton(
                  color: Colors.orange,
                  child: Text("<<"),
                  onPressed: (offset == 0)
                      ? null
                      : () => setState(() {
                            offset > 8 ? offset = offset - rows : offset = 0;
                          }),
                ),
                Spacer(),
                RaisedButton(
                  color: Colors.orange,
                  child: Text(">>"),
                  onPressed: (offset + rows == powerZoneSchemas.length)
                      ? null
                      : () => setState(() {
                            offset + rows < powerZoneSchemas.length - rows
                                ? offset = offset + rows
                                : offset = powerZoneSchemas.length - rows;
                          }),
                ),
                Spacer(),
              ],
            ),
          ],
        );
      } else {
        return Padding(
          padding: EdgeInsets.all(25.0),
          child: ListView(
            children: <Widget>[
              Text('''
No power schema defined so far:
                
You can easily start with one of the three pre defined power schemas,
just click on one of the the buttons und go from there.

You could also create a schema from scratch.

'''),
              RaisedButton(
                color: Colors.green,
                child: Text("New schema"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddPowerZoneSchemaScreen(
                      athlete: widget.athlete,
                      powerZoneSchema: PowerZoneSchema(),
                    ),
                  ),
                ).then((_) => getData()()),
              ),
              RaisedButton(
                // MyIcon.downloadLocal,
                color: Colors.orange,
                child: Text("Zone schema like Stryd"),
                onPressed: () => likeStryd(),
              ),
              RaisedButton(
                // MyIcon.downloadLocal,
                color: Colors.orange,
                child: Text("Zone schema like Jim Vance"),
                onPressed: () => likeJimVance(),
              ),
              RaisedButton(
                // MyIcon.downloadLocal,
                color: Colors.orange,
                child: Text("Zone schema like Stefan Dillinger"),
                onPressed: () => likeStefanDillinger(),
              ),
            ],
          ),
        );
      }
    } else {
      return Center(child: Text("loading"));
    }
  }

  getData() async {
    Athlete athlete = widget.athlete;
    powerZoneSchemas = await athlete.powerZoneSchemas;
    setState(() {});
  }

  likeStryd() async {
    Athlete athlete = widget.athlete;
    var powerZoneSchema = PowerZoneSchema.likeStryd(athlete: athlete);
    await powerZoneSchema.addStrydZones();
    await powerZoneSchema.db.save();
    await getData();
  }

  likeJimVance() async {
    Athlete athlete = widget.athlete;
    var powerZoneSchema = PowerZoneSchema.likeJimVance(athlete: athlete);
    await powerZoneSchema.addJimVanceZones();
    await powerZoneSchema.db.save();
    await getData();
  }

  likeStefanDillinger() async {
    Athlete athlete = widget.athlete;
    var powerZoneSchema = PowerZoneSchema.likeStefanDillinger(athlete: athlete);
    await powerZoneSchema.addStefanDillingerZones();
    await powerZoneSchema.db.save();
    await getData();
  }

  deletePowerZoneSchema({PowerZoneSchema powerZoneSchema}) async {
    await powerZoneSchema.delete();
    await getData();
  }
}
