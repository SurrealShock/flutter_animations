import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  // Create lists for the animation controller, width, height, border radius
  // and colors for each dot.
  List<AnimationController> controller = [];
  List<Animation> animateWidth = [];
  List<Animation> animateHeight = [];
  List<Animation> borderRadius = [];
  PageController pageController;
  List<List<Color>> colors = [];
  double width;
  double height;
  double dx = 0.0;
  double dy = 0.0;
  List<Color> backgroundColor = [Colors.white, Colors.white];
  var i = 1;

  @override
  void initState() {
    // Initialize the color array
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

    // Create animation controllers for each color dot
    for (var i = 0; i < 10; i++) {
      controller.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 500)));
    }

    for (var i = 0; i < 10; i++) {
      // Initialize the animations for each dot
      // Tween allows for simple animations where it
      // interpolates the values inbetween the begin and end
      borderRadius.add(Tween(
        begin: 200.0,
        end: 0.0,
      ).animate(
          // We can create a curved animation that starts
          // slightly later than the width and height animation
          // This gives the appearance that its is a circle at first
          // which turns into a rectangle
          CurvedAnimation(parent: controller[i], curve: Interval(0.3, 1.0)))
        ..addListener(() {
          setState(() {});
        }));

      // The container should start at 0.0 where it is not visible
      // then expand to the height of the screen. I set animateWidth
      // to be height rather than width because if not height will
      // expand at a quicker rate than the width due to the height
      // being larger than the width. The user won't be able to notice
      // that it goes past max width of the screen but creates an
      // interesting effect.
      animateWidth.add(Tween(
        begin: 0.0,
        end: 1000.0,
      ).animate(
          CurvedAnimation(parent: controller[i], curve: Interval(0.0, 1.0)))
        ..addListener(() {
          setState(() {});
        }));

      // We could use animateWidth for height and width, but if I want
      // to edit the animation in the future I can easily modify it here.
      animateHeight.add(Tween(
        begin: 0.0,
        end: 1000.0,
      ).animate(
          CurvedAnimation(parent: controller[i], curve: Interval(0.0, 1.0)))
        ..addListener(() {
          setState(() {});
        })
        ..addStatusListener(_handleBackground));
    }

    super.initState();
  }

  double _normalize(double dataIn, double axis) {
    return ((dataIn) - (axis / 2)) / (axis - (axis / 2));
  }

  // When _handleBackground is called it takes the status of
  // the animation. If the animation is complete the background
  // is changed to the animated color, so when a new color begins
  // to animate it animates over the previous color. White is the
  // default background.

  void _handleBackground(status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        // Also reset the previous controller so if it is pressed
        // again it animates forward rather than not animating.
        controller[i].reset();
        backgroundColor = colors[i];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _handleAnimation(int index) {
      i = index;
      controller[index].forward();
    }

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    pageController = PageController(viewportFraction: 1 / (width / 115));

    return new Scaffold(
      // The stack allows for displaying items on top of each other
      body: Stack(
        children: <Widget>[
          // Here this creates a container which is the background
          // I pass it the value of backgroundColor which changes each
          // the animation finishes. This allows for the appearence that
          // each animation animates over the previous color.
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: backgroundColor)),
          ),
          // This is the container that actually does the animation
          // The width and height are updated each frame as it animates
          // because we added an empty listener for setState(() {})
          Center(
            child: Container(
                child: new Align(
                    alignment: Alignment(
                        _normalize(dx, width), _normalize(dy, height)),
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: colors[i]),
                          borderRadius:
                              BorderRadius.circular(borderRadius[i].value)),
                      width: animateWidth[i].value,
                      height: animateHeight[i].value,
                    ))),
          ),
          ListView.builder(
			  padding: EdgeInsets.only(right: 40.0),
            // Scroll horizontally
            scrollDirection: Axis.horizontal,
            // Create a page controller with a viewport fraction
            // that snaps to each dot. 115 = dot width + padding
            controller: pageController,
            // PageScrollPhysics are required for item snapping
            physics: PageScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Align(
                // Align the dots to center
                alignment: Alignment.center,
                // Create a gesture detector which handles what
                // happens when one of the dots are pressed
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    dx = details.globalPosition.dx;
                    dy = details.globalPosition.dy;
                    print("$dx : $dy");
                  },
                  onTap: () {
                    if (index != 0 && index != 9) {
                      pageController.animateToPage(index - 1,
                          curve: Curves.easeInOut,
                          duration: Duration(milliseconds: 750));
                    }
                    _handleAnimation(index);
                  },
                  child: ColorDot(colors[index]),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.arrow_forward),
        label: Text('Next'),
        onPressed: () {
          // Navigator is used to create a new page
          // Pass context, and create builder for new page
          Navigator
              .of(context)
              .push(MaterialPageRoute(builder: (cntx) => DemoPage(colors[i])));
        },
        backgroundColor: backgroundColor[0],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ColorDot extends StatelessWidget {
  final color;
  ColorDot(this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      // Space out the dots such they are not touching
      padding: const EdgeInsets.only(left: 40.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1.5),
          shape: BoxShape.circle,
          // Gradient that starts at the bottom left
          // and ends at the top right
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: color),
        ),
        // Define the dimensions of the color dots
        width: 75.0,
        height: 75.0,
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  // Create constructor that takes color parameter
  final color;
  DemoPage(this.color);
  DemoPageState createState() => DemoPageState(color);
}

class DemoPageState extends State<DemoPage> {
  final color;
  DemoPageState(this.color);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 225.0,
            width: 225.0,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(225.0)),
                color: color[0]),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (cntx) => HeroPage(color)));
                      },
                      child: Hero(
                        tag: 0,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: color),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0.0, 2.0),
                                    color: color[0].withOpacity(0.3),
                                    spreadRadius: 2.0,
                                    blurRadius: 3.5)
                              ]),
                          width: 150.0,
                          height: 150.0,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Hero',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.arrow_back),
        label: Text('Back'),
        onPressed: () {
          // Navigator is used to create a new page
          // Pass context, and create builder for new page
          Navigator.of(context).pop();
        },
        backgroundColor: color[0],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class HeroPage extends StatefulWidget {
  final color;
  HeroPage(this.color);
  @override
  _HeroPageState createState() => _HeroPageState(color);
}

class _HeroPageState extends State<HeroPage> with TickerProviderStateMixin {
  final color;
  _HeroPageState(this.color);

  AnimationController animationController;
  Animation borderRadius;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    borderRadius = Tween(begin: 0.0, end: 12.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size(MediaQuery.of(context).size.width, kToolbarHeight),
          child: Hero(
            tag: 0,
            child: AppBar(
              backgroundColor: color[0],
              title: Text('Hero Page'),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 6.0, right: 6.0),
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
				height: 100.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
						  offset: Offset(0.0, 4.0),
                            spreadRadius: 1.0,
                            blurRadius: 4.0)
                      ]),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator is used to create a new page
            // Pass context, and create builder for new page
            Navigator.of(context).pop();
          },
          backgroundColor: color[0],
        ));
  }
}
