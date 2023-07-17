class CountryModel {
  const CountryModel({this.name, this.countryCode, this.callingCode});

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'] as String,
      //flag: json['flag'] as String,
      countryCode: json['country_code'] as String,
      callingCode: json['calling_code'] as String,
    );
  }

  final String? name;
  //final String? flag;
  final String? countryCode;
  final String? callingCode;

  

  
}
