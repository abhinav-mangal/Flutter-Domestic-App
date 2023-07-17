part of 'extension.dart';

extension DateTimeHelper on DateTime {
  String dateTimeString({bool? isShowDate}) {
    String dateInString = '';
    if (this != null) {
      final DateFormat formatter = DateFormat('dd MMMM yyyy');
      dateInString = formatter.format(this);
    }

    return dateInString;
  }

  String taskDateTimeString({bool? isShowDate}) {
    String dateInString = '';
    final DateFormat formatter = DateFormat('hh:mm a');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String getTimeToString() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('HH:mm');
    dateInString = formatter.format(this.toLocal());
    return dateInString;
  }

  String dateToyyyymmdd() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String showDayMonth() {
    String dateInString = '';
    final DateFormat formatter = DateFormat('dd, MMMM');
    dateInString = formatter.format(this);
    return dateInString;
  }

  String dateTimeStringForAnnouncement() {
    String dateInString = '';
    if (this != null) {
      final DateFormat formatter = DateFormat('EEEE, MMMM dd yyyy');
      dateInString = formatter.format(this);
    }

    return dateInString;
  }

  String dateTimeStringForNotification() {
    String fullString = '';
    if (this != null) {
      final DateFormat formatter = DateFormat('MMMM dd yyyy');
      final String dateInString = formatter.format(this);

      final DateFormat formatterTime = DateFormat('hh:mm a');
      final String timeInString = formatterTime.format(this);

      fullString = '$dateInString at $timeInString';
    }

    return fullString;
  }

  bool isBeforCurrentTime() {
    final DateTime now = DateTime.now();
    if (this != null) {
      return this.isBefore(now);
    }
    return false;
  }

  bool isToday() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dateToCheck = DateTime(this.year, this.month, this.day);

    if (today == dateToCheck) {
      return true;
    }

    return false;
  }

  bool isYesterDay() {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(days: 1));
    if (this.day == yesterday.day &&
        this.month == yesterday.month &&
        this.year == yesterday.year) {
      return true;
    }

    return false;
  }

  DateTime timeIn15Interval() {
    //String nearestHoursInterval = now.hour;
    //String nearestMinuteInterval = now.minute;
    // round to nearest 15 minutes
    int hoursInterval = this.hour;
    int minuteInterval = this.minute;
    if (this.minute % 15 != 0) {
      minuteInterval += 15 - (this.minute % 15);
    }

    if (minuteInterval > 59) {
      hoursInterval += 1;
      minuteInterval = 00;
    }

    DateFormat dateFormat = DateFormat('HH:mm');
    DateTime currentTime = dateFormat.parse('$hoursInterval:$minuteInterval');
    // String todaysTime = DateFormat.Hm().format(dt);
    return currentTime;
  }

  String timeString() {
    if (this != null) {
      
      var formatter = DateFormat('hh:mm a');
      return formatter.format(this);
    }
    return '';
  }

  String dateDay() {
    if (this == null) {
      return '';
    }
    var formatterDay = DateFormat('dd');
    return formatterDay.format(this);
  }

  String dateMonth() {
    if (this == null) {
      return '';
    }
    var formatterMonth = DateFormat('MMMM');
    return formatterMonth.format(this);
  }

  // String dayName(isFullName) {
  //   var formatter = DateFormat(isFullName ? 'EEEE' : 'E');
  //   return formatter.format(this);
  // }

  String dateDifferenceInHours(DateTime dateToCompare) {
    int diff = this.difference(dateToCompare).inHours;
    if (diff > 24) {
      diff = this.difference(dateToCompare).inDays;
      return '${diff}d left';
    }
    return '${diff}h left';
  }

  String timeStringIn24Format() {
    DateFormat dateFormat = DateFormat('HH:mm');
    DateTime currentTime = dateFormat.parse('${this.hour}:${this.minute}');
    String todaysTime = DateFormat.Hm().format(currentTime);
    return todaysTime;
  }

  DateTime dateForTime(DateTime time) {
    DateTime dateTime =
        DateTime(this.year, this.month, this.day, time.hour, time.minute);
    return dateTime;
  }

  DateTime dateConvert(String time) {
    DateTime timeOfDay = DateFormat("HH:mm").parse(time);

    DateTime dateTime = DateTime(
        this.year, this.month, this.day, timeOfDay.hour, timeOfDay.minute);
    return dateTime;
  }

  DateTime addDay(int days) {
    DateTime newDate = DateTime(this.year, this.month, this.day + days);
    return newDate;
  }

  DateTime addMinutes(int minutes) {
    DateTime newDate = DateTime(
        this.year, this.month, this.day, this.hour, this.minute + minutes);
    return newDate;
  }

  DateTime minusMinutes(int minutes) {
    DateTime newDate = DateTime(
        this.year, this.month, this.day, this.hour, this.minute - minutes);
    return newDate;
  }

  DateTime addMonth(int value) {
    DateTime newDate = DateTime(this.year, this.month + value, this.day);
    return newDate;
  }

  String timeAfter({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);

    if (difference == 0) {
      return 'AppConstants.today';
    } else if (difference == 1) {
      return 'AppConstants.tomorrow';
    } else {
      var formatter = DateFormat('MMM dd');
      return formatter.format(this);
    }
  }

  String timeAgo({bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(this);

    if (difference.inDays > 360) {
      final DateFormat formatter = DateFormat('MMM dd yyyy');
      return formatter.format(this);
    } else if (difference.inDays > 8) {
      final DateFormat formatter = DateFormat('MMM dd');
      return formatter.format(this);
    } else if ((difference.inDays / 7).floor() >= 1) {
      return numericDates ? '1 week' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} d';
    } else if (difference.inDays >= 1) {
      return numericDates ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return numericDates ? '1 h' : 'h';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} m';
    } else if (difference.inMinutes >= 1) {
      return numericDates ? '1 m' : '1 m';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'Just now';
    }
  }

  bool isEqualDate(DateTime nextDate){
    return this.year == nextDate.year &&
        this.month == nextDate.month &&
        this.day == nextDate.day;
  }
}
