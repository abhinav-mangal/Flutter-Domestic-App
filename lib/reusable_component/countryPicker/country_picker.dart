import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../utils/common/constants.dart';
import '../../utils/common/main_app_bar.dart';
import '../../utils/theme/colors.dart';
import '../custom_scaffold.dart';
import 'country_code_picker.dart';
import 'country_model.dart';

class CountryPicker extends StatefulWidget {
  static const String routeName = '/CountryPicker';

  @override
  _CountryPickerState createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  @override
  Widget build(BuildContext context) {
    final AppConfig? config = AppConfig.of(context);
    return CustomScaffold(
      appBar: getMainAppBar(
        context,
        config,
        title: NavigationBarConstants.selectCountry,
        backgoundColor: context.theme.accentColor,
        textColor: AppColors.textColorWhite,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
          child: CountryPickerWidget(
            searchInputStyle: config!.calibriHeading2FontStyle
                .apply(color: config.whiteColor),
            itemTextStyle: context.theme.textTheme.bodyText2!.apply(
              fontWeightDelta: -1,
              color: config.greyColor,
            ),
            flagIconSize: 25,
            searchInputDecoration: InputDecoration(
              hintText: AppConstants.search,
              labelText: AppConstants.search,
              labelStyle:
                  config.labelNormalFontStyle.apply(color: config.greyColor),
              hintStyle:
                  config.labelNormalFontStyle.apply(color: config.greyColor),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.accentColor,
                ),
                //borderRadius: BorderRadius.circular(10.0),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.hintColor,
                ),
                //borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onSelected: (CountryModel country) =>
                Navigator.pop(context, country),
          ),
        ),
      ),
    );
  }
}
