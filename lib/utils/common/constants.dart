import 'package:easy_localization/easy_localization.dart';
import 'package:energym/main.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

String currentUserID = '';

enum HealthkitDays { today, days7, days30 }

enum WorkoutType {
  resistance,
  watts,
  calories,
  cadence,
  activityMinutes,
  energyGenerated,
  caloriesBurend
}

class ImgConstants {
  //Splash
  static const String splash = 'assets/other/splash.png';
  static const String backArrow = 'assets/images/svg/ic_back_arrow.svg';
  static const String close = 'assets/images/svg/ic_close.svg';
  static const String splashLogo = 'assets/images/png/splash_logo.png';
  static const String humanPower = 'assets/images/svg/human_power.svg';
  static const String intro1 = 'assets/images/png/intro1.png';
  static const String intro2 = 'assets/images/png/intro2.png';
  static const String intro3 = 'assets/images/png/intro3.png';
  static const String unpaired = 'assets/images/png/attachment.png';
  static const String paired = 'assets/images/png/paired.png';
  static const String indoorbike = 'assets/images/png/indoorbike.png';
  static const String tickmarkbike = 'assets/images/png/Tickmarkbike.png';
  static const String searchingBLE = 'assets/images/png/searchingble.png';
  static const String bluetoothicon = 'assets/images/png/bluetoothicon.png';
  static const String qrscan = 'assets/images/png/qrscan.png';

  static const String imagePlaceholder =
      'assets/images/png/image_placeholder.png';
  static const String nameLogo = 'assets/images/png/ic_name_logo.png';
  static const String downArrow = 'assets/images/svg/ic_down_arrow.svg';
  static const String apple = 'assets/images/svg/ic_apple.svg';
  static const String facebook = 'assets/images/svg/ic_facebook.svg';
  static const String gmail = 'assets/images/svg/ic_gmail.svg';
  static const String checkmark = 'assets/images/svg/ic_checkd.svg';
  static const String camera = 'assets/images/svg/ic_camera.svg';
  static const String profileVector1 = 'assets/images/svg/ic_vector1.svg';
  static const String profileVector2 = 'assets/images/svg/ic_vector2.svg';
  static const String profileVector3 = 'assets/images/svg/ic_vector3.svg';
  static const String profileVector4 = 'assets/images/svg/ic_vector4.svg';
  static const String galary = 'assets/images/svg/ic_gallary.svg';
  static const String largeCamera = 'assets/images/svg/large_camera.svg';
  static const String largeGalary = 'assets/images/svg/large_gallary.svg';
  static const String largeSettings = 'assets/images/svg/large_settings.svg';
  static const String locationPin = 'assets/images/svg/ic_location_pin.svg';
  static const String largeProfileSuccess =
      'assets/images/svg/large_profile_success.svg';
  static const String icPowerOn = 'assets/images/svg/ic_power_on.svg';

  static const String tabDashboard = 'assets/images/svg/ic_tab_dashboard.svg';
  static const String tabCommunity = 'assets/images/svg/ic_tab_community.svg';
  static const String tabWorkout = 'assets/images/svg/ic_tab_workout.svg';
  static const String tabMarketPlace =
      'assets/images/svg/ic_tab_market_place.svg';
  static const String notification = 'assets/images/svg/ic_notification.svg';

  static const String logoR = 'assets/images/png/logo_r.png';
  static const String icSettings = 'assets/images/svg/ic_settings.svg';
  static const String sweatCoin = 'assets/images/svg/ic_sweatcoin.svg';

  static const String light = 'assets/images/svg/ic_light.svg';
  static const String battery = 'assets/images/svg/ic_battery.svg';
  static const String eBike = 'assets/images/svg/ic_charging.svg';
  static const String search = 'assets/images/svg/ic_search.svg';
  static const String addFollower = 'assets/images/svg/ic_add_followers.svg';
  static const String share = 'assets/images/svg/ic_share.svg';
  static const String userPlaceHolder =
      'assets/images/svg/ic_user_placeholder.svg';
  static const String optionMenu = 'assets/images/svg/ic_option_menu.svg';
  static const String unlike = 'assets/images/svg/ic_like.svg';
  static const String like = 'assets/images/svg/ic_liked_filled.svg';
  static const String comment = 'assets/images/svg/ic_comment.svg';
  static const String checkMarkCircle =
      'assets/images/svg/ic_circle_check_mark.svg';
  static const String uncheckMarkCircle =
      'assets/images/svg/ic_circle_uncheck_mark.svg';
  static const String logout = 'assets/images/svg/ic_logout.svg';

