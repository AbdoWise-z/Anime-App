import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RippleTextFormField extends StatelessWidget {
  final Color ripple;
  final Color background;
  final double corners;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final EdgeInsets padding;
  final TextStyle? style;
  final bool autoFocus;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? formatter;
  final Function(String)? onSubmit;
  final Function()? onEditingComplete;
  final int? maxLength;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;

  const RippleTextFormField({Key? key, this.ripple = Colors.blue, this.background = const Color(0x1200ff00), this.corners = 20, this.decoration, this.onChanged, this.controller, this.focusNode, this.padding = const EdgeInsets.fromLTRB(0 , 0, 0, 0), this.style, this.autoFocus = false, this.validator, this.formatter, this.keyboardType, this.onSubmit, this.onEditingComplete, this.maxLength, this.readOnly = false, this.maxLines, this.minLines}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: ripple),
        child: Material(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(corners)),
          clipBehavior: Clip.hardEdge,
          color: background,
          child: InkWell(
            child: Padding(
              padding: padding,
              child: TextFormField(
                maxLength: maxLength,
                validator: validator,
                decoration: decoration,
                onChanged: onChanged,
                style: style,
                autofocus: autoFocus,
                controller: controller,
                focusNode: focusNode,
                keyboardType: keyboardType,
                inputFormatters: formatter,
                onEditingComplete: onEditingComplete,
                onFieldSubmitted: onSubmit,
                readOnly: readOnly,
                maxLines: maxLength,
                minLines: minLines,
              ),
            ),
            onTap: () {
            },
          ),
      ),
    );
  }
}
