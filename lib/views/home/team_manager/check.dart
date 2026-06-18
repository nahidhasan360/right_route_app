import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ========================================
// CONTROLLER: GetX দিয়ে State Management
// ========================================
class UserController extends GetxController {
  // User list - Observable করা হয়েছে যাতে UI auto update হয়
  var users = <UserModel>[
    UserModel(
      name: 'John Doe',
      email: 'john@truck-com...',
      status: 'Active',
      isActive: true,
    ),
    UserModel(
      name: 'Mark Smith',
      email: 'marksmith@truc...',
      status: 'Pending',
      isActive: false,
    ),
    UserModel(
      name: 'Mark Smith',
      email: 'marksmith@truc...',
      status: 'Resend',
      isActive: false,
    ),
  ].obs;

  // Add/Edit dialog এর email field
  var emailController = TextEditingController();

  // Search query
  var searchQuery = ''.obs;

  // Dialog খোলা/বন্ধ tracking
  var isDialogOpen = false.obs;

  // User edit করার function
  void editUser(int index) {
    emailController.text = users[index].email;
    isDialogOpen.value = true;
  }

  // User add করার function
  void addUser() {
    if (emailController.text.isNotEmpty) {
      users.add(UserModel(
        name: 'New User',
        email: emailController.text,
        status: 'Pending',
        isActive: false,
      ));
      emailController.clear();
      isDialogOpen.value = false;
    }
  }

  // User remove করার function
  void removeUser(int index) {
    users.removeAt(index);
  }

  // Dialog cancel করার function
  void cancelDialog() {
    emailController.clear();
    isDialogOpen.value = false;
  }
}

// ========================================
// DATA MODEL: User এর structure
// ========================================
class UserModel {
  String name;
  String email;
  String status;
  bool isActive;

  UserModel({
    required this.name,
    required this.email,
    required this.status,
    required this.isActive,
  });
}