  static const String privacy = 'assets/images/svg/ic_privacy.svg';
  static const String lock = 'assets/images/svg/ic_lock.svg';
  static const String support = 'assets/images/svg/ic_support.svg';
  static const String forwardArrow = 'assets/images/svg/ic_forward_arrow.svg';
  static const String delete = 'assets/images/svg/ic_delete.svg';
  static const String nodata = 'assets/images/svg/nodata.svg';

  static const String box = 'assets/images/svg/box.svg';
  static const String Path = 'assets/images/svg/Path.svg';
  static const String arrowftp = 'assets/images/png/arrowftp.png';

  static const String deviceConnectionIntro1 =
      'assets/images/png/device_connection_intro1.png';
  static const String deviceConnectionIntro2 =
      'assets/images/png/device_connection_intro2.png';
  static const String deviceConnectionIntro3 =
      'assets/images/png/device_connection_intro3.png';
  static const String battery2 = 'assets/images/svg/ic_battery_2.svg';
  static const String burn = 'assets/images/svg/ic_fire.svg';
  static const String timer = 'assets/images/svg/ic_timer.svg';
  static const String plus = 'assets/images/svg/ic_plus.svg';
  static const String minus = 'assets/images/svg/ic_minus.svg';
  static const String cycle = 'assets/images/svg/ic_cycle.svg';
  static const String backArrowSmall =
      'assets/images/svg/ic_back_arrow_small.svg';
  static const String workoutbg = 'assets/images/png/workoutbg.png';
  static const String tree = 'assets/images/png/tree.png';
  static const String planetGif = 'assets/images/gif/planet.gif';

  static const String loginRegenImage =
      'assets/images/png/login_regen_image.png';
  static const String boxImage = 'assets/images/png/box.png';
  static const String textfieldBg = 'assets/images/png/textfield_bg.png';
  static const String avatar = 'assets/images/png/Avatar.png';
  static String plusButton = 'assets/images/png/plusButton.png';
  static String sliderThumb = 'assets/images/png/sliderThumb.png';

  static String level1 = 'assets/images/level/1.png';
  static String level2 = 'assets/images/level/2.png';
  static String level3 = 'assets/images/level/3.png';
  static String level4 = 'assets/images/level/4.png';
  static String level5 = 'assets/images/level/5.png';
  static String level6 = 'assets/images/level/6.png';
  static String level7 = 'assets/images/level/7.png';
  static String level8 = 'assets/images/level/8.png';
  static String level9 = 'assets/images/level/9';
  static String level10 = 'assets/images/level/10.png';
}

// declare your lottie constant over here
class LottieConstants {
  //static const String loader = 'assets/lottie/8383-loader.json';
  //static const String loader = 'assets/lottie/loder.json';
  static const String loader = 'assets/lottie/loder_new.json';
  static const String workoutComplete = 'assets/lottie/workout_complete.json';
}

// declare your API Path over here
// Use -> APIConstant.baseUrl
// Use -> APIConstant.requestKeys.email
class APIConstant {
  static RequestKeys requestKeys = const RequestKeys();
  static ResponseKeys responseKeys = const ResponseKeys();

  static String baseUrl = 'Your Project base url';
  static String login = 'oauth/login';
  static String signUp = 'oauth/register';
  static String logout = 'oauth/logout';
  static String createSweatCoin = '/api/platform/v1/users.json';
  static String getSweatCoinUser = '/api/platform/v1/users/';
  static String rewardSweatCoinUser = '/api/platform/v1/users/reward.json';
}

class RequestKeys {
  const RequestKeys();
  String get clientId => 'client_id';
  String get payload => 'payload';
}

class ResponseKeys {
  const ResponseKeys();
  String get data => 'data';
  String get status => 'status';
}

