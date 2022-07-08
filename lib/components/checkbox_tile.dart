import 'package:flutter/material.dart';
import 'package:letsmeet/components/controllers/checkbox_tile_controller.dart';

class CheckboxTile extends StatefulWidget {
  final CheckboxTileController controller;
  final Widget? title;

  const CheckboxTile({Key? key, required this.controller, this.title})
      : super(key: key);

  @override
  State<CheckboxTile> createState() => _CheckboxTileState();
}

class _CheckboxTileState extends State<CheckboxTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            widget.controller.value = !widget.controller.value!;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Row(
            children: [
              Checkbox(
                visualDensity:
                    const VisualDensity(vertical: -2, horizontal: -2),
                value: widget.controller.value,
                onChanged: (value) {
                  setState(() {
                    widget.controller.value = value;
                  });
                },
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
      ),
    );
  }
}
