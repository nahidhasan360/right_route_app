import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';

class EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const EmailInputField({
    Key? key,
    required this.controller,
    this.hintText = "Email",
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  @override
  void dispose() {
    // Note: Controller dispose parent widget-এ করতে হবে
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 50,
        maxHeight: 70,
        maxWidth: 500,
      ),
      decoration: BoxDecoration(
        color: AppColors.medGray,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: widget.controller,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Lato',
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.2,
        ),
        cursorColor: Color(0xFFFFFFFF),
        cursorHeight: 22,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Color(0xFFBFBFBF),
            fontSize: 16,
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
          isDense: false,
          contentPadding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 10,
            bottom: 10,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        keyboardType: TextInputType.emailAddress,
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }
}