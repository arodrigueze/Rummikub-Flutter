import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:audioplayers/audio_cache.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CounterRummikub(),
    theme: ThemeData(
        canvasColor: Colors.pink[900],
        iconTheme: IconThemeData(color: Colors.yellow[200]),
        accentColor: Colors.blue[900],
        brightness: Brightness.dark),
  ));
}

class CounterRummikub extends StatefulWidget {
  @override
  CounterRummikubState createState() => CounterRummikubState();
}

class CounterRummikubState extends State<CounterRummikub>
    with TickerProviderStateMixin {
  AudioCache audioCache = AudioCache();
  AnimationController controller;
  String dropdownValue = '15';
  String get timerString {
    Duration duration = (controller.duration * controller.value);
    return '${(duration.inSeconds + 1).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: Duration(seconds: int.parse(dropdownValue)));

    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        controller.reverse(from: 1.0);
        audioCache.play('sounds/bip.mp3');
      }
    });
    if (audioCache.fixedPlayer != null) {
      audioCache.fixedPlayer.startHeadlessService();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.teal[400],
              ),
              height: 100,
              margin: EdgeInsets.only(top: 30),
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('Timer'),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_downward),
                    iconSize: 44,
                    elevation: 16,
                    style: TextStyle(color: Colors.yellow[200]),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownValue = newValue;
                        controller.duration =
                            Duration(seconds: int.parse(newValue));
                        controller.value = 1.0;
                      });
                    },
                    items: <String>['15', '30', '60', '90']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.center,
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(children: <Widget>[
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (BuildContext context, Widget child) {
                          return new CustomPaint(
                              painter: TimerPainter(
                            animation: controller,
                            backgroundColor: Colors.yellow[200],
                            color: themeData.indicatorColor,
                          ));
                        },
                      ),
                    ),
                    Align(
                      alignment: FractionalOffset.center,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Count Down',
                              style: themeData.textTheme.subtitle1,
                            ),
                            AnimatedBuilder(
                              animation: controller,
                              builder: (BuildContext context, Widget child) {
                                return new Text(
                                  controller.isAnimating
                                      ? timerString
                                      : dropdownValue,
                                  style: themeData.textTheme.headline1,
                                );
                              },
                            )
                          ]),
                    )
                  ]),
                ),
              ),
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.yellow[200],
                ),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text('NEXT',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontSize: 50
                  ))
                ),
              ),
              onTap: () {
                controller.duration = Duration(seconds: int.parse(dropdownValue));
                controller.reverse(from: 1.0);
              },
            ),
            Container(
              height: 50,
            ),
            Container(
              margin: EdgeInsets.all(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        controller.stop();
                        controller.value = 1.0;
                      });
                    },
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget child) {
                        return new Icon(Icons.stop);
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({this.animation, this.backgroundColor, this.color})
      : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
