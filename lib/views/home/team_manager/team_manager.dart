import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';

import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';

// ============================================================
// SCREENUTIL RULES (Design: 440x956)
// ============================================================
// .w   → horizontal dimension (width, horizontal padding/margin)
// .h   → vertical dimension (height, vertical padding/margin)
// .sp  → font size ONLY
// .r   → border radius ONLY
// ❌ NEVER use .h on lineHeight/height inside TextStyle — it's a multiplier
// ❌ NEVER use raw numbers for spacing — always .w or .h
// ============================================================

// ============================================================
// COLOR CONSTANTS
// ============================================================
class TeamManagerColors {
  static const Color primaryOrange = Color(0xffF58842);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkerBackground = Color(0xFF0F0F0F);
  static const Color borderColor = Color(0xFF3A3A3A);
}

// ============================================================
// CONTROLLER
// ============================================================
class TeamManagerController extends GetxController {
  final searchController = TextEditingController();
  final emailInputController = TextEditingController();
  final emailInputFocusNode = FocusNode();

  var userList = <UserModel>[].obs;
  var filteredUserList = <UserModel>[].obs;
  var isAllSelected = false.obs;
  var enrolledFilter = 'All'.obs;
  UserModel? editingUser;

  final userListScrollController = ScrollController();
  final emailInputScrollController = ScrollController();

  RxInt userLimit = 215.obs;
  RxInt currentUsers = 0.obs;
  RxInt remainingSlots = 215.obs;

