import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String obscuringCharacter;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool? enabled;
  final bool enableSuggestions;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final Widget? icon;
  final VoidCallback? onClear;
  final Color? backgroundColor;
  final double elevation;
  final EdgeInsetsGeometry? contentPadding;

  /// By defalut when a [onClear] is specified. it will clear a text
  /// in [controller] first (without having to specify) and then
  /// run [onClear] function after. By set this [preventDefalutClear] to `true`
  /// in will not clear [controller] and user have to implement by yourself.
  final bool preventDefaultClear;

  const InputField({
    Key? key,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.enabled,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.inputFormatters,
    this.hintText,
    this.icon,
    this.onClear,
    this.preventDefaultClear = false,
    this.backgroundColor,
    this.elevation = 1.0,
    this.contentPadding,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  TextEditingController controller = TextEditingController();
  late FocusNode focusNode = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor ?? Theme.of(context).cardColor,
      elevation: widget.elevation,
      borderRadius: const BorderRadius.all(
        Radius.circular(16),
      ),
      child: TextFormField(
        controller: widget.controller ?? controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        obscuringCharacter: widget.obscuringCharacter,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        focusNode: focusNode,
        decoration: InputDecoration(
          contentPadding: widget.contentPadding,
          fillColor: widget.backgroundColor ?? Theme.of(context).cardColor,
          hintText: widget.hintText,
          prefixIcon: widget.icon,
          suffixIcon:
              focusNode.hasFocus && widget.onClear != null && !widget.readOnly
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        if (!widget.preventDefaultClear) {
                          controller.clear();
                          widget.controller?.clear();
                        }
                        widget.onClear!();
                      },
                    )
                  : null,
        ),
        enabled: widget.enabled,
        enableSuggestions: widget.enableSuggestions,
        inputFormatters: widget.inputFormatters,
        buildCounter: (
          context, {
          required currentLength,
          required isFocused,
          required maxLength,
        }) {
          TextEditingController currentController =
              widget.controller ?? controller;

          int currentTextLength = currentController.text.trim().length;

          if (isFocused && maxLength != null ||
              (maxLength != null && currentTextLength > maxLength)) {
            return Text(
              "$currentTextLength / $maxLength\n",
              style: TextStyle(
                color: currentTextLength <= maxLength
                    ? Theme.of(context).textTheme.bodyText1!.color
                    : Theme.of(context).errorColor,
                fontSize: 12,
                fontWeight:
                    currentTextLength > maxLength ? FontWeight.bold : null,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}
