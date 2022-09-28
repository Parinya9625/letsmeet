import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/models/feedback.dart' as lm;
import 'package:letsmeet/services/firestore.dart';
import 'package:letsmeet/components/input_field.dart';
import 'package:letsmeet/components/admin/detail_dialog.dart';
import 'package:letsmeet/components/admin/responsive_layout.dart';
import 'package:intl/intl.dart';

class FeedbacksPage extends StatefulWidget {
  const FeedbacksPage({Key? key}) : super(key: key);

  @override
  State<FeedbacksPage> createState() => _FeedbacksPageState();
}

class _FeedbacksPageState extends State<FeedbacksPage> {
  void confirmRemoveFeedback(
      BuildContext detailContext, lm.Feedback feedback) async {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text("Confirm remove feedback"),
            content:
                const Text('Are you sure you want to remove this feedback?'),
            actions: [
              TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  }),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).errorColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    elevation: 0,
                  ),
                  child: const Text("Remove"),
                  onPressed: () {
                    context.read<CloudFirestoreService>().removeFeedback(
                          id: feedback.id!,
                        );

                    Navigator.pop(dialogContext);
                    Navigator.pop(detailContext);
                  }),
            ],
          );
        });
  }

  void feedbackDialog({required lm.Feedback feedback}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DetailDialog(
              width: 512,
              menus: [
                DetailDialogMenuButton(
                  icon: Icons.delete_rounded,
                  onPressed: () {
                    confirmRemoveFeedback(context, feedback);
                  },
                ),
                DetailDialogMenuButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback.message,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat("EEE, dd MMM y, HH:mm")
                            .format(feedback.createdTime),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget feedbackCard(lm.Feedback feedback) {
    return GestureDetector(
      onTap: () {
        feedbackDialog(
          feedback: feedback,
        );
      },
      child: Card(
        margin: const EdgeInsets.all(2),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  feedback.message,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat("EEE, dd MMM y, HH:mm")
                        .format(feedback.createdTime),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<lm.Feedback> listFeedback = context.watch<List<lm.Feedback>>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Feedbacks (${listFeedback.length})",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: ResponsiveValue(
                  context: context,
                  small: 2,
                  medium: 3,
                  large: 4,
                  extraLarge: 5,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 2 / 1,
                children: [
                  for (lm.Feedback feedback in listFeedback) ...{
                    feedbackCard(feedback),
                  },
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
