import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<PaletteGenerator> _colorFuture;

  String image = "assets/graduation.jpg";

  @override
  void initState() {
    _colorFuture =
        PaletteGenerator.fromImageProvider(AssetImage(image));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AlbumCover(
              image: image,
            ),
            FutureBuilder(
              future: _colorFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    PaletteGenerator generator = snapshot.data;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Graduation",
                          style: Theme.of(context).textTheme.headline4.copyWith(
                              color: generator.darkVibrantColor.color),
                        ),
                        Text(
                          "Kanye West",
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: generator.vibrantColor.color),
                        ),
                        SizedBox(height: 40),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            for (var color in generator.colors)
                              Expanded(
                                child: Container(
                                  height: 60,
                                  color: color,
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.vibrantColor.color,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.darkVibrantColor.color,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.lightVibrantColor.color,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.mutedColor.color,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.darkMutedColor.color,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 60,
                                color: generator.lightMutedColor.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Text("Fehler");
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class AlbumCover extends StatefulWidget {
  final Size size;
  final String image;

  const AlbumCover(
      {Key key, this.size = const Size(300, 300), @required this.image})
      : super(key: key);

  @override
  _AlbumCoverState createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<AlbumCover> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _blurAnimation;

  bool isHovering = false;
  bool isPlaying = false;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1);
    _blurAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => isHovering = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => isHovering = false);
        _animationController.reverse();
      },
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.92 + _blurAnimation.value * 0.2,
                child: Transform.translate(
                  offset: Offset(0, widget.size.height * 0.04 + 13),
                  child: child,
                ),
              );
            },
            child: Container(
              width: widget.size.width,
              height: widget.size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + _blurAnimation.value * 0.05,
                child: Container(
                  width: widget.size.width,
                  height: widget.size.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.asset(
                          widget.image,
                          color: Colors.black
                              .withOpacity(_blurAnimation.value * 0.2),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 150),
                        opacity: isHovering ? 1 : 0,
                        child: Icon(
                          isPlaying
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: widget.size.width * 0.2,
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.pink.shade100.withOpacity(0.5),
                            onTap: () => setState(() => isPlaying = !isPlaying),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            child: null,
          ),
        ],
      ),
    );
  }
}
