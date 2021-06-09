import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medremind/Components/NotificationManager.dart';
import 'package:medremind/Model/Medicine.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

var Medname = TextEditingController();
NotificationManager manager;
var time;
var hour;
var min;
List query;
var query_length;
var currid;
List<String> timeofday = ['Morning', 'Afternoon', 'Evening', 'Night'];
TimeOfDay _time;

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper.instance;
  @override
  void initState() {
    super.initState();
    manager = new NotificationManager();
    setState(() {
      _query();
      _rowcount();
      _time = TimeOfDay(hour: 7, minute: 15);
    });
    // Medname.dispose();
  }

  void _selectTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null) {
      setState(
        () {
          _time = newTime;
          time = _time.format(context);
          hour = _time.hour;
          min = _time.minute;
          print(time);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 19, 43, 1),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: FloatingActionButton(
          onPressed: () {
            _modalBottomSheetMenu();
          },
          backgroundColor: Color.fromRGBO(111, 255, 233, 1),
          splashColor: Color.fromRGBO(0, 184, 156, 1),
          hoverColor: Color.fromRGBO(23, 190, 165, 1),
          focusColor: Color.fromRGBO(23, 190, 165, 1),
          child: Icon(
            Icons.add,
            size: 40,
            color: Color.fromRGBO(11, 19, 43, 1),
          ),
        ),
      ),
      body: query_length == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'No Medicines added !',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.varelaRound(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: ListView.builder(
                itemCount: query_length,
                itemBuilder: (context, index) {
                  // var item = query[index].toString();
                  var item = jsonEncode(query);
                  var temp = json.decode(item);
                  var fin = temp[index]['id'].toString();
                  var del = int.parse(fin);
                  if (query_length != 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          temp.removeAt(index);
                          int del = int.parse(fin);
                          _delete(del);
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromRGBO(28, 37, 65, 1),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.medication_outlined,
                                          color: Colors.lightGreenAccent,
                                          size: 40,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              temp[index]['name'],
                                              style: GoogleFonts.varelaRound(
                                                fontSize: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule_outlined,
                                              color: Colors.pinkAccent,
                                              size: 30,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${temp[index]['hour']}' +
                                                      ' :'.toString(),
                                                  style:
                                                      GoogleFonts.varelaRound(
                                                    fontSize: 25,
                                                    color: Colors.tealAccent,
                                                  ),
                                                ),
                                                Text(
                                                  temp[index]['min'].toString(),
                                                  style:
                                                      GoogleFonts.varelaRound(
                                                    fontSize: 25,
                                                    color: Colors.tealAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Swip to delete',
                                          style: GoogleFonts.varelaRound(
                                            fontSize: 20,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'No Medicines  added !',
                        style: GoogleFonts.varelaRound(
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  // Modal to enter data
  void _modalBottomSheetMenu() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      context: context,
      builder: (builder) {
        return new Container(
          height: 550.0,
          color: Colors.transparent,
          child: new Container(
            decoration: new BoxDecoration(
              color: Color.fromRGBO(28, 37, 65, 1),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(30.0),
                topRight: const Radius.circular(30.0),
              ),
            ),
            child: new Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Add Medicine',
                  style: GoogleFonts.varelaRound(
                    fontSize: 30,
                    color: Colors.tealAccent,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Name :',
                        style: GoogleFonts.varelaRound(
                          fontSize: 30,
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Container(
                          width: 250,
                          child: TextFormField(
                            controller: Medname,
                            style: GoogleFonts.varelaRound(
                                fontSize: 30, color: Colors.white),
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time of Day :',
                        style: GoogleFonts.varelaRound(
                          fontSize: 30,
                          color: Colors.redAccent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Colors.red;
                                return Colors.redAccent;
                                // Use the component's default.
                              },
                            ),
                          ),
                          onPressed: _selectTime,
                          child: Text(
                            'SELECT TIME',
                            style: GoogleFonts.varelaRound(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Colors.blueAccent;
                        return Colors.blue;
                        // Use the component's default.
                      },
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _insert();
                      manager.showNotificationDaily(
                          query_length, Medname.text, hour, min);
                      Medname.clear();
                      _query();

                      Navigator.pop(context);
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      "Add",
                      style: GoogleFonts.varelaRound(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: Medname.text,
      DatabaseHelper.columnHour: hour,
      DatabaseHelper.columnMin: min,
    };
    final id = await dbHelper.insert(row);
    setState(() {
      _rowcount();
    });
    print('inserted row id: $id');
  }

  _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    // allRows.forEach(print);
    setState(() {
      query = allRows.toList();
    });
    return query;
  }

  // void _update() async {
  //   // row to update
  //   Map<String, dynamic> row = {
  //     DatabaseHelper.columnId: 1,
  //     DatabaseHelper.columnName: 'Paracetamol',
  //     DatabaseHelper.columnTime: '24/4/13',
  //     DatabaseHelper.columnTimeofday: 'Night'
  //   };
  //   final rowsAffected = await dbHelper.update(row);
  //   print('updated $rowsAffected row(s)');
  // }

  void _delete(int del) async {
    // Assuming that the number of rows is the id for the last row.
    // final id = await dbHelper.queryRowCount();
    print('Id is ' + '$del');
    final rowsDeleted = await dbHelper.delete(del);
    print('deleted $rowsDeleted row(s): row $del');
    // setState(() {
    //   _rowcount();
    // });
  }

  _rowcount() async {
    final id = await dbHelper.queryRowCount();
    setState(() {
      query_length = id.toInt();
    });

    return query_length;
  }
}
