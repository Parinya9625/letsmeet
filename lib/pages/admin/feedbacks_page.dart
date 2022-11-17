import 'package:flutter/material.dart';
import 'package:letsmeet/models/user.dart';
import 'package:provider/provider.dart';
import 'package:letsmeet/models/feedback.dart' as lm;
import 'package:letsmeet/services/firestore.dart';
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

  void feedbackDialog({required lm.Feedback feedback, User? user}) {
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
                        user != null ? "${user.name} ${user.surname}" : "...",
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ],
                  ),
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
    User? user;
    return GestureDetector(
      onTap: () {
        feedbackDialog(
          feedback: feedback,
          user: user,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FutureBuilder(
                    future: feedback.getBy,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("...");
                      }

                      user = snapshot.data;

                      return Expanded(
                        child: Text(
                          "${user!.name} ${user!.surname}",
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      DateFormat("EEE, dd MMM y, HH:mm")
                          .format(feedback.createdTime),
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
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
                  small: 1,
                  medium: 2,
                  large: 3,
                  extraLarge: 4,
                ),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: ResponsiveValue(
                  context: context,
                  small: 2.5 / 1,
                  medium: 2.3 / 1,
                  large: 2.5 / 1,
                  extraLarge: 2 / 1,
                ),
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
