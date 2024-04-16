import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_tts/flutter_tts.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Companion',
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => SplashScreen(),
        '/home': (context) => MyHomePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController receivedInputController = TextEditingController();

  DatabaseReference _testRef1 = FirebaseDatabase.instance.ref().child('blinkDuration1');
  DatabaseReference _testRef2 = FirebaseDatabase.instance.ref().child('blinkDuration2');
  DatabaseReference _testRef3 = FirebaseDatabase.instance.ref().child('blinkDuration3');


  @override
  void initState() {
    super.initState();
    // Subscribe to Bluetooth data stream here
    receivedInputController.addListener(() {
    _speak(receivedInputController.text);
  });

  // Listening to Firebase Realtime Database changes
    _testRef1.onValue.listen((event) {
      if (event.snapshot.value != null) {
        // Extract data from the snapshot
       int blinkDuration1Value = event.snapshot.value as int;

        // Update the state variables with the retrieved values
        setState(() {
          blinkDuration1 = blinkDuration1Value;
          

          // Print the blink durations to the console
          print('Blink Duration 1: $blinkDuration1');
        });
      }
    });

    _testRef2.onValue.listen((event) {
      if (event.snapshot.value != null) {
        // Extract data from the snapshot
       int blinkDuration2Value = event.snapshot.value as int;

        // Update the state variables with the retrieved values
        setState(() {
          blinkDuration2 = blinkDuration2Value;
          

          // Print the blink durations to the console
          print('Blink Duration 2: $blinkDuration2');
        });
      }
    });

    _testRef3.onValue.listen((event) {
      if (event.snapshot.value != null) {
        // Extract data from the snapshot
       int blinkDuration3Value = event.snapshot.value as int;

        // Update the state variables with the retrieved values
        setState(() {
          blinkDuration3 = blinkDuration3Value;
          

          // Print the blink durations to the console
          print('Blink Duration 3: $blinkDuration3');
        });
      }
    });
  }

  


  Future<void> _speak(String text) async {
  await flutterTts.setLanguage('en-US');
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}



  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String realTimeValue = '0';
  String getOnceValue = '0';

  int blinkDuration1 = 0;
  int blinkDuration2 = 0;
  int blinkDuration3 = 0;

  FlutterTts flutterTts = FlutterTts();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Morse Companion'),
        backgroundColor: Colors.blue, // Set the app bar color to blue
      ),
      body: FutureBuilder(
        future: _fApp,
        builder: (context,snapshot) {
          if(snapshot.hasError){
            return Text("Something wrong with firebase");
          }else if(snapshot.hasData) {
            return buildUI();
          } else {
            return CircularProgressIndicator();
          }
        }
        )
    );
  }

  Widget buildUI() {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref().child('data');
    //listening to firebase realtime database value
    _testRef.onValue.listen(
      (event) {
        setState(() {
          realTimeValue = event.snapshot.value.toString();
        });
      },
    );
    
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Received Inputs TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Received Inputs:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller:
                    receivedInputController..text = realTimeValue, // Use the TextEditingController here
                readOnly: true, // Make the TextField read-only
                decoration: InputDecoration(
                  hintText: 'Received input here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          // Frequently Used Phrases ListView
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Frequently Used Phrases:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('I am hungry'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('I feel pain : ...'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('I feel hot: ---'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}



