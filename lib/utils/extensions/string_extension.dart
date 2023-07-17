part of 'extension.dart';

extension strExtension on String {
  bool isNumeric() {
    if (this == null) {
      return false;
    }
    return double.parse(this) != null;
  }

  bool validDouble() {
    if (this == null) {
      return false;
    }
    return double.tryParse(this) != null && double.tryParse(this)! > 0;
  }

  Color colorFromHex() {
    final hexCode = this.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  String hidePhoneNumber({int lastdigit = 4}) {
    //int substractLeng = this.length - lastdigit;
    String newString = this.substring(this.length - lastdigit);
    return '**$newString';
  }

  DateTime getDateFromString() {
    return DateFormat('yyyy-MM-dd').parse(this);
  }

  String onlyNumber() {
    if (this != null) {
      return this.replaceAll(new RegExp(r"\D"), "");
    }

    return '';
  }
}