//declare your error constant message over here as well as in language JSON file
class MsgConstants {
  static String password = 'Please enter password'.tr();
  static String cpassword = 'Please enter confirm password'.tr();
  static String passwordnotmatch = 'Confirm password does not match'.tr();
  static String enterValidPwd =
      'Password length must be 8 characters long and contains uppercase, lowercase, digits, special characters'
          .tr();
  static String enterMobileCode = 'Please enter country code'.tr();
  static String enterMobileNumber = 'Please enter phone number'.tr();
  static String enterValueMobileNumber = 'Please enter valid phone number'.tr();
  static String enterFullName = 'Please enter full name'.tr();
  static String enterEmail = 'Please enter email address'.tr();
  static String enterValidEmail = 'Please enter valid email address'.tr();
  static String enterUserName = 'Please enter user name'.tr();
  static String enterValidUserName = 'Please enter valid user name'.tr();
  static String userNameExists =
      'User name already exists. Please choose another user name'.tr();
  static String selectProfilePicture = 'Please select profile picture'.tr();
  static String selectLocation = 'Please select location'.tr();
  static String selectHeight = 'Please select height'.tr();
  static String selectWeight = 'Please select weight'.tr();
  static String selectBirthday = 'Please select birthDay'.tr();
  static String selectGender = 'Please select gender'.tr();
  static String selectCaloriesGoal = 'Please select calories burn goal'.tr();
  static String enterGroupName = 'Please enter group name'.tr();
  static String emailExists =
      'Email address is already exists. Please enter another email'.tr();
  static String selectFTP = 'Please select FTP Level'.tr();
  static String testmin = 'Please choose test exercise minutes'.tr();
  static String groupjoin = 'Group joined successfully'.tr();
}

class AppConstants {
  static String noSongs = 'No Songs'.tr();
  static String updateGroup = 'Update Group'.tr();
  static String update = 'Update'.tr();
  static String invited = 'Invited'.tr();
  static String removeMembr = 'Remove Member'.tr();
  static String invitemember = 'Invite Member to Group'.tr();
  static String join = 'JOIN'.tr();
  static String publicGroups = 'Public Groups'.tr();
  static String exit = 'Exit'.tr();
  static String leaveGroup = 'Leave Group'.tr();
  static String editGroup = 'Edit Group Info'.tr();
  static String groupSettings = 'Group Settings'.tr();
  static String joinpublicgroup = ' Join a public group '.tr();
  static String editGoal = 'Edit your goal'.tr();
  static String currentGoal = 'Current Calorie Goal'.tr();
  static String newGoal = 'New Goal'.tr();
  static String saveWorkout = 'Save Workout'.tr();
  static String saveGoal = 'Save Goal'.tr();

  static String editgoal = 'Edit goal'.tr();
  static String resistanceLevel = 'Resistance Level'.tr();
  static String startWorkout = 'Start Workout'.tr();
  static String hitmydailygoal = 'Hit my daily goal'.tr();
  static String calGoal = 'Calorie Goal'.tr();

  static String totalWatts = 'Total Watts'.tr();
  static String avWattsAndFTP = 'Av. Watts / FTP'.tr();
  static String climbCondition = 'Climb Condition'.tr();
  static String pharaomones = 'Pharaomones'.tr();
  static String allPain = 'All Pain, All Gain'.tr();
  static String holyHiit = 'Holy Hiit'.tr();
  static String shedHappens = 'Shed Happens'.tr();

  static String female = 'Female'.tr();
  static String male = 'Male'.tr();
  static String sex = 'sex'.tr();
  static String yourWorkout = 'your workout'.tr();
  static String chooseanOption = 'Choose an option'.tr();
  static String customTime = 'Custom Time'.tr();

  static String oldFTP = 'Old FTP'.tr();
  static String newFTP = 'New FTP'.tr();
  static String greenZoneSummary = 'Green Zone Summary'.tr();
  static String currentFTP = 'Current FTP'.tr();
  static String startCalibration = 'Start Calibration'.tr();
  static String liveCalibration = 'Live Calibration'.tr();

