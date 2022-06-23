import 'package:cached_network_image/cached_network_image.dart';
import "package:flutter/material.dart";
import 'package:letsmeet/components/controllers/review_user_controller.dart';
import 'package:letsmeet/models/user.dart';
import 'package:letsmeet/style.dart';

class ReviewUserCard extends StatefulWidget {
  final User user;
  final ReviewUserController controller;

  const ReviewUserCard({Key? key, required this.controller, required this.user})
      : super(key: key);

  @override
  State<ReviewUserCard> createState() => _ReviewUserCardState();
}

class _ReviewUserCardState extends State<ReviewUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.user.image,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.user.name} ${widget.user.surname}",
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (int i = 1; i < 6; i++) ...{
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.controller.value = i;
                              });
                            },
                            child: Icon(
                              i <= widget.controller.value
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Theme.of(context)
                                  .extension<LetsMeetColor>()!
                                  .rating,
                            ),
                          ),
                        }
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
