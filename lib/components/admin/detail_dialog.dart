import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailDialog extends StatefulWidget {
  final double? width;
  final double? height;
  final List<Widget>? menus;
  final Widget child;

  const DetailDialog({
    Key? key,
    this.width,
    this.height,
    this.menus,
    required this.child,
  }) : super(key: key);

  @override
  State<DetailDialog> createState() => _DetailDialogState();
}

class _DetailDialogState extends State<DetailDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.menus ?? [],
              ),
              const SizedBox(height: 16),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

class DetailDialogMenuButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final Color? color;
  final bool visible;

  const DetailDialogMenuButton({
    Key? key,
    this.onPressed,
    this.icon,
    this.child,
    this.color,
    this.visible = true,
  }) : super(key: key);

  @override
  State<DetailDialogMenuButton> createState() => _DetailDialogMenuButtonState();
}

class _DetailDialogMenuButtonState extends State<DetailDialogMenuButton> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          width: widget.child == null ? 48 : null,
          height: 48,
          child: widget.child != null
              ? TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    foregroundColor: widget.color,
                  ),
                  onPressed: widget.onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    child: widget.child!,
                  ),
                )
              : TextButton(
                  style: TextButton.styleFrom(
                    shape: const CircleBorder(),
                    foregroundColor: widget.color,
                  ),
                  onPressed: widget.onPressed,
                  child: widget.icon?.fontPackage == "font_awesome_flutter"
                      ? FaIcon(widget.icon)
                      : Icon(widget.icon),
                ),
        ),
      ),
    );
  }
}
