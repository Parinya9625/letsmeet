import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class TOSPage extends StatefulWidget {
  const TOSPage({Key? key}) : super(key: key);

  @override
  State<TOSPage> createState() => _TOSPageState();
}

class _TOSPageState extends State<TOSPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: FutureBuilder(
          future:
              DefaultAssetBundle.of(context).loadString("lib/assets/tos.md"),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return Markdown(
              selectable: true,
              data: snapshot.data,
              extensionSet: md.ExtensionSet(
                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                [
                  md.EmojiSyntax(),
                  ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                ],
              ),
            );
          }),
    );
  }
}
