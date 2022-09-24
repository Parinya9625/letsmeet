import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/checkbox_tile_controller.dart';

class CheckboxTile extends StatefulWidget {
  final CheckboxTileController controller;
  final Widget? title;
  final String? errorText;
  final double? elevation;
  final bool disable;

  const CheckboxTile({
    Key? key,
    required this.controller,
    this.title,
    this.errorText,
    this.elevation,
    this.disable = false,
  }) : super(key: key);

  @override
  State<CheckboxTile> createState() => CheckboxTileState();
}

class CheckboxTileState extends State<CheckboxTile> {
  bool _isValid = true;

  bool validate() {
    setState(() {
      _isValid = widget.controller.value ?? false;
    });
    return widget.controller.value ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.disable
            ? null
            : () {
                setState(() {
                  _isValid = true;
                  widget.controller.value = !widget.controller.value!;
                });
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    visualDensity:
                        const VisualDensity(vertical: -2, horizontal: -2),
                    value: widget.controller.value,
                    onChanged: widget.disable
                        ? null
                        : (value) {
                            setState(() {
                              _isValid = true;
                              widget.controller.value = value;
                            });
                          },
                    fillColor: widget.disable
                        ? MaterialStateProperty.all(
                            Theme.of(context).disabledColor)
                        : !_isValid
                            ? MaterialStateProperty.all(
                                Theme.of(context).errorColor)
                            : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: widget.title,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isValid && widget.errorText != null) ...{
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  widget.errorText!,
                  style: Theme.of(context).inputDecorationTheme.errorStyle,
                ),
              ),
            },
          ],
        ),
      ),
    );
  }
}
