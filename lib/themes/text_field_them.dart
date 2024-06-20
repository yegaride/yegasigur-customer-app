import 'package:cabme/themes/constant_colors.dart';
import 'package:flutter/material.dart';

class TextFieldThem {
  const TextFieldThem(Key? key);

  static buildTextField(
      {required String title,
      required TextEditingController controller,
      IconData? icon,
      String? Function(String?)? validators,
      TextInputType textInputType = TextInputType.text,
      bool obscureText = true,
      EdgeInsets contentPadding = EdgeInsets.zero,
      maxLine = 1,
      bool enabled = true,
      maxLength = 300,
      String? labelText}) {
    return TextFormField(
      obscureText: !obscureText,
      validator: validators,
      keyboardType: textInputType,
      textCapitalization: TextCapitalization.sentences,
      controller: controller,
      maxLines: maxLine,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          counterText: "",
          labelText: labelText,
          hintText: title,
          contentPadding: contentPadding,
          suffixIcon: Icon(icon),
          border: const UnderlineInputBorder()),
    );
  }

  static boxBuildTextField({
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validators,
    TextInputType textInputType = TextInputType.text,
    bool obscureText = false,
    EdgeInsets contentPadding = EdgeInsets.zero,
    maxLine = 1,
    bool enabled = true,
    maxLength = 300,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return _AppInput(
      controller: controller,
      hintText: hintText,
      contentPadding: contentPadding,
      enabled: enabled,
      maxLength: maxLength,
      maxLine: maxLine,
      obscureText: obscureText,
      textInputType: textInputType,
      validators: validators,
      textCapitalization: textCapitalization,
    );
  }
}

class _AppInput extends StatefulWidget {
  const _AppInput({
    this.obscureText = false,
    required this.hintText,
    required this.controller,
    this.validators,
    this.textInputType = TextInputType.text,
    this.contentPadding = EdgeInsets.zero,
    this.maxLine = 1,
    this.enabled = true,
    this.maxLength = 300,
    required this.textCapitalization,
  });

  final bool obscureText;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validators;
  final TextInputType textInputType;
  final EdgeInsets contentPadding;
  final int maxLine;
  final bool enabled;
  final int maxLength;
  final TextCapitalization textCapitalization;

  @override
  State<_AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<_AppInput> {
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: widget.obscureText ? hidePassword : widget.obscureText,
        validator: widget.validators,
        keyboardType: widget.textInputType,
        textCapitalization: widget.textCapitalization,
        controller: widget.controller,
        maxLines: widget.maxLine,
        maxLength: widget.maxLength,
        enabled: widget.enabled,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            counterText: "",
            contentPadding: const EdgeInsets.all(8),
            fillColor: Colors.white,
            filled: true,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: hidePassword ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
                  )
                : null,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            errorStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ConstantColors.textFieldBoarderColor, width: 0.7),
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: ConstantColors.hintTextColor)));
  }
}
