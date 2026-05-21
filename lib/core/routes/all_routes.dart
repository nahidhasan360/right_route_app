import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:right_routes/views/home/create_new_routes/homescreen.dart';
import '../../views/account/account_delete.dart';
import '../../views/account/are_you_sure_delete_this_account.dart';
import '../../views/account/change_mail/change_email.dart';
import '../../views/account/change_password/change_password.dart';
import '../../views/account/contact_support.dart';
import '../../views/account/email_saved.dart';
import '../../views/account/help.dart';
import '../../views/account/password_saved.dart';
import '../../views/authentication/create_an_account/create_an_account.dart';
import '../../views/authentication/enter_email_for_delete/enter_email_for_delete.dart';
import '../../views/authentication/enter_email_screen/enter_email_screen.dart';
import '../../views/authentication/get_started_screen/get_started_screen.dart';
import '../../views/authentication/login_account/email_edit/email_edit.dart';
import '../../views/authentication/login_account/login_account.dart';
import '../../views/authentication/login_account/otp_verification/otp_verification_binding.dart';
import '../../views/authentication/login_account/otp_verification/otp_verification_screen.dart';
import '../../views/authentication/privacy_policy/privacy_policy.dart';
import '../../views/authentication/subscriber_agreement/subscriber_agreement.dart';
import '../../views/authentication/terms_of_service/terms_of_service.dart';
import '../../views/authentication/we_willbe_login/we_logged_you.dart';
import '../../views/home/account_screen/account_screen.dart';
import '../../views/home/create_new_routes/confirm_your_routes/confirm_controller.dart';
import '../../views/home/create_new_routes/confirm_your_routes/confirm_your_routes.dart';
import '../../views/home/create_new_routes/permit_list/permit_list_screen.dart';
import '../../views/home/create_new_routes/permit_list/view_permit.dart';
import '../../views/home/create_new_routes/route_create_screen/add_permit/add_permit.dart';
import '../../views/home/create_new_routes/permit_list/add_permit_segment/add_permit_segment.dart';
import '../../views/home/create_new_routes/permit_list/add_permit_segment/confirm_segment/confirm_your_route_for_segment.dart';
import '../../views/home/create_new_routes/permit_list/add_permit_segment/confirm_segment/confirm_your_route_segment_controller.dart';
import '../../views/home/history_screen/history_screen.dart';
import '../../views/home/team_manager/team_manager.dart';
import '../../views/splash_screen/splash_screen.dart';
import '../../views/subscription_plans/choose_team_plan/choose_team_plan.dart';
import '../../views/subscription_plans/choose_your_plan/choose_your_plan.dart';
import '../../views/subscription_plans/individual_team.dart';

class AppRoutes {
  // dialog box
  static const String subscriberAgreement = "/SubscriberAgreement";

  static const String splashScreen = "/SplashScreen";
  static const String getStartedScreen = "/GetStartedScreen";
  static const String enterEmailForDelete = "/EnterEmailForDelete";

  // ================== Enter Email screen =====================//
  static const String enterEmailScreen = "/EnterEmailScreen";
  static const String createAccountScreen = "/CreateAnAccount";
  static const String loginAccount = "/LoginAccount";
  static const String emailEdit = "/EmailEdit";

  static const String otpVerificationScreen = "/OtpVerificationScreen";
  static const String weLoggedYou = "/WeLoggedYou";
  static const String individualTeam = "/IndividualTeam";
  static const String chooseYourPlan = "/ChooseYourPlan";
  static const String chooseATeamPlan = "/ChooseATeamPlan";

  // ================= home teamManager ===========================
  static const String homeScreen =
      "/Homescreen"; // Home screen route name (alias)
  static const String teamManager = "/TeamManager";
  static const String accountScreen = "/AccountScreen";
  static const String historyScreen = "/HistoryScreen";