  @override
  void onInit() {
    super.onInit();
    loadSampleUsers();

    searchController.addListener(() {
      filterUsers(searchController.text);
    });

    emailInputController.addListener(() {
      _updateUserCount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (emailInputScrollController.hasClients) {
        final maxScroll = emailInputScrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          emailInputScrollController.jumpTo(maxScroll * 0.2);
        }
      }
    });
  }

  void loadSampleUsers() {
    userList.value = [
      UserModel(
          name: 'John Doe',
          email: 'john@truck.com...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Mark Smith',
          email: 'marksmith@truc...',
          status: UserStatus.pending,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Sarah Johnson',
          email: 'sarah@truc...',
          status: UserStatus.resend,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Sam Cline',
          email: 'samcline@truc...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Emily Davis',
          email: 'emily@truck.com...',
          status: UserStatus.pending,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'Michael Brown',
          email: 'michael@truc...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
      UserModel(
          name: 'Jessica Wilson',
          email: 'jessica@truc...',
          status: UserStatus.resend,
          isSelected: false,
          isEnrolled: false),
      UserModel(
          name: 'David Lee',
          email: 'david@truck.com...',
          status: UserStatus.active,
          isSelected: false,
          isEnrolled: true),
    ];
    filterUsers(searchController.text);
    _updateUserCount();
  }

  void filterUsers(String query) {
    var tempList = userList.toList();

    // Text search filter
    if (query.isNotEmpty) {
      tempList = tempList
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Enrolled filter
    if (enrolledFilter.value != 'All') {
      bool isTargetEnrolled = enrolledFilter.value == 'Yes';
      tempList = tempList
          .where((user) => user.isEnrolled == isTargetEnrolled)
          .toList();
    }

    // A-Z sorting by First Name (Name)
    tempList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    filteredUserList.value = tempList;
    _updateSelectAllState();
  }

  void toggleUserSelection(int index) {
    filteredUserList[index].isSelected = !filteredUserList[index].isSelected;
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void toggleAllSelection() {
    isAllSelected.value = !isAllSelected.value;
    for (var user in filteredUserList) {
      user.isSelected = isAllSelected.value;
    }
    filteredUserList.refresh();
  }

  void _updateSelectAllState() {
    if (filteredUserList.isEmpty) {
      isAllSelected.value = false;
      return;
    }
    isAllSelected.value = filteredUserList.every((user) => user.isSelected);
  }

  void editUser(UserModel user) {
    editingUser = user;
    emailInputController.text = '${user.name}, ${user.email}';
    Get.snackbar('Edit Mode', 'User loaded in ADD/EDIT USERS box.',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white);
  }

  UserModel? parseSingleEntry(String entry) {
    try {
      final parts = entry.split(',').map((e) => e.trim()).toList();
      if (parts.length != 2) return null;
      final name = parts[0];
      final email = parts[1];
      if (name.isEmpty || email.isEmpty || !email.contains('@')) return null;
      return UserModel(
          name: name,
          email: email,
          status: UserStatus.pending,
          isSelected: false);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> parseMultipleEntries(String csvData) {
    final lines = csvData
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final users = <UserModel>[];
    for (final line in lines) {
      final user = parseSingleEntry(line);
      if (user != null) users.add(user);
    }
    return users;
  }

  void addUserEmail() {
    final input = emailInputController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Error', 'Please enter user information',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Handle Edit Mode
    if (editingUser != null) {
      final singleUser = parseSingleEntry(input);
      if (singleUser != null) {
        editingUser!.name = singleUser.name;
        editingUser!.email = singleUser.email;
        filterUsers(searchController.text);
        emailInputController.clear();
        editingUser = null;
        Get.snackbar('Success', 'User updated successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Invalid Format',
            'Use format: "Firstname Lastname, email@email.com"',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
      return;
    }

    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    int pendingCount = lines.length;
    int totalAfterAdd = userList.length + pendingCount;

    if (totalAfterAdd > userLimit.value) {
      int exceededBy = totalAfterAdd - userLimit.value;
      int availableSlots = userLimit.value - userList.length;
      Get.snackbar('Limit Exceeded',
          'Trying to add $pendingCount users but only $availableSlots seats available. Over by $exceededBy.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 6));
      return;
    }

    final singleUser = parseSingleEntry(input);
    if (singleUser != null) {
      userList.add(singleUser);
      filterUsers(searchController.text);
      emailInputController.clear();
      Get.snackbar('Success', 'Invitation sent to ${singleUser.email}',
          backgroundColor: Colors.green, colorText: Colors.white);
      return;
    }

    final multipleUsers = parseMultipleEntries(input);
    if (multipleUsers.isNotEmpty) {
      userList.addAll(multipleUsers);
      filterUsers(searchController.text);
      emailInputController.clear();
      Get.snackbar(
          'Success', '${multipleUsers.length} user(s) added successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
      return;
    }

    Get.snackbar(
        'Invalid Format', 'Use format: "Firstname Lastname, email@email.com"',
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  void importUsers() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      String? filePath = result.files.single.path;
      if (filePath == null) {
        Get.snackbar('Error', 'Could not access file',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final file = File(filePath);
      String csvString;
      try {
        csvString = await file.readAsString();
      } catch (e) {
        Get.snackbar('Error', 'Could not read file.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter()
            .convert(csvString, eol: '\n', shouldParseNumbers: false);
      } catch (e) {
        Get.snackbar('Error', 'Invalid CSV format',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (csvData.isEmpty) {
        Get.snackbar('Error', 'CSV file is empty',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      StringBuffer importedText = StringBuffer();
      int successCount = 0;
      int skipCount = 0;

      for (var row in csvData) {
        if (row.isEmpty) continue;
        String name = '';
        String email = '';

        if (row.length == 1) {
          email = row[0].toString().trim();
          name = email.split('@')[0];
        } else if (row.length >= 2) {
          if (row.length == 2) {
            name = row[0].toString().trim();
            email = row[1].toString().trim();
          } else {
            email = row.last.toString().trim();
            name = row.sublist(0, row.length - 1).join(' ').trim();
          }
        }

        if (email.isEmpty || !email.contains('@')) {
          skipCount++;
          continue;
        }

        importedText.writeln('$name, $email');
        successCount++;
      }

      if (successCount == 0) {
        Get.snackbar('Error', 'No valid users found in CSV',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      emailInputController.text = importedText.toString().trim();
      String message = '$successCount user(s) imported';
      if (skipCount > 0) message += '\n$skipCount invalid entries skipped';
      Get.snackbar('Success', message,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3));
    } catch (e) {
      Get.snackbar('Error', 'Failed to import: ${e.toString()}',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _updateUserCount() {
    currentUsers.value = userList.length;
    final input = emailInputController.text.trim();
    int pendingUsers = 0;
    if (input.isNotEmpty) {
      pendingUsers = input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    remainingSlots.value = userLimit.value - currentUsers.value - pendingUsers;
    update(['add_button']);
  }

  String get limitText {
    int remaining = userLimit.value - currentUsers.value;
    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      remaining -= input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    return remaining >= 0 ? '+ $remaining' : '$remaining';
  }

  Color get limitColor {
    int remaining = userLimit.value - currentUsers.value;
    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      remaining -= input.split('\n').where((e) => e.trim().isNotEmpty).length;
    }
    return remaining >= 0 ? const Color(0xFF12A900) : const Color(0xFFA20000);
  }

  bool canAddUsers() {
    final input = emailInputController.text.trim();
    if (input.isEmpty) return true;
    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    return userList.length + lines.length <= userLimit.value;
  }

  Color addButtonColor() =>
      canAddUsers() ? AppColors.orange : const Color(0xFF8F8F8F);

  void cancelInput() {
    emailInputController.clear();
    editingUser = null;
    _updateUserCount();
  }

  void downloadSelected() async {
    if (filteredUserList.isEmpty) {
      Get.snackbar('Warning', 'No users available to download',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }

    try {
      List<List<dynamic>> csvData = [
        ['Name', 'Email', 'Enrolled']
      ];

      for (var user in filteredUserList) {
        csvData.add([user.name, user.email, user.isEnrolled ? 'Yes' : 'No']);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      // Print the CSV to the console so you can verify it on the frontend!
      debugPrint('--- GENERATED CSV FOR EMAIL ---');
      debugPrint(csvString);
      debugPrint('-------------------------------');

      // Instead of saving to file, we simulate sending the email as per UI requirements
      CustomDialogs.showDownloadSuccess();
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate CSV: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void cancelSelected() {
    searchController.clear();
    enrolledFilter.value = 'All';
    emailInputController.clear();
    editingUser = null;

    for (var user in userList) {
      user.isSelected = false;
    }
    isAllSelected.value = false;

    filterUsers('');
  }

  void resendSelected() {
    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    final resendUsers =
        selected.where((u) => u.status == UserStatus.resend).toList();
    if (resendUsers.isEmpty) {
      Get.snackbar('Warning', 'Selected users do not have "Resend" status',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    for (var user in resendUsers) {
      CustomDialogs.showResendConfirmation(
        userName: user.name,
        userEmail: user.email,
        onConfirm: () {
          user.status = UserStatus.pending;
          user.isSelected = false;
          Get.back();
        },
      );
    }
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void removeSelected() {
    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user to remove',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    CustomDialogs.showRemoveConfirmation(onConfirm: () {
      filteredUserList.removeWhere((u) => u.isSelected);
      userList.removeWhere((u) => u.isSelected);
      Get.back();
    });
  }

  String getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.resend:
        return 'Resend';
      case UserStatus.remove:
        return 'Remove';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    emailInputController.dispose();
    emailInputFocusNode.dispose();
    userListScrollController.dispose();
    emailInputScrollController.dispose();
    super.onClose();
  }
}

// ============================================================
// MODELS & ENUMS
// ============================================================
class UserModel {
  String name;
  String email;
  UserStatus status;
  bool isSelected;
  bool isEnrolled;

  UserModel({
    required this.name,
    required this.email,
    required this.status,
    this.isSelected = false,
    this.isEnrolled = false,
  });
}

enum UserStatus { active, pending, resend, remove }

// ============================================================
// CUSTOM SCROLL INDICATOR
// ============================================================
class CustomScrollIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final double containerHeight;

  const CustomScrollIndicator({
    super.key,
    required this.scrollController,
    required this.containerHeight,
  });

  @override
  State<CustomScrollIndicator> createState() => _CustomScrollIndicatorState();
}

class _CustomScrollIndicatorState extends State<CustomScrollIndicator> {
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.hasClients && mounted) {
      setState(() {
        _scrollPosition = widget.scrollController.offset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.scrollController.hasClients) return const SizedBox.shrink();

    try {
      final position = widget.scrollController.position;
      final maxScroll = position.maxScrollExtent;
      if (maxScroll <= 0) return const SizedBox.shrink();

      final viewportHeight = position.viewportDimension;
      final contentHeight = maxScroll + viewportHeight;
      if (contentHeight <= 0 || widget.containerHeight <= 0) {
        return const SizedBox.shrink();
      }

      final indicatorHeight =
          (viewportHeight / contentHeight) * widget.containerHeight;
      final maxIndicatorTravel = widget.containerHeight - indicatorHeight;
      final indicatorTop = (_scrollPosition / maxScroll) * maxIndicatorTravel;

      return Positioned(
        right: 5.w,
        top: indicatorTop.clamp(5.0, maxIndicatorTravel),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            try {
              final dragRatio = details.delta.dy / widget.containerHeight;
              final newScroll = (_scrollPosition + dragRatio * maxScroll)
                  .clamp(0.0, maxScroll);
              widget.scrollController.jumpTo(newScroll);
            } catch (_) {}
          },
          child: Container(
            // ✅ .w for width, .h for height — correct
            width: 9.w,
            height: indicatorHeight.clamp(5.h, widget.containerHeight),
            decoration: BoxDecoration(
              color: TeamManagerColors.primaryOrange,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

// ============================================================
// DIALOGS
// ============================================================
class CustomDialogs {
  static void showRemoveConfirmation({required VoidCallback onConfirm}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        // ✅ .w for horizontal inset
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          // ✅ .w for all-side padding (visual consistency)
          padding: EdgeInsets.all(15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/icons/bell-icon.svg",
                    height: 20.h,
                    width: 20.w,
                  ),
                  GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      width: 79.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            // ✅ lineHeight — NO .h, pure multiplier
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'You are about to remove the selected User(s). Tap Confirm to continue.',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  // ✅ NO .h on lineHeight
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showDownloadSuccess() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          padding: EdgeInsets.all(15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/icons/bell-icon.svg",
                    height: 20.h,
                    width: 20.w,
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      "assets/icons/Close-X-Circle.svg",
                      height: 20.h,
                      width: 20.w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Your Users list has been emailed to you at the email associated with this account. It is in .CSV format.',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static void showResendConfirmation({
    required String userName,
    required String userEmail,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 60.sp),
              SizedBox(height: 20.h),
              Text(
                'Email Sent!',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                'An email invite has been sent to',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                userName,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                userEmail,
                style: GoogleFonts.lato(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'They will have 7 days to respond.\nStatus will change to "Pending".',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    // ✅ NO .h
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25.h),
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.lato(
                      color: Colors.green.shade700,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void showHelpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/icons/dulogbox_person.svg",
                      width: 30.w, height: 30.h),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",
                        width: 30.w, height: 30.h),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildInstructionText(
                title: 'Single entry:',
                content:
                    'Tap inside field below, type first/last name and email separated by a comma.',
              ),
              _buildInstructionText(
                title: 'Example:',
                content: 'John Doe, email@email.com',
                isExample: true,
              ),
              SizedBox(height: 12.h),
              _buildInstructionText(
                title: 'Multiple entries:',
                content:
                    'Tap Import. List must be comma delineated in .CSV format, one user per line.',
              ),
              SizedBox(height: 12.h),
              Text(
                'After import, tap on name or email to edit. Clicking on Add moves the list to the Users list above.',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  // ✅ NO .h
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  static Widget _buildInstructionText({
    required String title,
    required String content,
    bool isExample = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            // ✅ NO .h on lineHeight
            height: 1.5,
          ),
          children: [
            TextSpan(
                text: title,
                style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
            const TextSpan(text: ' '),
            TextSpan(
              text: content,
              style: GoogleFonts.lato(
                  fontStyle: isExample ? FontStyle.italic : FontStyle.normal),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN SCREEN
// ============================================================
class TeamManager extends StatelessWidget {
  TeamManager({super.key});

  final controller = Get.put(TeamManagerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                // Updated to match 20.h top margin across all screens ((152 - 112) / 2 = 20)
                toolbarHeight: 152.h,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageManager.mapBackground),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 225.w,
                      height: 112.h,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImageManager.splashScreenLogo),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                // ✅ .w for horizontal padding
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Manager',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            // ✅ NO .h — lineHeight is a multiplier
                            height: 0.88,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Divider(color: AppColors.dividerColor, thickness: 1),
                        SizedBox(height: 3.h),
                        _buildSubscriptionInfo(),
                        SizedBox(height: 20.h),
                        Divider(color: AppColors.dividerColor, thickness: 1),
                        SizedBox(height: 20.h),
                        _buildUsersSection(),
                        GestureDetector(
                          onTap: () {
                            final navController = Get.find<NavController>();
                            Get.offAllNamed(AppRoutes.accountScreen);
                          },
                          child: Text(
                            'Manage Account',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: const Color(0xFF9DACF5),
                              fontSize: 18.sp,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              // ✅ NO .h
                              height: 1.78,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  Widget _buildSubscriptionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT PLAN',
          style: GoogleFonts.leagueGothic(
            color: AppColors.orange,
            fontSize: 26.sp,
            fontWeight: FontWeight.w400,
            // ✅ NO .h
            height: 1.56,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: 8.h),
        _buildInfoText('Up to 100 users'),
        _buildInfoText('Enrolled user total: 0 of 100'),
        _buildInfoText('Renewal date: [Month/Day/Year]'),
        _buildInfoText('Subscription ID: sub.100 monthly'),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.chooseATeamPlan),
          child: Text(
            'Upgrade / Downgrade',
            style: GoogleFonts.lato(
              color: AppColors.purple,
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              // ✅ NO .h
              height: 1.56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      // ✅ .h for vertical padding only
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w400,
          // ✅ NO .h
          height: 1.56,
        ),
      ),
    );
  }

  Widget _buildUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchHeader(),
        SizedBox(height: 16.h),
        _buildUserListTable(),
        SizedBox(height: 16.h),
        _buildActionButtons(),
        SizedBox(height: 24.h),
        _buildAddEditUsersSection(),
        SizedBox(height: 25.h),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Row(
      children: [
        Text(
          'USERS',
          style: GoogleFonts.leagueGothic(
            color: AppColors.orange,
            fontSize: 26.sp,
            fontWeight: FontWeight.w400,
            // ✅ NO .h
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        const Spacer(),
        Obx(() => Container(
              height: 32.h,
              padding: EdgeInsets.only(left: 8.w, right: 1.w),
              decoration: BoxDecoration(
                color: AppColors.medGray,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.enrolledFilter.value,
                  dropdownColor: AppColors.medGray,
                  icon: Transform.translate(
                    offset: Offset(-6.w, 0),
                    child: Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 14.sp),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.enrolledFilter.value = newValue;
                      controller.filterUsers(controller.searchController.text);
                    }
                  },
                  items: <String>['All', 'Yes', 'No']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            )),
        SizedBox(width: 8.w),
        Row(
          children: [
            Icon(Icons.search,
                color: TeamManagerColors.primaryWhite, size: 26.sp),
            SizedBox(width: 2.w),
            Container(
              width: 195.w,
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppColors.medGray,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: TextField(
                    controller: controller.searchController,
                    cursorColor: AppColors.white,
                    cursorHeight: 18,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: () =>
                  controller.filterUsers(controller.searchController.text),
              child: Container(
                width: 33.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.medGray,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Text(
                    'GO',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      // ✅ NO .h
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserListTable() {
    // ✅ .h diye responsive — 440x956 design e 224.h = correct
    final double containerHeight = 224.h;

    return Obx(() {
      if (controller.filteredUserList.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            Stack(
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: containerHeight),
                  child: SingleChildScrollView(
                    controller: controller.userListScrollController,
                    child: Column(
                      children: List.generate(
                        controller.filteredUserList.length,
                        (index) => _buildTableRow(index),
                      ),
                    ),
                  ),
                ),
                CustomScrollIndicator(
                  scrollController: controller.userListScrollController,
                  containerHeight: containerHeight,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      // ✅ .w horizontal, .h vertical
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.r),
          topRight: Radius.circular(8.r),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Name',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Email',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Enrolled',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 70.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => GestureDetector(
                      onTap: controller.toggleAllSelection,
                      child: Container(
                        width: 20.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: controller.isAllSelected.value
                              ? AppColors.orange
                              : Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5.w),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: controller.isAllSelected.value
                            ? Icon(Icons.check,
                                color: Colors.white, size: 16.sp)
                            : null,
                      ),
                    )),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _showUserManagementHelp,
                  child: SvgPicture.asset(
                    "assets/icons/Question-Box-gray.svg",
                    width: 24.w,
                    height: 24.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(int index) {
    return Obx(() {
      final user = controller.filteredUserList[index];
      final nameEmailColor = user.isSelected
          ? TeamManagerColors.primaryOrange
          : TeamManagerColors.primaryWhite;
      final statusColor = _getTextColor(user.status);

      return Container(
        // ✅ .w horizontal, .h vertical
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border:
              Border(bottom: BorderSide(color: AppColors.medGray, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: nameEmailColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                user.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: nameEmailColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user.isEnrolled ? 'Yes' : 'No',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: user.isEnrolled ? Colors.green : Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 70.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => controller.toggleUserSelection(index),
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: user.isSelected
                            ? TeamManagerColors.primaryOrange
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5.w),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: user.isSelected
                          ? Icon(Icons.close, color: Colors.white, size: 16.sp)
                          : null,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => controller.editUser(user),
                    child: SvgPicture.asset(
                      "assets/icons/Edit-Pencil-white.svg",
                      width: 24.w,
                      height: 24.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showUserManagementHelp() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 20.w, bottom: 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset("assets/icons/Edit-Pencil-white.svg",
                      height: 30.h, width: 30.w),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'User Management',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: SvgPicture.asset("assets/icons/Close-X-Circle.svg",
                          height: 30.h, width: 30.w),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                '• Click the checkbox to select individual users\n'
                '• Click the checkbox in the header to select/deselect all users\n'
                '• Click the pencil icon to edit a user\'s information\n'
                '• Select users and click action buttons for bulk operations',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  // ✅ NO .h
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          'No users found',
          style: GoogleFonts.lato(
            color: TeamManagerColors.primaryWhite.withValues(alpha: 0.6),
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 80.w,
            child: _buildActionButton('Download', controller.downloadSelected)),
        SizedBox(width: 10.w),
        SizedBox(
            width: 80.w,
            child: _buildActionButton('Cancel', controller.cancelSelected)),
        SizedBox(width: 10.w),
        SizedBox(
            width: 80.w,
            child: _buildActionButton('Remove', controller.removeSelected)),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // ✅ .w horizontal, .h vertical
        padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddEditUsersSection() {
    // ✅ .h diye responsive
    final double containerHeight = 265.h;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Text(
                'ADD / EDIT USERS',
                style: GoogleFonts.leagueGothic(
                  color: AppColors.orange,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w400,
                  // ✅ NO .h
                  height: 1.17,
                  letterSpacing: 1.50,
                ),
              ),
              SizedBox(width: 3.w),
              GestureDetector(
                onTap: CustomDialogs.showHelpDialog,
                child: SvgPicture.asset(
                  "assets/icons/Question-Box-gray.svg",
                  height: 21.h,
                  width: 21.w,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: containerHeight,
              // ✅ .w for all-side padding
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border:
                    Border.all(color: TeamManagerColors.borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller.emailInputScrollController,
                      child: TextField(
                        controller: controller.emailInputController,
                        focusNode: controller.emailInputFocusNode,
                        maxLines: null,
                        minLines: 10,
                        style: GoogleFonts.lato(
                          color: Colors.black,
                          fontSize: 16.sp,
                        ),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.lato(
                            color: Colors.black.withValues(alpha: 0.4),
                            fontSize: 16.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  Divider(color: AppColors.darkGray, thickness: 1),
                  Obx(() => Text(
                        controller.limitText,
                        style: GoogleFonts.lato(
                          color: controller.limitColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              ),
            ),
            CustomScrollIndicator(
              scrollController: controller.emailInputScrollController,
              containerHeight: containerHeight,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            SizedBox(
              width: 84.w,
              child: _buildActionButton('Import', controller.importUsers),
            ),
            const Spacer(),
            SizedBox(
              width: 84.w,
              child: _buildActionButton('Cancel', controller.cancelInput),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 64.w,
              child: GetBuilder<TeamManagerController>(
                id: 'add_button',
                builder: (ctrl) {
                  return GestureDetector(
                    onTap: ctrl.canAddUsers()
                        ? ctrl.addUserEmail
                        : () => Get.snackbar(
                              'Cannot Add',
                              'User limit exceeded. Remove some users or upgrade your plan.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 4),
                            ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ctrl.addButtonColor(),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getTextColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return TeamManagerColors.primaryOrange;
      case UserStatus.pending:
        return TeamManagerColors.primaryWhite;
      case UserStatus.resend:
        return TeamManagerColors.primaryOrange;
      case UserStatus.remove:
        return TeamManagerColors.primaryWhite;
    }
  }
}
