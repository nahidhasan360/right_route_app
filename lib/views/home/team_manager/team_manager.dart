import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';

// ✅ CSV Import Dependencies
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';

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
// CONTROLLER - GetX State Management
// ============================================================
class TeamManagerController extends GetxController {
  final searchController = TextEditingController();
  final emailInputController = TextEditingController();
  final emailInputFocusNode = FocusNode();

  var userList = <UserModel>[].obs;
  var filteredUserList = <UserModel>[].obs;
  var isAllSelected = false.obs;

  final userListScrollController = ScrollController();
  final emailInputScrollController = ScrollController();

  // ✅ User Limit Variables
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
      ),
      UserModel(
        name: 'Mark Smith',
        email: 'marksmith@truc...',
        status: UserStatus.pending,
        isSelected: false,
      ),
      UserModel(
        name: 'Sarah Johnson',
        email: 'sarah@truc...',
        status: UserStatus.resend,
        isSelected: false,
      ),
      UserModel(
        name: 'Sam Cline',
        email: 'samcline@truc...',
        status: UserStatus.active,
        isSelected: false,
      ),
      UserModel(
        name: 'Emily Davis',
        email: 'emily@truck.com...',
        status: UserStatus.pending,
        isSelected: false,
      ),
      UserModel(
        name: 'Michael Brown',
        email: 'michael@truc...',
        status: UserStatus.active,
        isSelected: false,
      ),
      UserModel(
        name: 'Jessica Wilson',
        email: 'jessica@truc...',
        status: UserStatus.resend,
        isSelected: false,
      ),
      UserModel(
        name: 'David Lee',
        email: 'david@truck.com...',
        status: UserStatus.active,
        isSelected: false,
      ),
    ];
    filteredUserList.value = userList;
    _updateUserCount();
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      filteredUserList.value = userList;
    } else {
      filteredUserList.value = userList
          .where(
            (user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
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
    emailInputController.text = '${user.name}, ${user.email}';
    Get.snackbar(
      'Edit Mode',
      'User loaded in ADD/EDIT USERS box. Modify and click Add to update.',
      backgroundColor: TeamManagerColors.primaryOrange,
      colorText: Colors.white,
    );
  }

  UserModel? parseSingleEntry(String entry) {
    try {
      final parts = entry.split(',').map((e) => e.trim()).toList();
      if (parts.length != 2) return null;

      final name = parts[0];
      final email = parts[1];

      if (name.isEmpty || email.isEmpty || !email.contains('@')) {
        return null;
      }

      return UserModel(
        name: name,
        email: email,
        status: UserStatus.pending,
        isSelected: false,
      );
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
      if (user != null) {
        users.add(user);
      }
    }

    return users;
  }

  void addUserEmail() {
    final input = emailInputController.text.trim();

    if (input.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter user information',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    int pendingCount = lines.length;
    int totalAfterAdd = userList.length + pendingCount;

    if (totalAfterAdd > userLimit.value) {
      int exceededBy = totalAfterAdd - userLimit.value;
      int availableSlots = userLimit.value - userList.length;

      Get.snackbar(
        'Limit Exceeded',
        'You are trying to add $pendingCount users but only have $availableSlots seats available.\nYou are over the limit by $exceededBy users.\n\nPlease remove some users from the text field or upgrade your plan.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 6),
      );
      return;
    }

    final singleUser = parseSingleEntry(input);
    if (singleUser != null) {
      userList.add(singleUser);
      filteredUserList.value = userList;
      emailInputController.clear();

      Get.snackbar(
        'Success',
        'User invitation sent to ${singleUser.email}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }

    final multipleUsers = parseMultipleEntries(input);
    if (multipleUsers.isNotEmpty) {
      userList.addAll(multipleUsers);
      filteredUserList.value = userList;
      emailInputController.clear();

      Get.snackbar(
        'Success',
        '${multipleUsers.length} user(s) added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Invalid Format',
      'Please use format: "Firstname Lastname, email@email.com"',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void importUsers() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      String? filePath = result.files.single.path;
      if (filePath == null) {
        Get.snackbar(
          'Error',
          'Could not access file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!filePath.toLowerCase().endsWith('.csv')) {
        Get.snackbar(
          'Error',
          'Please select a CSV file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final file = File(filePath);

      String csvString;
      try {
        csvString = await file.readAsString();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not read file. Please ensure it is a valid CSV file.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter().convert(
          csvString,
          eol: '\n',
          shouldParseNumbers: false,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid CSV format',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (csvData.isEmpty) {
        Get.snackbar(
          'Error',
          'CSV file is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
        Get.snackbar(
          'Error',
          'No valid users found in CSV file',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      emailInputController.text = importedText.toString().trim();

      String message = '$successCount user(s) imported successfully';
      if (skipCount > 0) {
        message += '\n$skipCount invalid entries skipped';
      }

      Get.snackbar(
        'Success',
        message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (emailInputScrollController.hasClients) {
          emailInputScrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to import: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _updateUserCount() {
    currentUsers.value = userList.length;

    final input = emailInputController.text.trim();
    int pendingUsers = 0;

    if (input.isNotEmpty) {
      final lines = input
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      pendingUsers = lines.length;
    }

    remainingSlots.value = userLimit.value - currentUsers.value - pendingUsers;
    update(['add_button']);
  }

  String get limitText {
    int remaining = userLimit.value - currentUsers.value;

    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      final lines = input
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      remaining -= lines.length;
    }

    if (remaining >= 0) {
      return '+ $remaining';
    } else {
      return '$remaining';
    }
  }

  Color get limitColor {
    int remaining = userLimit.value - currentUsers.value;

    final input = emailInputController.text.trim();
    if (input.isNotEmpty) {
      final lines = input
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      remaining -= lines.length;
    }

    return remaining >= 0 ? Colors.green : Colors.red;
  }

// ✅ This is already correct - no change needed
  bool canAddUsers() {
    final input = emailInputController.text.trim();

    // Empty hole Orange button
    if (input.isEmpty) return true;

    final lines = input.split('\n').where((e) => e.trim().isNotEmpty).toList();
    int pendingCount = lines.length;
    int totalAfterAdd = userList.length + pendingCount;

    // Limit cross na korle Orange, korle Grey
    return totalAfterAdd <= userLimit.value;
  }
  Color addButtonColor() {
    return canAddUsers() ? AppColors.orange : Colors.grey;
  }

  void downloadSelected() {
    if (userList.isEmpty) {
      Get.snackbar(
        'Warning',
        'No users available to download',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white,
      );
      return;
    }

    String csvContent = 'Name,Email,Status\n';
    for (var user in userList) {
      csvContent +=
          '${user.name},${user.email},${_getStatusText(user.status)}\n';
    }

    Get.snackbar(
      'Success',
      'Your user list in .CSV format has been emailed to the email on this account.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  void cancelSelected() {
    for (var user in filteredUserList) {
      user.isSelected = false;
    }
    isAllSelected.value = false;
    filteredUserList.refresh();
    emailInputController.clear();

    Get.snackbar(
      'Cancelled',
      'All selections cleared and text field cleared',
      backgroundColor: TeamManagerColors.primaryOrange,
      colorText: Colors.white,
    );
  }

  void resendSelected() {
    final selected = filteredUserList.where((user) => user.isSelected).toList();

    if (selected.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select at least one user',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white,
      );
      return;
    }

    final resendUsers = selected
        .where((user) => user.status == UserStatus.resend)
        .toList();

    if (resendUsers.isEmpty) {
      Get.snackbar(
        'Warning',
        'Selected users do not have "Resend" status',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white,
      );
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
    final selected = filteredUserList.where((user) => user.isSelected).toList();

    if (selected.isEmpty) {
      Get.snackbar(
        'Warning',
        'Please select at least one user to remove',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white,
      );
      return;
    }

    CustomDialogs.showRemoveConfirmation(
      onConfirm: () {
        filteredUserList.removeWhere((user) => user.isSelected);
        userList.removeWhere((user) => user.isSelected);

        Get.back();
        Get.snackbar(
          'Success',
          '${selected.length} user(s) removed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  String _getStatusText(UserStatus status) {
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

class UserModel {
  String name;
  String email;
  UserStatus status;
  bool isSelected;

  UserModel({
    required this.name,
    required this.email,
    required this.status,
    this.isSelected = false,
  });
}

enum UserStatus { active, pending, resend, remove }

class CustomScrollIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final double containerHeight;

  const CustomScrollIndicator({
    Key? key,
    required this.scrollController,
    required this.containerHeight,
  }) : super(key: key);

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
    if (!widget.scrollController.hasClients) {
      return SizedBox.shrink();
    }

    try {
      final position = widget.scrollController.position;
      final maxScroll = position.maxScrollExtent;

      if (maxScroll <= 0) {
        return SizedBox.shrink();
      }

      final viewportHeight = position.viewportDimension;
      final contentHeight = maxScroll + viewportHeight;

      if (contentHeight <= 0 || widget.containerHeight <= 0) {
        return SizedBox.shrink();
      }

      final indicatorHeight =
          (viewportHeight / contentHeight) * widget.containerHeight;
      final maxIndicatorTravel = widget.containerHeight - indicatorHeight;

      if (maxScroll <= 0) {
        return SizedBox.shrink();
      }

      final indicatorTop = (_scrollPosition / maxScroll) * maxIndicatorTravel;

      return Positioned(
        right: 5,
        top: indicatorTop.clamp(5, maxIndicatorTravel),
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            try {
              final dragRatio = details.delta.dy / widget.containerHeight;
              final scrollDelta = dragRatio * maxScroll;
              final newScroll = (_scrollPosition + scrollDelta).clamp(
                0.0,
                maxScroll,
              );
              widget.scrollController.jumpTo(newScroll);
            } catch (e) {}
          },
          onTapDown: (details) {
            try {
              final tapPosition = details.localPosition.dy;
              final scrollRatio = tapPosition / widget.containerHeight;
              final newScroll = (scrollRatio * maxScroll).clamp(0.0, maxScroll);
              widget.scrollController.animateTo(
                newScroll,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            } catch (e) {}
          },
          child: Container(
            width: 9,
            height: indicatorHeight.clamp(5.h, widget.containerHeight),
            decoration: BoxDecoration(
              color: TeamManagerColors.primaryOrange,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
    } catch (e) {
      return SizedBox.shrink();
    }
  }
}

class CustomDialogs {
  static void showRemoveConfirmation({required VoidCallback onConfirm}) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFB71C1C)),
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/icons/bell-icon.svg",
                    height: 20,
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: onConfirm,
                    child: Container(
                      width: 79,
                      height: 23,
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You are about to remove the selected User(s). Tap confirm to continue.',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
  //                 ============================    resend diolog box show ============================
  static void showResendConfirmation({
    required String userName,
    required String userEmail,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 60),
              SizedBox(height: 20),
              Text(
                'Email Sent!',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'An email invite has been sent to',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                userName,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                userEmail,
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'They will have 7 days to respond.\nStatus will change to "Pending".',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 25),
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.lato(
                      color: Colors.green.shade700,
                      fontSize: 18,
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
        insetPadding: EdgeInsets.symmetric(horizontal: 1),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/dulogbox_person.svg",
                    width: 30,
                    height: 30,
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      "assets/icons/Close-X-Circle.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInstructionText(
                title: 'Single entry:',
                content:
                    'Tap inside field below, type first/last name and email separated by a comma. ',
              ),
              _buildInstructionText(
                title: 'Example:',
                content: '[sample format: Firstname Lastname, email@email.com]',
                isExample: true,
              ),
              SizedBox(height: 12),
              _buildInstructionText(
                title: 'Multiple entries:',
                content:
                    'Tap Import. List must be comma delineated in .CSV format, one user per line.',
              ),
              SizedBox(height: 12),
              Text(
                'After import, tap on name or email to edit. Clicking on Add moves the list to the Users list and automatically sends invite emails.',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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
    return RichText(
      text: TextSpan(
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: title,
            style: GoogleFonts.lato(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: ' '),
          TextSpan(
            text: content,
            style: GoogleFonts.lato(
              fontStyle: isExample ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}

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
                toolbarHeight: 144,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageManager.mapBackground),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 225,
                      height: 112,
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
                padding: EdgeInsets.symmetric(horizontal: 15),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Team Manager',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            height: 0.88,
                          ),
                        ),
                        SizedBox(height: 8),
                        Divider(color: AppColors.dividerColor, thickness: 1),
                        SizedBox(height: 3),
                        _buildSubscriptionInfo(),
                        SizedBox(height: 20),
                        Divider(color: AppColors.dividerColor, thickness: 1),
                        SizedBox(height: 20),
                        _buildUsersSection(),
                        GestureDetector(
                          onTap: () {
                            final navController = Get.find<NavController>();
                            // navController.saveCurrentNavbarRoute();
                            Get.offAllNamed(AppRoutes.accountScreen);
                          },
                          child: Text(
                            'Manage Account',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: const Color(0xFF9DACF5),
                              fontSize: 18,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500,
                              height: 1.78,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
          'MY CURRENT PLAN',
          style: GoogleFonts.leagueGothic(
            color: AppColors.orange,
            fontSize: 24,
            fontWeight: FontWeight.w400,
            height: 1.56,
          ),
        ),
        SizedBox(height: 8),
        _buildInfoText('Team [sample data: 1,000 (up to 1,000 users)]'),
        _buildInfoText('Seats used: [sample data: 785 of 1,000]'),
        _buildInfoText('Renewal Date: [sample data: Nov 29, 2025]'),
        _buildInfoText('Subscription ID: [subscription ID here]'),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.chooseATeamPlan);
          },
          child: Text(
            'Upgrade / Downgrade',
            style: GoogleFonts.lato(
              color: AppColors.purple,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.56,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
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
        SizedBox(height: 16),
        _buildUserListTable(),
        SizedBox(height: 16),
        _buildActionButtons(),
        SizedBox(height: 24),
        _buildAddEditUsersSection(),
        SizedBox(height: 25),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: 10),
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
            fontSize: 24,
            fontWeight: FontWeight.w400,
            height: 1.17,
            letterSpacing: 1.50,
          ),
        ),
        Spacer(),
        Row(
          children: [
            Icon(Icons.search, color: TeamManagerColors.primaryWhite, size: 24),
            SizedBox(width: 2),
            Container(
              width: 195,
              height: 32,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.medGray,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: controller.searchController,
                  cursorColor: AppColors.white,
                  cursorHeight: 18,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 2.29,
                  ),
                  decoration: InputDecoration(
                    hintStyle: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.29,
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
            SizedBox(width: 3),
            GestureDetector(
              onTap: () {
                controller.filterUsers(controller.searchController.text);
              },
              child: Container(
                width: 33,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.medGray,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'GO',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 2,
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
    return Obx(() {
      if (controller.filteredUserList.isEmpty) {
        return _buildEmptyState();
      }

      final containerHeight = 224.0;

      return Container(
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(8),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
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
                fontSize: 16,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      controller.toggleAllSelection();
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: controller.isAllSelected.value
                            ? AppColors.orange
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: controller.isAllSelected.value
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _showUserManagementHelp();
                  },
                  child: SvgPicture.asset(
                    "assets/icons/Question-Box-gray.svg",
                    width: 24,
                    height: 24,
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

      // ✅ Name/Email: White unless checkbox checked → then Orange
      final nameEmailColor = user.isSelected
          ? TeamManagerColors.primaryOrange
          : TeamManagerColors.primaryWhite;

      // ✅ Status color: Active/Resend = Orange, Pending = White
      final statusColor = _getTextColor(user.status);

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          border: Border(
            bottom: BorderSide(color: AppColors.medGray, width: 1),
          ),
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
                  fontSize: 14,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _getStatusText(user.status),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.toggleUserSelection(index);
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: user.isSelected
                            ? TeamManagerColors.primaryOrange
                            : Colors.transparent,
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: user.isSelected
                          ? Icon(Icons.close, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      controller.editUser(user);
                    },
                    child: SvgPicture.asset(
                      "assets/icons/Edit-Pencil-white.svg",
                      width: 24,
                      height: 24,
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
        insetPadding: EdgeInsets.symmetric(horizontal: 1),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/Edit-Pencil-white.svg",
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'User Management',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: SvgPicture.asset(
                        "assets/icons/Close-X-Circle.svg",
                        height: 30,
                        width: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '• Click the checkbox to select individual users\n'
                '• Click the checkbox in the header to select/deselect all users\n'
                '• Click the pencil icon to edit a user\'s information\n'
                '• Select users and click action buttons to perform bulk operations',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton('Download', controller.downloadSelected),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildActionButton('Cancel', controller.cancelSelected),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildActionButton('Resend', controller.resendSelected),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildActionButton('Remove', controller.removeSelected),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddEditUsersSection() {
    final containerHeight = 264.9;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                textAlign: TextAlign.start,
                'ADD / EDIT USERS',
                style: GoogleFonts.leagueGothic(
                  color: AppColors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  height: 1.17,
                  letterSpacing: 1.50,
                ),
              ),
              SizedBox(width: 3),
              GestureDetector(
                onTap: () {
                  CustomDialogs.showHelpDialog();
                },
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/Question-Box-gray.svg",
                    height: 21,
                    width: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: containerHeight,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: TeamManagerColors.borderColor,
                  width: 1,
                ),
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
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.lato(
                            color: Colors.black.withValues(alpha: 0.4),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  Divider(color: AppColors.darkGray, thickness: 1),
                  Obx(
                    () => Text(
                      controller.limitText,
                      style: GoogleFonts.lato(
                        color: controller.limitColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomScrollIndicator(
              scrollController: controller.emailInputScrollController,
              containerHeight: containerHeight,
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 84,
              child: _buildActionButton('Import', controller.importUsers),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 84,
              child: _buildActionButton('Cancel', controller.cancelSelected),
            ),
            SizedBox(width: 12),
            SizedBox(
              width: 64,
              child: GetBuilder<TeamManagerController>(
                id: 'add_button',
                builder: (ctrl) {
                  final canAdd = ctrl.canAddUsers();
                  final buttonColor = ctrl.addButtonColor();

                  return GestureDetector(
                    onTap: canAdd
                        ? ctrl.addUserEmail
                        : () {
                            Get.snackbar(
                              'Cannot Add',
                              'User limit exceeded. Please remove some users from the text field or upgrade your plan.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: Duration(seconds: 4),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Add',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w800,
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
        return TeamManagerColors.primaryOrange;  // ✅ Active = Orange
      case UserStatus.pending:
        return TeamManagerColors.primaryWhite;   // ✅ Pending = White
      case UserStatus.resend:
        return TeamManagerColors.primaryOrange;  // ✅ Resend = Orange
      case UserStatus.remove:
        return TeamManagerColors.primaryWhite;   // ✅ Remove = White (though this won't be visible)
    }
  }

  String _getStatusText(UserStatus status) {
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
}