  static String mon = 'MON'.tr();
  static String tue = 'TUE'.tr();
  static String wed = 'WED'.tr();
  static String thu = 'THU'.tr();
  static String fri = 'FRI'.tr();
  static String sat = 'SAT'.tr();
  static String sun = 'SUN'.tr();
  static String yourperformance = 'your performance'.tr();
  static String accountCreatedSuccessfully =
      'Your account has been successfully created.'.tr();
  static String forgotpassword = 'Forgot password?'.tr();
  static String submit = 'Submit'.tr();
  static String emailsent = 'Please check mail to reset password'.tr();
  static String forgotPassword = 'Forgot Password'.tr();
  static String registration = 'Registration'.tr();
  static String cpassword = 'Confirm Password'.tr();
  static String password = 'Password'.tr();
  static String fullName = 'Full Name'.tr();
  static String signup = 'Signup'.tr();
  static String login = 'Login'.tr();
  static String register = 'Register'.tr();
  static String email = 'Email'.tr();
  static String welcomeOnly = 'WELCOME'.tr();
  static String disconnectBike = 'Do you want to disconnect bike?'.tr();
  static String appName = 'energym'.tr();
  static String bleMNotConnectedessage =
      "Bike is not connected with energym, please connect first!".tr();
  static String bleDisconnectes =
      "Bike is disconnected, pleae connect and start exercise again".tr();
  static String bleDataNotAccessible =
      "This BLE device having advertisement is not accessible. ".tr();
  static String bleDevice =
      "This QR is not connectable, so please reset device or use proper QR code."
          .tr();
  static String intro1Title =
      'Laculis suspendisse turpis sodales ulla uspendisse'.tr();
  static String intro2Title = 'Ipsum risus posuere habitant condimentum'.tr();
  static String intro3Title =
      'Semper sem ante sociis a vestibulum posuere'.tr();
  static String welcomeToenergym = 'Welcome to energym'.tr();
  static String letsGo = 'Hi there! Let’s get you setup.'.tr();
  static String msgPhoneNumber = 'CONTINUE WITH PHONE NUMBER'.tr();
  static String code = 'Code'.tr();
  static String mobile = 'e.g. 1234567'.tr();
  static String phoneNumber = 'Phone number'.tr();

  static String search = 'Search'.tr();
  static String agreeMsg =
      'By tapping on continue, you are agreeing to the'.tr();
  static String termsOfUse = 'Terms of use'.tr();
  static String and = ' and '.tr();
  static String privacyPolicy = 'Privacy Policy'.tr();
  static String or = 'OR'.tr();
  static String veryfyPhone = 'Verify Phone'.tr();
  static String veryfyPhoneMsg =
      'We’ve sent you a code to verify your phone number'.tr();
  static String dontHaveCode = 'I didn’t receive a code!'.tr();
  static String redend = 'Resend'.tr();
  static String of = 'of'.tr();
  static String completeYourProfileTitle = 'Complete Your Profile'.tr();
  static String hintFullName = 'FULL NAME'.tr();
  static String hintEmailAddress = 'EMAIL ADDRESS'.tr();
  static String hintUserName = 'USERNAME'.tr();
  static String hintProfilePicture = 'Profile Picture'.tr();
  static String hindSelectFromBelow = 'SELECT FROM BELOW'.tr();
  static String hintLocation = 'LOCATION'.tr();

  static String hintHeight = 'HEIGHT'.tr();
  static String cm = 'cm'.tr();
  static String feet = 'feet'.tr();

  static String hintWeight = 'WEIGHT'.tr();
  static String kg = 'kg'.tr();
  static String pound = 'pound'.tr();

  static String hintDateOfBirth = 'DATE OF BIRTH'.tr();

  static String activityLevelTitle =
      'What is your current activity level?'.tr();
  static String activityLevelMsg1 = 'being not at all active and'.tr();
  static String activityLevelMsg2 = 'being highly active'.tr();

  static String dailyGoalTitle = 'Choose your daily activity goal.'.tr();
  static String dailyGoalMsg =
      'How many days per week do you aim to exercise?'.tr();

  static String hintCalories = 'CALORIE'.tr();
  static String calorieGoalTitle = 'Select your calorie burn goal'.tr();
  static String calorieGoalMsg =
      'How many calories would you like to burn each day?'.tr();
  static String calories = 'Calories'.tr();

  static String hintMinutes = 'MINUTES'.tr();
  static String minutesGoalTitle = 'Select your active minutes goal'.tr();
  static String minutesGoalMsg =
      'How many minutes would you like to workout each day?'.tr();
  static String minutes = 'Minutes'.tr();