// ========================================
// MAIN SCREEN: Complete UI
// ========================================
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D2E), // Dark navy background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================================
              // HEADER SECTION: "USERS" title + Search bar
              // ========================================
              _buildHeader(controller),

              SizedBox(height: 20.h),

              // ========================================
              // USER TABLE: Name, Email, Status columns
              // ========================================
              _buildUserTable(controller),

              SizedBox(height: 20.h),

              // ========================================
              // ACTION BUTTONS: Download, Cancel, Resend, Remove
              // ========================================
              _buildActionButtons(),

              SizedBox(height: 30.h),

              // ========================================
              // ADD/EDIT SECTION: Dialog box
              // ========================================
              _buildAddEditSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // HEADER WIDGET: Title এবং Search Bar
  // ========================================
  Widget _buildHeader(UserController controller) {
    return Row(
      children: [
        // "USERS" title - Orange color with specific font
        Text(
          'USERS',
          style: TextStyle(
            color: const Color(0xFFFF8C42), // Orange color
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.w, // Letter spacing for style
          ),
        ),

        SizedBox(width: 16.w),

        // Search bar - Dark background with "Doc" placeholder
        Expanded(
          child: Container(
            height: 32.h,
            decoration: BoxDecoration(
              color: const Color(0xFF4A5568), // Gray background
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                // Search icon
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Icon(
                    Icons.search,
                    color: Colors.white70,
                    size: 18.sp,
                  ),
                ),

                // Search input field
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Doc',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // GO button - Small dark button
                Container(
                  margin: EdgeInsets.only(right: 4.w),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3748), // Darker gray
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: Text(
                    'GO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // USER TABLE WIDGET: Complete table structure
  // ========================================
  Widget _buildUserTable(UserController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419), // Very dark background for table
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFF2D3748),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          // Table Header Row
          _buildTableHeader(),

          // Divider line
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: const Color(0xFF2D3748),
          ),

          // Table Rows - Dynamic list থেকে generate হবে
          Obx(() => Column(
            children: controller.users.asMap().entries.map((entry) {
              int index = entry.key;
              UserModel user = entry.value;
              return _buildTableRow(user, index, controller);
            }).toList(),
          )),
        ],
      ),
    );
  }

  // ========================================
  // TABLE HEADER: Column titles
  // ========================================
  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Name column - 30% width
          Expanded(
            flex: 3,
            child: Text(
              'Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Email column - 40% width
          Expanded(
            flex: 4,
            child: Text(
              'Email',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Status column - 20% width
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Icons column - Fixed width
          SizedBox(
            width: 60.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.help_outline, size: 16.sp, color: Colors.white70),
                SizedBox(width: 8.w),
                Icon(Icons.help_outline, size: 16.sp, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // TABLE ROW: Single user row
  // ========================================
  Widget _buildTableRow(UserModel user, int index, UserController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2D3748),
            width: 1.h,
          ),
        ),
      ),
      child: Row(
        children: [
          // Name - Blue color for active, Orange for others
          Expanded(
            flex: 3,
            child: Text(
              user.name,
              style: TextStyle(
                color: user.isActive
                    ? const Color(0xFF4A9EFF) // Blue for active
                    : const Color(0xFFFF8C42), // Orange for others
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Email - Truncated with ellipsis
          Expanded(
            flex: 4,
            child: Text(
              user.email,
              style: TextStyle(
                color: user.isActive
                    ? const Color(0xFF4A9EFF)
                    : const Color(0xFFFF8C42),
                fontSize: 13.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status - Different colors based on status
          Expanded(
            flex: 2,
            child: Text(
              user.status,
              style: TextStyle(
                color: user.status == 'Active'
                    ? const Color(0xFF48BB78) // Green
                    : user.status == 'Pending'
                    ? const Color(0xFFECC94B) // Yellow
                    : const Color(0xFFFF8C42), // Orange
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Action icons - Checkbox and Edit pencil
          SizedBox(
            width: 60.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Checkbox
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),

                SizedBox(width: 8.w),

                // Edit pencil icon - Clickable
                GestureDetector(
                  onTap: () => controller.editUser(index),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8926A), // Brown/tan color
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // ACTION BUTTONS: Download, Cancel, Resend, Remove
  // ========================================
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Download button - Orange
        _buildButton('Download', const Color(0xFFFF8C42), () {}),
        SizedBox(width: 12.w),

        // Cancel button - Orange
        _buildButton('Cancel', const Color(0xFFFF8C42), () {}),
        SizedBox(width: 12.w),

        // Resend button - Orange
        _buildButton('Resend', const Color(0xFFFF8C42), () {}),
        SizedBox(width: 12.w),

        // Remove button - Orange
        _buildButton('Remove', const Color(0xFFFF8C42), () {}),
      ],
    );
  }

  // ========================================
  // REUSABLE BUTTON: Orange styled button
  // ========================================
  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ========================================
  // ADD/EDIT SECTION: Dialog box UI
  // ========================================
  Widget _buildAddEditSection(UserController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1419),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFF2D3748),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and help icon
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2D3748),
                  width: 1.h,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ADD / EDIT USERS',
                  style: TextStyle(
                    color: const Color(0xFFFF8C42),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.w,
                  ),
                ),
                Icon(
                  Icons.help_outline,
                  color: Colors.white70,
                  size: 18.sp,
                ),
              ],
            ),
          ),

          // Email input field - White background
          Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                color: const Color(0xFFFF8C42),
                width: 2.w, // Orange border to match screenshot
              ),
            ),
            child: TextField(
              controller: controller.emailController,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                hintText: 'john@truckcompany.com',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 14.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          // Character counter - "+ 215" green text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              '+ 215',
              style: TextStyle(
                color: const Color(0xFF48BB78), // Green
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Bottom action buttons row
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Import button
                _buildButton('Import', const Color(0xFFFF8C42), () {}),
                SizedBox(width: 12.w),

                // Cancel button
                _buildButton('Cancel', const Color(0xFFFF8C42),
                    controller.cancelDialog),

                const Spacer(),

                // Add button - Primary action
                _buildButton('Add', const Color(0xFFFF8C42),
                    controller.addUser),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// RESPONSIVE VERSION: MediaQuery based
// ========================================
// Note: উপরের code ScreenUtil দিয়ে pixel-perfect।
// Dynamic responsive এর জন্য w, h, sp, r এর জায়গায়
// MediaQuery.of(context).size.width/height * percentage use করুন

/*
DYNAMIC RESPONSIVE VERSION এর জন্য:

1. ScreenUtil এর পরিবর্তে MediaQuery:
   - 16.w → MediaQuery.of(context).size.width * 0.04
   - 20.h → MediaQuery.of(context).size.height * 0.025

2. LayoutBuilder দিয়ে breakpoints:
   - Mobile: width < 600
   - Tablet: width < 900
   - Desktop: width >= 900

3. Flexible widgets ব্যবহার করুন:
   - Fixed padding এর বদলে Expanded/Flexible
   - Fixed font size এর বদলে Text scale factor
*/