library countrycodepicker;

import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import '../../app_config.dart';
import 'country_model.dart';
import 'functions.dart';

const TextStyle _defaultItemTextStyle = TextStyle(fontSize: 16);
const TextStyle _defaultSearchInputStyle = TextStyle(fontSize: 16);
const String countryCodePackageName = 'three_steps_traintalent';

class CountryPickerWidget extends StatefulWidget {
  const CountryPickerWidget({
    Key? key,
    this.itemTextStyle = _defaultItemTextStyle,
    this.searchInputStyle = _defaultSearchInputStyle,
    this.searchInputDecoration,
    this.flagIconSize = 32,
    this.showSeparator = false,
    this.focusSearchBox = false,
    this.onSelected,
  })  : assert(flagIconSize != null &&
            showSeparator != null &&
            focusSearchBox != null),
        super(key: key);

  /// This callback will be called on selection of a [CountryModel].
  final ValueChanged<CountryModel>? onSelected;

  /// [itemTextStyle]
  /// can be used to change the TextStyle of the Text in ListItem.
  /// Default is [_defaultItemTextStyle]
  final TextStyle? itemTextStyle;

  /// [searchInputStyle]
  /// can be used to change the TextStyle of the Text in SearchBox.
  ///  Default is [searchInputStyle]
  final TextStyle? searchInputStyle;

  /// [searchInputDecoration]
  ///  can be used to change the decoration for SearchBox.
  final InputDecoration? searchInputDecoration;

  /// Flag icon size (width). Default set to 32.
  final double? flagIconSize;

  ///Can be set to `true` for showing the List Separator. Default set to `false`
  final bool? showSeparator;

  ///Can be set to `true` for opening the keyboard automatically.
  /// Default set to `false`
  final bool? focusSearchBox;

  @override
  _CountryPickerWidgetState createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<CountryModel> _list = <CountryModel>[];
  List<CountryModel> _filteredList = <CountryModel>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  CountryModel? _currentCountry;
  AppConfig? _config;
  void _onSearch(String text) {
    if (text == null || text.isEmpty) {
      setState(() {
        _filteredList.clear();
        _filteredList.addAll(_list);
      });
    } else {
      setState(() {
        _filteredList = _list
            .where((CountryModel element) =>
                element.name!
                    .toLowerCase()
                    .contains(text.toString().toLowerCase()) ||
                element.callingCode!
                    .toLowerCase()
                    .contains(text.toString().toLowerCase()) ||
                element.countryCode!
                    .toLowerCase()
                    .startsWith(text.toString().toLowerCase()))
            .map((CountryModel e) => e)
            .toList();
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      final FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
    // loadList();
    super.initState();
  }

  Future<void> loadList() async {
    setState(() {
      _isLoading = true;
    });
    _list = await getCountries(context);
    try {
      final String? code = await FlutterSimCountryCode.simCountryCode
          .onError((error, stackTrace) {
        print(error);
      });
      _currentCountry = _list.firstWhere(
        (CountryModel? element) => element!.countryCode == code,
        orElse: () => const CountryModel(),
      );
      if (_currentCountry?.callingCode != null) {
        _list.removeWhere((CountryModel element) =>
            element.callingCode == _currentCountry!.callingCode);
        _list.insert(0, _currentCountry!);
      }
    } finally {
      setState(() {
        _filteredList = _list.map((CountryModel e) => e).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: TextField(
            autocorrect: false,
            style: _config!.calibriHeading2FontStyle
                .apply(color: _config!.whiteColor),
            autofocus: widget.focusSearchBox ?? false,
            keyboardAppearance: _config!.brightness,
            decoration: widget.searchInputDecoration ??
                InputDecoration(
                    suffixIcon: Visibility(
                      visible: _controller.text.isNotEmpty,
                      child: InkWell(
                        onTap: () => setState(() {
                          _controller.clear();
                          _filteredList.clear();
                          _filteredList.addAll(_list);
                        }),
                        child: const Icon(Icons.clear),
                      ),
                    ),
                    border: OutlineInputBorder(
                        //borderSide: const BorderSide(),
                        borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    hintText: 'Search country name, code'),
            textInputAction: TextInputAction.search,
            controller: _controller,
            onChanged: _onSearch,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 16),
                  controller: _scrollController,
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, int index) =>
                      widget.showSeparator! ? const Divider() : Container(),
                  itemBuilder: (_, int index) {
                    return InkWell(
                      onTap: () {
                        widget.onSelected?.call(_filteredList[index]);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 12, top: 12, left: 24, right: 24),
                        child: Row(
                          children: <Widget>[
                            Image.asset(
                              'assets/flags/${_filteredList[index].countryCode}.png',
                              //_filteredList[index].flag,
                              // package: countryCodePackageName,
                              width: widget.flagIconSize,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            Expanded(
                                child: Text(
                              '${_filteredList[index].callingCode} ${_filteredList[index].name}',
                              style: _config!.paragraphNormalFontStyle
                                  .apply(color: _config!.whiteColor),
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