  static String hintEnergyGenerate = 'Energy goal'.tr();
  static String energyGoalTitle = 'Select your energy generation goal'.tr();
  static String energyGoalMsg =
      'How much energy would you like to generate each day?'.tr();

  static String titleFTP = 'What is your current FTP?'.tr();
  static String hintFTP = 'FTP'.tr();
  static String orSelectFTP = 'OR SELECT'.tr();
  static String beginnerFTP = 'Beginner'.tr();
  static String mediumFTP = 'Medium'.tr();
  static String athleteFTP = 'Athlete'.tr();
  static String ftpDescription =
      'Don’t worry if you’re not sure of your FTP score, we’ll take you straight to the Green Zone after setting up your profile, so you can complete a calibration.'
          .tr();

  static String watt = 'Watts'.tr();
  static String camera = 'Camera'.tr();
  static String gallery = 'Gallery'.tr();
  static String yourPlanet = 'Your Planet'.tr();

  static String galleryPermissionTital = 'Gallery Permission'.tr();
  static String galleryPermissionMsg =
      'This app needs gallery access to take pictures for upload user profile photo'
          .tr();

  static String cameraPermissionTital = 'Camera Permission'.tr();
  static String cameraPermissionMsg =
      'This app needs camera access to take pictures for upload user profile photo'
          .tr();
  static String appSetting = 'Settings'.tr();

  static String locationServiceTitle = 'Cannot Find GPS Signal'.tr();
  static String locationServiceMessage =
      'Turn on Location Services in Setting > Privacy to allow us to find current address.'
          .tr();
  static String locationPermissionTitle = 'Location Permission Denied'.tr();
  static String locationPermissionMessage =
      'Update your location access settings to "While Using the App" or "Always"'
          .tr();

  static String contactPermissionTital = 'Contact Permission'.tr();
  static String contactPermissionMsg =
      'This app needs Contact access to invite user and send refrel link'.tr();

  static String activityLevelMin = '0 '.tr();
  static String activityLevelMix = ' 5 '.tr();

  static String somethingWronge = 'Something went wronge'.tr();
  static String profileCreateSuccessTitle =
      'Your profile has been successfully created.'.tr();
  static String profileCreateSuccessMsg =
      'Parturient enim nam orci imperdiet facilisi hac laoreet vulputate id ac adipiscing nibh varius aliquet aenean scelerisque.'
          .tr();

  static String tabDashboard = 'Dashboard'.tr();
  static String tabCommunity = 'Community'.tr();
  static String tabWorkout = 'Workout'.tr();
  static String tabMarketplace = 'Marketplace'.tr();
  static String tabProfile = 'Profile'.tr();
  static String myProfile = 'My Profile'.tr();
  static String followers = 'Followers'.tr();
  static String editProfile = 'Edit Profile'.tr();

  static String global = 'Global'.tr();
  static String localCountry = 'My Country'.tr();
  static String regional = 'Regional'.tr();

  static String errorInvalidMoblile = 'Invalid phone number'.tr();
  static String errorInvalidMoblileMsg =
      'Please enter valid phone number with country code.'.tr();

  static String errorInvalidCode = 'Invalid code'.tr();
  static String errorInvalidCodeMsg =
      'The SMS verification code is invalid.'.tr();

  static String welcome = 'Welcome, '.tr();
  static String today = 'Today'.tr();
  static String sevenDays = '7 Days'.tr();
  static String thirtyDays = '30 Days'.tr();

  static String activeMinutes = 'Active Minutes'.tr();
  static String energyGenerated = 'Energy Generated'.tr();
  static String caloriesBurned = 'Calories Burned'.tr();

  static String energyGeneratedMsg = 'Energy you’ve generated could...'.tr();
  static String lightHome = 'Light a home for '.tr();
  static String hours = ' hours'.tr();

  static String chargePhone = 'Charge your phone '.tr();
  static String times = ' times'.tr();

  static String chargeEbike = 'Charge an ebike '.tr();

  static String feed = 'Feed'.tr();
  static String leaderboard = 'Leaderboard'.tr();

  static String group = 'Group'.tr();
  static String searchFollowers = 'Search Followers'.tr();
  static String addFollower = 'Add Follower'.tr();

