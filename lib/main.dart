import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _subtitleController;
  late Animation<double> sizeAnimation;
  late Animation<double> opacityAnimation;
  late Animation<Offset> _textPositionAnimation;
  bool showText = false;
  bool showSecondImage = false;
  final List<String> _textWords = [
    'Transferência',
    'por',
    'voz',
    'solicitada',
  ];
  late List<bool> _wordVisibility;
  bool firstAnimation = false;

  late Animation<double> subtitleOpacityAnimation;
  late Animation<Offset> subtitlePositionAnimation;
  bool showSubtitle = false;
  bool showButton = false;
  @override
  void initState() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _textController = _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    sizeAnimation = Tween<double>(begin: 5, end: 0.3).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );
    _wordVisibility = List.generate(_textWords.length, (index) => false);
    _textPositionAnimation = Tween<Offset>(
      begin: const Offset(5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    subtitlePositionAnimation = Tween<Offset>(
      begin: const Offset(5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.linear,
      ),
    );

    subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.linear,
      ),
    );
    _logoController.forward();

    _logoController.addListener(() {
      if (_logoController.value > .5) {
        setState(() {
          showText = true;
        });
        _textController.forward().whenComplete(() async {
          if (!firstAnimation) {
            await _animateWords(true);
          } else {
            await _animateWords(false);
          }
        });
      }
    });
    Future.microtask(() async {
      await Future.delayed(const Duration(seconds: 2));
      checkVisibulity();
    });
    super.initState();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future _animateWords(bool hide) async {
    for (int i = 0; i < _textWords.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _wordVisibility[i] = hide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff5D2479),
      body: Center(
        child: Stack(
          children: [
            const SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 0,
              left: 0,
              child: AnimatedContainer(
                height: showSecondImage ? 300 : 0,
                width: showSecondImage ? 300 : 0,
                duration: const Duration(milliseconds: 500),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/person.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: sizeAnimation.value == 0.3
                                  ? 1
                                  : sizeAnimation.value,
                              child: Image.asset(
                                'assets/plus.png',
                                height: 150,
                                width: sizeAnimation.value == 0.3
                                    ? null
                                    : firstAnimation
                                        ? null
                                        : MediaQuery.of(context).size.width,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        if (showText && !showSubtitle)
                          Positioned(
                            bottom: -10,
                            right: 0,
                            child: SlideTransition(
                              position: _textPositionAnimation,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _textPositionAnimation.value.dx == 0
                                    ? 1
                                    : .5,
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showText) ...[
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: opacityAnimation,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8.0,
                          children: _textWords.asMap().entries.map((entry) {
                            int index = entry.key;
                            String word = entry.value;
                            return AnimatedSlide(
                              offset: _wordVisibility[index]
                                  ? Offset.zero
                                  : const Offset(0.5, 1),
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeOut,
                              child: AnimatedOpacity(
                                opacity: _wordVisibility[index] ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  word,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ), //showSubtitle
                      if (showSubtitle) ...[
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: subtitlePositionAnimation,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: subtitlePositionAnimation.value.dx == 0
                                ? 1
                                : .5,
                            child: const Text(
                              'Informe ao cliente que a assinatura digital e a Assinatura foram realizados com sucesso e o termo e contrato serão enviados por e-mail.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width:
                            showButton ? MediaQuery.of(context).size.width : 0,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Center(
                          child: Text(
                            "Continuar",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff5D2479),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkVisibulity() async {
    if (_wordVisibility.where((element) => element).toList().length ==
        _textWords.length) {
      setState(() {
        firstAnimation = true;
      });
      sizeAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: _logoController,
          curve: Curves.easeIn,
        ),
      );
      _logoController.reset();
      _logoController.forward();
      _textPositionAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(10, 0),
      ).animate(
        CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
        ),
      );

      _textController.reset();
      _textController.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        showSecondImage = true;
      });
      await Future.delayed(const Duration(seconds: 1));

      await _animateWords(true);
      setState(() {
        showSubtitle = true;
      });
      _subtitleController.reset();
      _subtitleController.forward().whenComplete(() => setState(() {}));

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        showButton = true;
      });
    }
  }
}
