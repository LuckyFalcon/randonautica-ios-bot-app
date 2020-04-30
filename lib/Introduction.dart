import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import 'main.dart';

class Introduction extends StatelessWidget {
  const Introduction({Key key}) : super(key: key);

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MyStatefulWidget()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/$assetName.jpg', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Introduction",
          body:
          "The Randonautica app puts the user in the Director's Chair of an adventure story yet to be written. By using the app, the user can break from their mundane day-to-day and take a journey of randomness into the world around them.",
          image: _buildImage('img1'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Generate",
          body:
          "Generate a random location using Quantum Randomness",
          image: _buildImage('img2'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Navigate",
          body:
          "Navigate and visit the location.",
          image: _buildImage('navigate'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Explore",
          body: "Explore the world you never knew existed.",
          image: _buildImage('img3'),
          footer: RaisedButton(
            onPressed: () {/* Nothing */},
            child: const Text(
              'FooButton',
              style: TextStyle(color: Colors.white),
            ),
            color: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Title of last page",
          bodyWidget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("Click on ", style: bodyStyle),
              Icon(Icons.edit),
              Text(" to edit a post", style: bodyStyle),
            ],
          ),
          image: _buildImage('img1'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
