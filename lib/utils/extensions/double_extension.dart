part of 'extension.dart';

extension WidgetExtension on double {
  Widget get widthSizedBox => SizedBox(width: this);
  Widget get heightSizedBox => SizedBox(height: this);

  double doubleWithPlaces(int places){ 
   final double mod = pow(10.0, places).toDouble(); 
   return (this * mod).round().toDouble() / mod; 
}
}
