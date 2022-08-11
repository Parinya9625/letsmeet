import 'package:flutter/material.dart';

class BaseSearchFilter extends StatefulWidget {
  final String title;
  final dynamic value;
  final Widget child;
  final VoidCallback? onOpen;
  final VoidCallback? onApply;
  final VoidCallback? onClear;
  final VoidCallback? onClose;

  const BaseSearchFilter({
    Key? key,
    required this.title,
    required this.child,
    this.value,
    this.onOpen,
    this.onApply,
    this.onClear,
    this.onClose,
  }) : super(key: key);

  @override
  State<BaseSearchFilter> createState() => _BaseSearchFilterState();
}

class _BaseSearchFilterState extends State<BaseSearchFilter> {
  void showFilterOption() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const Spacer(),
                  if (widget.onClear != null) ...{
                    TextButton(
                      onPressed: widget.onClear,
                      style: Theme.of(context).textButtonTheme.style!.copyWith(
                        overlayColor: MaterialStateProperty.resolveWith(
                          (states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.transparent;
                            }
                            return Theme.of(context)
                                .errorColor
                                .withOpacity(0.1);
                          },
                        ),
                      ),
                      child: Text(
                        "Clear",
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                              color: Theme.of(context).errorColor,
                            ),
                      ),
                    ),
                  },
                ],
              ),
              // const SizedBox(height: 4),
              widget.child,
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply?.call();
                        Navigator.pop(context);
                      },
                      child: const Text("APPLY"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          widget.onOpen?.call();
          showFilterOption();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value.toString(),
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.expand_more_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
