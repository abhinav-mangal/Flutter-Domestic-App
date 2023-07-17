import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import 'country_code_picker.dart';
import 'country_model.dart';

///This function returns list of countries
Future getCountries(BuildContext context) async {
  // String rawData = await DefaultAssetBundle.of(context).loadString(
  //     'packages/three_steps_traintalent/raw/country_codes.json');
  String rawData = await DefaultAssetBundle.of(context)
      .loadString('assets/raw/country_codes.json');
  // if (rawData == null) {
  //   return [];
  // }
  final parsed = json.decode(rawData.toString()).cast<Map<String, dynamic>>();
  print('parser = $parsed');
  return parsed
      .map<CountryModel>(
          (json) => CountryModel.fromJson(json as Map<String, dynamic>))
      .toList() as List<CountryModel>;
}

///This function returns an user's current country. User's sim country code is matched with the ones in the list.
///If there is no sim in the device, first country in the list will be returned.
Future<CountryModel?> getDefaultCountry(BuildContext context) async {
  final list = await getCountries(context);
  CountryModel? currentCountry;
  try {
    final countryCode = await FlutterSimCountryCode.simCountryCode;
    currentCountry = list.firstWhere(
        (element) => element.countryCode == countryCode,
        orElse: () => const CountryModel());
  } catch (e) {
    currentCountry = list.first;
  }
  return currentCountry;
}

///This function returns an country whose [countryCode] matches with the passed one.
Future<CountryModel> getCountryByCountryCode(
    BuildContext context, String countryCode) async {
  final list = await getCountries(context);
  return list.firstWhere((element) => element.callingCode == countryCode,
      orElse: () => const CountryModel());
}

Future<CountryModel?> showCountryPickerSheet(BuildContext context,
    {Widget? title,
    Widget? cancelWidget,
    double cornerRadius = 35,
    bool focusSearchBox = false,
    double heightFactor = 0.9}) {
  assert(cornerRadius != null, 'cornerRadius cannot be null');
  assert(focusSearchBox != null, 'focusSearchBox cannot be null');
  assert(heightFactor <= 0.9 && heightFactor >= 0.4,
      'heightFactor must be between 0.4 and 0.9');
  return showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cornerRadius),
              topRight: Radius.circular(cornerRadius))),
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFactor,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              Stack(
                children: <Widget>[
                  cancelWidget ??
                      Positioned(
                        right: 8,
                        top: 4,
                        bottom: 0,
                        child: MaterialButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(context)),
                      ),
                  Center(
                    child: title ??
                        const Text(
                          'Choose region',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CountryPickerWidget(
                  onSelected: (country) => Navigator.of(context).pop(country),
                ),
              ),
            ],
          ),
        );
      });
}

Future<CountryModel?> showCountryPickerDialog(
  BuildContext context, {
  Widget? title,
  double cornerRadius = 35,
  bool focusSearchBox = false,
}) {
  assert(focusSearchBox != null, 'focusSearchBox cannot be null');

  return showDialog<CountryModel>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
              Radius.circular(cornerRadius),
            )),
            child: Column(
              children: <Widget>[
                SizedBox(height: 16),
                Stack(
                  children: <Widget>[
                    Positioned(
                      right: 8,
                      top: 4,
                      bottom: 0,
                      child: MaterialButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context)),
                    ),
                    Center(
                      child: title ??
                          const Text(
                            'Choose region',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CountryPickerWidget(
                    onSelected: (country) => Navigator.of(context).pop(country),
                  ),
                ),
              ],
            ),
          ));
}
