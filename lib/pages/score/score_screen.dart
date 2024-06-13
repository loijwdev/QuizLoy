import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:quiz_loy/pages/constant.dart';

class ScoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kết quả"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SvgPicture.asset("assets/logo/bg.svg", fit: BoxFit.fill),
            Column(
              children: [
                Spacer(flex: 3),
                Text(
                  "Score",
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: kSecondaryColor),
                ),
                Spacer(),
                Text(
                  "4/5",
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(color: kSecondaryColor),
                ),
                Spacer(flex: 3),
              ],
            )
          ],
        ),
      ),
    );
  }
}