  static String searchLeaderboard = 'Search Leaderboard'.tr();

  static String searchGroups = 'Search by Group Name'.tr();
  static String addGroup = 'Add Group'.tr();

  static String addOrInvite = 'Add or Invite Followers'.tr();
  static String byInvitingFollower =
      'By Inviting follower, you can earn 5 Sweatcoins when they sign up.'.tr();
  static String searchBy = 'Search by Username or Email Address'.tr();
  static String shareYourReferralLink = 'Share your referral link:'.tr();
  static String eran =
      'And earn 5 Sweatcoins each time someone signs up using your link.'.tr();
  static String copy = 'Copy'.tr();
  static String shareViaSocial = 'Share via Social'.tr();
  static String readMore = 'Read More'.tr();
  static String invite = 'Invite'.tr();
  static String follow = 'Follow'.tr();
  static String unfollow = 'Unfollow'.tr();

  static String followMsg = 'Followed successfully'.tr();
  static String unfollowMsg = 'Unfollowed successfully'.tr();

  static String error = 'Failed'.tr();
  static String errotMsg = 'Please try again after sometime!'.tr();
  static String shareYourThoughts = 'Share your thoughts'.tr();

  static String addPhoto = 'Add Photo'.tr();
  static String whatOnYourMind = 'What’s on your mind?'.tr();

  static String postTitle = 'Post'.tr();
  static String postMsg = 'Post created successfully'.tr();

  static String workoutTitle = 'Workout'.tr();
  static String workoutAlertMsg = 'Workout saved successfully'.tr();

  static String noInternetTitle = 'Connection'.tr();
  static String noInternetMsg =
      'It seems to be no active wifi or data connection'.tr();

  static String enterReport = 'Please enter your message'.tr();
  static String send = 'Send'.tr();
  static String writeYourReport = 'Write your report...'.tr();
  static String reportPost = 'Report Post'.tr();
  static String reportUser = 'Report User'.tr();
  static String dismiss = 'Dismiss'.tr();
  static String delete = 'Delete'.tr();
  static String deletePostMsg = "Are you sure you want to delete?".tr();
  static String deletePostSuccess = 'Post deleted successfully'.tr();
  static String writeYourComment = 'Write your comment...'.tr();
  static String hintGroupPicture = 'Group Picture'.tr();
  static String hintGroupName = 'Group Name'.tr();
  static String participant = 'Participant'.tr();
  static String groupTitle = 'Group'.tr();
  static String groupMsg = 'Group created successfully'.tr();
  static String groupUpdateMsg = 'Group update successfully'.tr();
  static String profile = 'Profile'.tr();
  static String settings = 'Settings'.tr();
  static String logout = 'Logout'.tr();
  static String loguoutMsg = "Are you sure you want to logout?".tr();
  static String loguoutSingleDevice =
      "You have been logged in to another device with this phone number.".tr();
  static String privacy = 'Privacy'.tr();
  static String security = 'Security'.tr();
  static String regen = 'RE:GEN'.tr();
  static String support = 'Support'.tr();
  static String deleteMyAccount = 'Delete My Account'.tr();
  static String version = 'Version'.tr();
  static String copyRight = 'energym © Copyright 2021'.tr();
  static String connected = 'Connected'.tr();
  static String notconnected = 'NotConnected'.tr();

  static String deleletAccountQuestion = 'Delete My Account?'.tr();
  static String deleteAccountMsg =
      'Are you sure you want to delete your account. All of your information from our database will be removed. This cannot be undone in future.'
          .tr();
  static String deleteAccountSuccessMsg = 'Account deleted successfully.'.tr();

  static String isPoststs = '’s Posts'.tr();
  static String groups = 'Groups'.tr();
  static String noData = 'No data'.tr();

  static String deviceConnectionIntro1Title = 'Setup your RE:Gen bike'.tr();
  static String deviceConnectionIntro2Title = 'Setting your device'.tr();
  static String deviceConnectionIntro3Title = 'All done, get riding'.tr();

