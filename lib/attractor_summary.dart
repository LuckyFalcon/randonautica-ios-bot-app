import 'package:flutter/material.dart';
import 'package:randonautica/separator.dart';
import 'package:randonautica/text_style.dart';

import 'Randonaut.dart';
import 'attractordetails.dart';

class attractorSummary extends StatelessWidget {
  final Attractor attractor;
  final bool horizontal;

  attractorSummary(this.attractor, {this.horizontal = true});

  attractorSummary.vertical(this.attractor) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    final attractorThumbnail = new Container(
      margin: new EdgeInsets.symmetric(vertical: 30.0),
      alignment:
          horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: new Hero(
        tag: "attractor-hero-${attractor.id}",
        child: new Image(
            image: new AssetImage(attractor.image),
            height: 92.0,
            width: 92.0,
            fit: BoxFit.fill),
      ),
    );

    Widget _attractorValue({String value, String image}) {
      return new Container(
        child: new Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          new Image.asset(image, height: 25.0),
          new Container(width: 8.0),
          new Text(attractor.gravity, style: Style.smallTextStyle),
        ]),
      );
    }

    final attractorCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(
          horizontal ? 76.0 : 16.0, horizontal ? 16.0 : 42.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
      child: new Column(
        crossAxisAlignment:
            horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: <Widget>[
          new Container(height: 4.0),
          new Text(attractor.name, style: Style.titleTextStyle),
          new Container(height: 10.0),
          new Text(attractor.location, style: Style.commonTextStyle),
          new Separator(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                  flex: horizontal ? 1 : 0,
                  child: _attractorValue(
                      value: attractor.distance,
                      image: 'assets/img/ic_distance.png')),
              new Container(
                width: 32.0,
              ),
              new Expanded(
                  flex: horizontal ? 1 : 0,
                  child: _attractorValue(
                      value: attractor.gravity,
                      image: 'assets/img/ic_gravity.png'))
            ],
          ),
        ],
      ),
    );

    final attractorCard = new Container(
      child: attractorCardContent,
      height: horizontal ? 124.0 : 170.0,
      margin: horizontal
          ? new EdgeInsets.only(left: 46.0)
          : new EdgeInsets.only(top: 72.0),
      decoration: new BoxDecoration(
        color: new Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          new BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return new GestureDetector(
        onTap: horizontal
            ? () => Navigator.of(context).push(
                  new PageRouteBuilder(
                    pageBuilder: (_, __, ___) => new DetailPage(attractor),
                    transitionsBuilder: (context, animation, secondaryAnimation,
                            child) =>
                        new FadeTransition(opacity: animation, child: child),
                  ),
                )
            : null,
        child: new Container(
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: new Stack(
            children: <Widget>[
              attractorCard,
              attractorThumbnail,
            ],
          ),
        ));
  }
}
