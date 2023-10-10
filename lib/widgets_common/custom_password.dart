// custom_textfield.dart
import 'package:flutter/material.dart';
import 'package:qurban_3/consts/consts.dart';

class CustomPassword extends StatefulWidget {
  final String? title;
  final String? hint;
  final TextEditingController? controller;
  final bool isPass;

  CustomPassword({this.title, this.hint, this.controller, required this.isPass});

  @override
  _CustomPasswordState createState() => _CustomPasswordState();
}

class _CustomPasswordState extends State<CustomPassword> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) // Add null check here
          widget.title!.text.color(black).fontFamily(semibold).size(16).make(),
        5.heightBox,
        TextFormField(
          obscureText: widget.isPass ? _isObscure : false,
          controller: widget.controller,
          decoration: InputDecoration(
            suffixIcon: widget.isPass
                ? IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                      color: textfieldGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            hintStyle: const TextStyle(
              fontFamily: semibold,
              color: textfieldGrey,
            ),
            hintText: widget.hint,
            isDense: true,
            fillColor: lightGrey,
            filled: true,
            border: InputBorder.none,
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: redColor),
            ),
          ),
        ),
        5.heightBox,
      ],
    );
  }
}