  static String deviceConnectionIntro1Msg =
      'Once setup, insert Ohm battery into the cradle and slowly spin Pedal until blue light pulses on the Ohms light bar, then press “Get Started” button'
          .tr();
  static String deviceConnectionIntro2Msg =
      'Open settings on your device - from there locate the wifi tab. It may take a minute for your RE:GEN bike to display, after connecting to your RE:GEN bike, your Ohm battery lighr bar should be a solid blue, please return to energym app.'
          .tr();
  static String deviceConnectionIntro3Msg =
      'Your device is successfully connected.'.tr();
  static String needHelp = 'Need help? '.tr();
  static String clickHere = 'Click here'.tr();

  static String setupMyREGEN = 'Setup my RE:GEN'.tr();
  static String seconds = 'Seconds'.tr();

  static String getStarted = 'Get Started'.tr();
  static String continueStr = 'Continue'.tr();
  static String continueWithApple = 'Continue with Apple'.tr();
  static String continueWithFacebook = 'Continue with Facebook'.tr();
  static String continueWithGmail = 'Continue with Google'.tr();
  static String next = 'Next'.tr();
  static String cancel = 'Cancel'.tr();
  static String done = 'Done'.tr();
  static String agree = 'I Agree'.tr();
  static String save = 'Save'.tr();
  static String skip = 'Skip'.tr();
  static String ok = 'Ok'.tr();
  static String post = 'Post'.tr();
  static String create = 'Create'.tr();
  static String goToMyWorkout = 'Go to My Workout'.tr();
  static String workout = 'Workout'.tr();
  static String PickYourWorkout = 'Pick your workout'.tr();

  static String buildMyWorkOut = 'Build My Workout'.tr();
  static String challengeFollower = 'Challenge Followers'.tr();
  static String goHeadToHead = 'Go Head-2-Head'.tr();
  static String yourPerformance = 'Your Performance'.tr();
  static String starMyWorkOut = 'Start My Workout'.tr();

  // Manish
  static String buildYourWorkout = 'Build Your Workout'.tr();
  static String HitMyDailyGoal = 'Hit My Daily Goal'.tr();
  static String challengeTheLeaderBoard = 'Challenge The Leaderboard'.tr();
  static String greenZone = 'Green Zone'.tr();
  static String challengeFriends = 'Challenge Friends'.tr();
  static String onDemand = 'On Demand'.tr();
  static String instantWorkout = 'Instant Workout'.tr();

  static String tCR = 'Time, calories, resistence'.tr();
  static String caloriesGoal = 'Calories Goal'.tr();
  static String rightForYourSpot = 'Fight for your spot'.tr();
  static String comingSoon = 'Coming Soon'.tr();
  static String startNow = 'Start now'.tr();

  static String pairBikeBlutooth = 'Pair your bike using Bluetooth'.tr();
  static String pairBikeQR = "Scan your bike's QR".tr();
  static String recommendedgym = '(Recommended for Gym use)'.tr();
  static String regenfound = 'RE:GENs\'s found'.tr();
  static String selectRide = 'Select your ride'.tr();
  static String searching = 'Searching...'.tr();
  static String thisisfaster =
      'This\'ll be faster than you can say \"bring it Ohm\"'.tr();
  static String connect = 'CONNECT'.tr();
  static String disconnect = 'Disconnect'.tr();

  static String hitMyDaily = 'Hit My Daily'.tr();
  static String calorieGoal = 'Calorie Goal'.tr();
  static String bestMy = 'Beat My'.tr();
  static String personalBest = 'Personal Best'.tr();
  static String min = 'Min'.tr();
  static String cal = 'Cal'.tr();
  static String youGotThis = 'You’ve got this!'.tr();
  static String duration = 'Duration'.tr();
  static String sweatCoins = 'Sweatcoins'.tr();
  static String watts = 'Watts'.tr();
  static String cals = 'cals'.tr();
  static String rpm = 'rpm'.tr();
  static String avwatts = 'Av. Watts'.tr();
  static String relax = 'Relax'.tr();
  static String completeMyWorkout = 'Complete My Workout'.tr();
  static String liveWorkout = 'Live Workout'.tr();
  static String resistance = 'Resistance'.tr();
  static String cadence = 'Cadence'.tr();
  static String workoutSummary = 'Workout Summary'.tr();
  static String wattsGenerated = 'Watts Generated'.tr();
  static String energyGeneratedAnd = 'Energy\nGenerated'.tr();
  static String caloriesBurnedAnd = 'Calories\nBurned'.tr();
  static String activeMinutesAnd = 'Active\nMinutes'.tr();

