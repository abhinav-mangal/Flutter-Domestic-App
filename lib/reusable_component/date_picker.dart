import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';

class DatePicker extends StatelessWidget {
  DatePicker({@required this.items, this.onDone, this.selectedIndex});
  final List? items;
  Function(int)? onDone;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    Size size = MediaQuery.of(context).size;
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: selectedIndex!);
    return Container(
      height: size.height / 4 + 40,
      child: Column(children: <Widget>[
        Container(
          height: 40,
          width: double.infinity,
          color: _appConfig.pickerBgColor,
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 80,
                  child: Text(
                    AppConstants.cancel,
                    style: _appConfig.paragraphLargeFontStyle
                        .apply(color: _appConfig.whiteColor),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (selectedIndex == null && items!.length != 0) {
                    onDone!(0);
                  } else {
                    onDone!(selectedIndex!);
                  }

                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 80,
                  child: Text(
                    AppConstants.done,
                    textAlign: TextAlign.end,
                    style: _appConfig.paragraphLargeFontStyle
                        .apply(color: _appConfig.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: size.height / 4,
          child: CupertinoPicker(
              scrollController: scrollController,
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                selectedIndex = index;
              },
              backgroundColor: _appConfig.pickerBgColor,
              children: new List<Widget>.generate(items!.length, (int index) {
                return new Center(
                  child: new Text(
                    '${items![index]}',
                    style: _appConfig.paragraphLargeFontStyle
                        .apply(color: _appConfig.whiteColor),
                  ),
                );
              })),
        ),
      ]),
    );
  }
}

class DatePickerDateMode extends StatelessWidget {
  DatePickerDateMode(
      {this.onDone,
      this.intialdate,
      this.minmumDate,
      this.maximumDate,
      this.pickerMode});

  Function(DateTime)? onDone;

  DateTime? selectedDate;

  DateTime? intialdate;
  DateTime? minmumDate;
  DateTime? maximumDate;
  CupertinoDatePickerMode? pickerMode;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    Size size = MediaQuery.of(context).size;
    selectedDate = intialdate ?? DateTime.now();
    return Container(
      height: size.height / 4 + 40,
      child: Column(
        children: <Widget>[
          Container(
            height: 40,
            width: double.infinity,
            color: _appConfig.pickerBgColor,
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 40,
                    width: 80,
                    child: Text(
                      AppConstants.cancel,
                      style: _appConfig.paragraphLargeFontStyle
                          .apply(color: _appConfig.whiteColor),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (selectedDate != null) {
                      onDone!(selectedDate!);
                    }
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 40,
                    width: 80,
                    child: Text(
                      AppConstants.done,
                      textAlign: TextAlign.end,
                      style: _appConfig.paragraphLargeFontStyle
                          .apply(color: _appConfig.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: size.height / 4,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: _appConfig.paragraphLargeFontStyle
                        .apply(color: _appConfig.whiteColor),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime:
                      intialdate, //intialdate != null ? intialdate : DateTime.now(),
                  onDateTimeChanged: (DateTime newdate) {
                    selectedDate = newdate;
                  },
                  backgroundColor: _appConfig.pickerBgColor,
                  maximumDate: maximumDate,
                  minimumDate: minmumDate,
                  mode: pickerMode ?? CupertinoDatePickerMode.date,
                ),
              ))
        ],
      ),
    );
  }
}
