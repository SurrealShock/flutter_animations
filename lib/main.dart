import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

enum Animate { idle, animating }

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<AnimationController> controller = [];
  List<Animation> colorWidth = [];
  Animate animate = Animate.idle;
  List<Animation> colorHeight = [];
  List<Animation> borderRadius = [];
  List<Animation> width;
  List<List<Color>> colors = [];
  List<Color> backgroundColor = [Colors.white, Colors.white];
  var i = 0;
  PageController pageController = PageController(viewportFraction: 1.0);
  @override
  void initState() {
    colors.add([Colors.blue[600], Colors.blue[300]]);
    colors.add([Colors.red[600], Colors.red[300]]);
    colors.add([Colors.green[600], Colors.green[300]]);
    colors.add([Colors.cyan[600], Colors.cyan[300]]);
    colors.add([Colors.purple[600], Colors.purple[300]]);
    colors.add([Colors.pink[600], Colors.pink[300]]);
    colors.add([Colors.yellow[600], Colors.yellow[300]]);
    colors.add([Colors.orange[600], Colors.orange[300]]);
    colors.add([Colors.amber[600], Colors.amber[300]]);
    colors.add([Colors.teal[600], Colors.teal[300]]);

    for (var i = 0; i < 10; i++) {
      controller.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 250)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _handleAnimation(int index) {
      i = index;
      setState(() {
        animate = Animate.animating;
      });
      controller[index].isCompleted
          ? controller[index].reverse()
          : controller[index].forward();
    }

    _handleColorStatus(status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          controller[i].reset();
          backgroundColor = colors[i];
        });
      }
    }

    for (var i = 0; i < 10; i++) {
      borderRadius.add(Tween(
        begin: 300.0,
        end: 0.0,
      ).animate(
          CurvedAnimation(parent: controller[i], curve: Interval(0.3, 1.0)))
        ..addListener(() {
          setState(() {});
        }));

      colorWidth.add(Tween(
        begin: 0.0,
        end: MediaQuery.of(context).size.width,
      ).animate(
          CurvedAnimation(parent: controller[i], curve: Interval(0.0, 1.0)))
        ..addListener(() {
          setState(() {});
        }));
      colorHeight.add(Tween(
        begin: 0.0,
        end: MediaQuery.of(context).size.height,
      ).animate(CurvedAnimation(
          parent: controller[i],
          curve: Interval(0.0, 1.0, curve: Curves.easeIn)))
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener(_handleColorStatus));
    }

    return new Scaffold(
        body: Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: backgroundColor)),
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: colors[i]),
                borderRadius: BorderRadius.circular(borderRadius[i].value)),
            width: colorWidth[i].value,
            height: colorHeight[i].value,
          ),
        ),
        ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  _handleAnimation(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: colors[index]),
                      borderRadius: BorderRadius.circular(25.0)),
                  width: 50.0,
                  height: 50.0,
                ),
              ),
            );
          },
        )
      ],
    ));
  }
}
