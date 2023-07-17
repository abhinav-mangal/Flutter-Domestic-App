import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:characters/characters.dart';
import 'package:flutter/services.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';
import '../utils/theme/colors.dart';
import 'masked_textInput_formatter.dart';

class CustomTextField extends StatefulWidget {
  final BuildContext? context;
  final EdgeInsetsDirectional? padding;
  final TextEditingController? controller;
  final FocusNode? focussNode;
  final FocusNode? nextFoucs;
  final String? lableText;
  final String? hindText;
  final String? errorText;
  final TextInputType? inputType;
  final TextCapitalization? capitalization;
  final TextInputAction? inputAction;
  final bool? isObscureText;
  final Widget? prefixWidget;
  final Widget? sufixWidget;
  final EdgeInsetsDirectional? contentPadding;
  final Function(String)? onchange;
  final Function(String)? onSubmit;
  final int? maxline;
  final int? maxlength;
  final bool? isEnable;
  final bool? isShowBorderOnUnFocus;
  final bool? isAutocorrect;
  final bool? enableSuggestions;
  final bool? isMobileField;
  final bool? showHint;
  final bool? showFlotingHint;
  final bool? isCircleCorner;
  final Color? bgColor;
  final Alignment? stackAlignment;
  final TextStyle? mainTextStyle;
  final TextStyle? hintTextStyle;
  final bool? isAutoFocuesd;
  final String? prefixTxt;
  final bool? isShowCounter;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool isAGradientShadow;
  CustomTextField(
      {this.context,
      this.padding,
      this.controller,
      this.focussNode,
      this.nextFoucs,
      this.lableText,
      this.hindText,
      this.errorText,
      this.inputType,
      this.capitalization,
      this.inputAction,
      this.isObscureText,
      this.prefixWidget,
      this.sufixWidget,
      this.contentPadding,
      this.onchange,
      this.onSubmit,
      this.maxline,
      this.maxlength,
      this.isEnable = true,
      this.isShowBorderOnUnFocus = true,
      this.isAutocorrect = false,
      this.enableSuggestions = false,
      this.isMobileField = false,
      this.showHint = true,
      this.showFlotingHint = false,
      this.isCircleCorner = false,
      this.bgColor,
      this.stackAlignment,
      this.mainTextStyle,
      this.hintTextStyle,
      this.isAutoFocuesd = false,
      this.prefixTxt = '',
      this.isShowCounter = false,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.isAGradientShadow = false});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    AppConfig config = AppConfig.of(context);
    double cornerRadius = widget.isCircleCorner! ? 12.0 : 4.0;
    return Container(
      decoration: widget.isAGradientShadow ? decoration() : null,
      padding:
          widget.padding ?? const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Stack(
        alignment: widget.stackAlignment != null
            ? widget.stackAlignment!
            : widget.prefixWidget != null
                ? Alignment.topLeft
                : Alignment.topRight,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focussNode,
            keyboardType: widget.inputType ?? TextInputType.text,
            keyboardAppearance: config.brightness,
            textCapitalization:
                widget.capitalization ?? TextCapitalization.none,
            textInputAction: widget.inputAction ?? TextInputAction.next,
            obscureText: widget.isObscureText ?? false,
            onChanged: widget.onchange,
            onSubmitted: widget.onSubmit,
            maxLines: widget.maxline,
            enabled: widget.isEnable,
            maxLength: widget.maxlength,
            // maxLengthEnforced: widget.maxlength != null,
            enableInteractiveSelection: true,
            autocorrect: widget.isAutocorrect!,
            autofocus: widget.isAutoFocuesd!,
            enableSuggestions: widget.enableSuggestions!,
            buildCounter: (BuildContext? context,
                {int? currentLength, int? maxLength, bool? isFocused}) {
              if (widget.isShowCounter!) {
                return Text(
                  '$currentLength/$maxLength',
                  style: config.calibriHeading3FontStyle.apply(
                    color: config.greyColor,
                  ),
                );
              } else {
                return null;
              }
            },

            //enabled: controller != _txtFieldCountryCode,
            style: widget.mainTextStyle != null
                ? widget.mainTextStyle
                : config.calibriHeading3FontStyle.apply(
                    color: config.whiteColor,
                  ),
            inputFormatters: <TextInputFormatter>[
              if (widget.maxlength != null)
                LengthLimitingTextFieldFormatterFixed(widget.maxlength!),
              if (widget.inputType == TextInputType.phone ||
                  widget.inputType == TextInputType.number)
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9-]+$')),
              if (widget.isMobileField!)
                MaskedTextInputFormatter(
                    mask: 'xxx-xxx-xxxxxx', separator: '-'),
            ],
            decoration: InputDecoration(
              fillColor:
                  widget.bgColor != null ? widget.bgColor : Colors.transparent,
              filled: widget.bgColor != null,
              labelText: widget.lableText,
              hintText: widget.showHint! ? '' : widget.hindText,
              //hasFloatingPlaceholder: widget?.showFlotingHint ?? false,
              errorText: widget.errorText,
              labelStyle: widget.hintTextStyle ??
                  config.labelNormalFontStyle.apply(
                    color: config.greyColor,
                  ),
              hintStyle: widget.hintTextStyle ??
                  config.paragraphExtraSmallFontStyle
                      .apply(color: config.greyColor),
              errorMaxLines: 4,
              prefixText: widget.prefixTxt,
              //hintStyle: ,
              prefixIcon:
                  widget.prefixTxt!.isNotEmpty ? Text(widget.prefixTxt!) : null,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              //suffixIcon: widget.sufixWidget,
              floatingLabelBehavior: widget.floatingLabelBehavior,
              contentPadding: widget.contentPadding ??
                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              border: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              disabledBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              enabledBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              focusedBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
            ),
          ),
          if (widget.prefixWidget != null)
            Positioned(
              left: 0,
              child: widget.prefixWidget!,
            )
          else
            const SizedBox(),
          if (widget.sufixWidget != null)
            Positioned(
              right: 0,
              child: widget.sufixWidget!,
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  BoxDecoration? decoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      gradient: LinearGradient(
        colors: [AppColors.black, AppColors.greyColor2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white24,
          blurRadius: 2,
          offset: const Offset(1, 1),
          spreadRadius: 1,
        ),
      ],
    );
  }
}

/// TextInputFormatter that fixes the regression.
/// https://github.com/flutter/flutter/issues/67236
///
/// Remove it once the issue above is fixed.
class LengthLimitingTextFieldFormatterFixed
    extends LengthLimitingTextInputFormatter {
  LengthLimitingTextFieldFormatterFixed(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength! > 0 &&
        newValue.text.characters.length > maxLength!) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      return LengthLimitingTextInputFormatter.truncate(newValue, maxLength!);
    }
    return newValue;
  }
}
