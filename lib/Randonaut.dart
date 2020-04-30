import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:randonautica/attractordetails.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Randonaut extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: new Color(0xFF736AB7),
      body: new Column(
        children: <Widget>[
          //new GradientAppBar("treva"),
          new RandonautPageBody(),
          FlatButton(
            color: Colors.blue,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(20.0),
            splashColor: Colors.blueAccent,
            onPressed: () {
              /*...*/
            },
            child: Text(
              "Start Randonauting",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Container(
            width: 32.0,
            height: 20,
          )
        ],
      ),
    );
  }

}

class RandonautPageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Expanded(
      child: new Container(
        child: new CustomScrollView(
          scrollDirection: Axis.vertical,
          shrinkWrap: false,
          slivers: <Widget>[
            new SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              sliver: new SliverList(
                delegate: new SliverChildBuilderDelegate(
                      (context, index) => new attractorRow(attractors[index]),
                  childCount: attractors.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Attractor {
  final String id;
  final String name;
  final String location;
  final String distance;
  final String gravity;
  final String description;
  final String image;
  final String picture;

  const Attractor({this.id, this.name, this.location, this.distance, this.gravity,
    this.description, this.image, this.picture});
}

List<Attractor> attractors = [
  const Attractor(
    id: "1",
    name: "Attractor",
    location: "Near Gorilla Avunue street",
    distance: "54.6m",
    gravity: "2.0 ",
    description: "This Attractor has a radius of 54.6m and falls in the legendary score category. Visiting this point might have interesting results!" ,
    image: "assets/reacticon.png",
    picture: "assets/owlbackground.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  ),
  const Attractor(
    id: "2",
    name: "Void",
    location: "Near ... street",
    distance: "54.6m",
    gravity: "3.711 ",
    description: "Lorem ipsum...",
    image: "assets/reacticon.png",
    picture: "assets/owlbackgroundtest.png",
  )
];

class attractorRow extends StatelessWidget {

  final Attractor attractor;

  attractorRow(this.attractor);

  @override
  Widget build(BuildContext context) {
    final attractorThumbnail = new Container(
      margin: new EdgeInsets.symmetric(
          vertical: 16.0
      ),
      alignment: FractionalOffset.centerLeft,
      child: new Image(
        image: new AssetImage("assets/reacticon.png"),
          height: 92.0,
          width: 92.0,
          fit:BoxFit.fill
      ),
    );

    final baseTextStyle = const TextStyle(
        fontFamily: 'Poppins'
    );
    final regularTextStyle = baseTextStyle.copyWith(
        color: const Color(0xffb6b2df),
        fontSize: 12.0,
        fontWeight: FontWeight.w400
    );
    final subHeaderTextStyle = regularTextStyle.copyWith(
        fontSize: 12.0
    );
    final headerTextStyle = baseTextStyle.copyWith(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.w600
    );

    Widget _attractorValue({String value, String image}) {
      return new Row(
          children: <Widget>[
            new Image.asset(image, height: 12.0),
            new Container(width: 8.0),
            new Text(attractor.gravity, style: regularTextStyle),
          ]
      );
    }


    final attractorCardContent = new Container(
      margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
      constraints: new BoxConstraints.expand(),
        child: new Row(
          children: [
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(height: 4.0),
                  new Text(attractor.name,
                    style: headerTextStyle,
                  ),
                  new Container(height: 10.0),
                  new Text(attractor.location,
                      style: subHeaderTextStyle

                  ),
                  new Container(
                      margin: new EdgeInsets.symmetric(vertical: 8.0),
                      height: 2.0,
                      width: 18.0,
                      color: new Color(0xff00c6ff)
                  ),
                  new Row(
                    children: <Widget>[
                      new Image.asset("assets/img/ic_distance.png", height: 12.0),
                      new Container(width: 8.0),
                      new Text(attractor.distance,
                        style: regularTextStyle,
                      ),
                      new Container(width: 24.0),
                      new Image.asset("assets/img/ic_gravity.png", height: 12.0),
                      new Container(width: 8.0),
                      new Text(attractor.gravity,
                        style: regularTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            new Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  new IconButton(
                      icon: new Icon(Icons.keyboard_arrow_right,
                        size: 60.0,
                        color: Colors.white,
                      ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailPage(attractor)),
                      );

                    },
                  ),
                  ]
            )
          ],
        ),
    );

    final attractorCard = new Container(
      child: attractorCardContent,
      height: 124.0,
      margin: new EdgeInsets.only(left: 46.0),
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


    return new Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: new Stack(
          children: <Widget>[
            attractorCard,
            attractorThumbnail,
          ],
        )
    );
  }
}

//Open a new page with a WebView
class openNavigation extends StatelessWidget {
  //Example of coordinates
  static LatLng currentLocation = new LatLng(51.5, -0.09);
  static LatLng attractorCoordinates = new LatLng(51.7, -0.09);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Randonautica"),
      ),
      body: Center(
        child: WebView(
          initialUrl: "https://www.google.com/maps/place/" + currentLocation.latitude.toString() + "+" + currentLocation.latitude.toString() + "/@" + attractorCoordinates.latitude.toString() + "+" + attractorCoordinates.latitude.toString() + ",14z",
          javascriptMode: JavascriptMode.unrestricted,
        )
      ),
    );
  }
}