  static String sweatcoinsEarned = 'sweatcoins\nearned'.tr();
  static String milesCovered = 'Miles\nCovered'.tr();
  static String shareWithFollower = 'Share with Follower'.tr();
  static String youSmashedIt = 'You Smashed It'.tr();
  static String backToDashboard = 'Back to Dashboard'.tr();

  static String workoutMsg = 'Workout completed'.tr();
  static String currentBalance = 'Current balance'.tr();
  static String allTransactions = 'All Transactions'.tr();

  static String workoutShare = 'Workout share'.tr();
  static String workoutShareMsg =
      'Do you want to share your today’s workout with your friend?'.tr();
  static String share = 'Share'.tr();
  static String smashedTodaysWorkout = 'Smashed today’s workout!'.tr();
}

class NavigationBarConstants {
  static String selectCountry = 'Select Country'.tr();
  static String termsOfUse = 'energym App Terms of Use'.tr();
  static String privacyPolicy = 'energym Privacy Policy'.tr();
  static String info = 'What is actitvity level'.tr();
  static String createPost = 'Create a Post'.tr();
  static String comments = 'Comments'.tr();
  static String notifications = 'Notifications'.tr();
  static String feed = 'Feed'.tr();
}

class AppKeyConstant {
  static String title = 'title';
  static String message = 'message';
  static String code = 'code';
  static String fromWhere = "";
  static String notificationRedirect = "Notification";
  static String sweatCoinClientIdProduction =
      'a568fe5f-2c1f-47db-84d8-207c0b4c275c';
  static String sweatCoinClientSecretProduction =
      'nvI7qb+UaHToHvLRJ0jsdFHJsOv+O82vml9rxGK7zkQ=';

  static String sweatCoinClientIdStaging =
      'a568fe5f-2c1f-47db-84d8-207c0b4c275c';
  static String sweatCoinClientSecretStaging =
      'j8qjyxWRL8E4jz4XqGxdPZCIhM7/DisYy9ctgzWlj4Y=';
}

class NotificationConstants {
  static const String notificationData = 'gcm.notification.data';
  static const String notificationTag = 'tag';
  static const String notificationName = 'name';
  static const String notificationDataId = '_id';
  static const String notificationDataAndroid = 'data';

  static const String notificationAps = 'aps';
  static const String notificationMessage = 'message';
  static const String notificationMoredata = 'extra';
}

SharedPrefsHelper sharedPrefsHelper = serviceLocator!<SharedPrefsHelper>();

class LargeImages {
  static Widget get settings {
    const Size size = Size(300, 254);
    return AspectRatio(
      //aspectRatio:  ,
      aspectRatio: size.aspectRatio,
      child: SvgPictureRecolor.asset(
        ImgConstants.largeSettings,
        width: size.width,
        height: size.height,
        boxfix: BoxFit.fill,
      ),
    );
  }
}

FlutterBlue flutterInstance = FlutterBlue.instance;

class LevelVideoName {
  static String levelVideoName1 = 'LAVA';
  static String levelVideoName2 = 'VOLCANIC';
  static String levelVideoName3 = 'FORMING';
  static String levelVideoName4 = 'ROCKY';
  static String levelVideoName5 = 'DESERT';
  static String levelVideoName6 = 'OASE';
  static String levelVideoName7 = 'MUDDY';
  static String levelVideoName8 = 'SWAMP';
  static String levelVideoName9 = 'FOREST';
  static String levelVideoName10 = 'GREEN';
}

class LevelLevelName {
  static String levelLevelName1 = 'Green-dreamer';
  static String levelLevelName2 = 'Power-hustler';
  static String levelLevelName3 = 'Leading the charge';
  static String levelLevelName4 = 'Power-player';
  static String levelLevelName5 = 'Grow-getter';
  static String levelLevelName6 = 'Live Wire';
  static String levelLevelName7 = 'Planeteer';
  static String levelLevelName8 = 'Power-gator';
  static String levelLevelName9 = 'Amp-leaf-ier';
  static String levelLevelName10 = 'Supercharger';
}
