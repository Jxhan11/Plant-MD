import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kissansphere/homescreen.dart';
import 'package:lottie/lottie.dart';

class ColorConstants {
  static Color backgroundColor = Color(0xff1A1A1A);
  // static Color primaryColor = Color(0xff8DBA91);
  static Color primaryColor = Color(0xffC8EECC);
  static Color primaryTextColor = Color(0xffEAEAEA);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'KissanSuraksha',
        theme: ThemeData(
          // This is the theme of your application.
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          fontFamily: 'Product Sans',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff8DBA91)),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kissan',
                        style: TextStyle(
                            // fontFamily: 'Oswald',
                            fontWeight: FontWeight.w800,
                            fontSize: 45,
                            letterSpacing: 1,
                            color: ColorConstants.primaryColor),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 80),
                        child: Text(
                          'Suraksha',
                          style: TextStyle(
                              // fontFamily: 'Oswald',
                              fontWeight: FontWeight.w500,
                              fontSize: 45,
                              letterSpacing: 1,
                              color: ColorConstants.primaryTextColor),
                        ),
                      ),
                    ],
                  )),
              HomeScreenLottie(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      (MaterialPageRoute(
                          builder: (context) => HomescreenPage())));
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    // width: 200,
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(201),
                        color: ColorConstants.primaryColor),
                    child: Text(
                      'Next   ->',
                      style: TextStyle(
                          color: ColorConstants.backgroundColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HomeScreenLottie extends StatefulWidget {
  const HomeScreenLottie({
    super.key,
  });

  @override
  State<HomeScreenLottie> createState() => _HomeScreenLottieState();
}

class _HomeScreenLottieState extends State<HomeScreenLottie>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.reset();
        controller.forward();
        Future.delayed(Duration(milliseconds: 1000), () {
          controller.stop();
        });
      },
      child: SizedBox(
        // color: Colors.amber,
        height: 410,
        // width: 300,
        // width: double.infinity,
        child: LottieBuilder.asset(
          'assets/lotties/globe.json',
          controller: controller,
          fit: BoxFit.fill,
          onLoaded: (composition) {
            try {
              debugPrint('LOTTIE ${composition.frameRate}');
              controller.duration = composition.duration;
              controller.forward();
              Future.delayed(Duration(milliseconds: 1100), () {
                controller.stop();
              });
              debugPrint(
                  'LOTTIE ${controller.status}'); // Might not be updated immediately
            } catch (e) {
              print('Error loading Lottie animation: $e');
            }
          },

          // repeat: false,
          // controller: ,
        ),
      ),
    );
  }
}