  // account all routes
  static const String contactSupport = "/ContactSupport";
  static const String changeEmail = "/ChangeEmail";
  static const String emailSaved = "/EmailSaved";
  static const String changePassword = "/ChangePassword";
  static const String passwordSaved = "/PasswordSaved";
  static const String areYouSureDeleteThisAccount =
      "/AreYouSureDeleteThisAccount";
  static const String accountDelete = "/AccountDelete";
  static const String help = "/Help";
  static const String privacyPolicy = "/PrivacyPolicy";
  static const String termsModal = "/TermsModal";

  //  =================  permit selection screen  ======================

  static const String addPermitScreen = "/AddPermitScreen";
  static const String addPermitSegmentScreen = "/AddPermitSegmentScreen";
  static const String permitListScreen = "/PermitListScreen";
  static const String viewPermitScreen = "/ViewPermitScreen";

  static const String confirmYourRoutes = "/EditConfirmStartYourRoute";
  static const String confirmYourRouteForSegment = "/ConfirmYourRouteForSegment";

  // =============  edit - confirm - start route section ================

  // static const String teamManager ="/TeamManager";

  // ================ login Screen part ================================

  // bridge
  static List<GetPage> routes = [
    // dialog box
    // accounts ar routes
    GetPage(name: subscriberAgreement, page: () => SubscriberAgreement()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicy()),
    GetPage(name: termsModal, page: () => TermsModal()),
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: getStartedScreen, page: () => GetStartedScreen()),
    GetPage(name: enterEmailScreen, page: () => EnterEmailScreen()),
    GetPage(name: createAccountScreen, page: () => CreateAnAccount()),
    GetPage(name: loginAccount, page: () => LoginAccount()),
    GetPage(
      name: otpVerificationScreen,
      page: () => OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(name: emailEdit, page: () => EmailEdit()),

    // GetPage(
    //   name: otpVerificationScreen,
    //   page: () => OtpVerificationScreen(),
    //   binding: OtpVerificationBinding(),
    // ),
    GetPage(name: weLoggedYou, page: () => WeLoggedYou()),
    GetPage(name: individualTeam, page: () => IndividualTeam()),
    GetPage(name: chooseYourPlan, page: () => ChooseYourPlan()),
    GetPage(name: chooseATeamPlan, page: () => ChooseATeamPlan()),

    // HOME ROUTES (Navbar tabs)
    GetPage(name: homeScreen, page: () => Homescreen()),
    GetPage(name: teamManager, page: () => TeamManager()),
    GetPage(name: accountScreen, page: () => AccountScreen()),
    GetPage(name: historyScreen, page: () => HistoryScreen()),

    // Route creation flow
    GetPage(name: addPermitScreen, page: () => AddPermit()),
    GetPage(name: addPermitSegmentScreen, page: () => AddPermitSegment()),
    GetPage(name: permitListScreen, page: () => PermitListScreen()),
    GetPage(name: viewPermitScreen, page: () => ViewPermitScreen()),

    GetPage(
        name: confirmYourRoutes,
        page: () => EditConfirmStartYourRoute(),
        binding: BindingsBuilder(() => Get.lazyPut<ConfirmRouteController>(
            () => ConfirmRouteController()))),
    GetPage(
        name: confirmYourRouteForSegment,
        page: () => const ConfirmYourRouteForSegment(),
        binding: BindingsBuilder(() => Get.lazyPut<ConfirmYourRouteSegmentController>(
            () => ConfirmYourRouteSegmentController()))),

    // =============  edit - confirm - start route section ================
    // accounts all screen route
    GetPage(name: contactSupport, page: () => ContactSupport()),
    GetPage(name: changeEmail, page: () => ChangeEmail()),
    GetPage(name: emailSaved, page: () => EmailSaved()),
    GetPage(name: changePassword, page: () => ChangePassword()),
    GetPage(name: passwordSaved, page: () => PasswordSaved()),
    GetPage(
      name: areYouSureDeleteThisAccount,
      page: () => AreYouSureDeleteThisAccount(),
    ),
    GetPage(name: accountDelete, page: () => AccountDelete()),
    GetPage(name: enterEmailForDelete, page: () => EnterEmailForDelete()),
    GetPage(name: help, page: () => Help()),
  ];
}
