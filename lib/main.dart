import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite_flutter/tflite_flutter.dart';


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
  TextEditingController screenValueController = TextEditingController();
  bool _isLoading = true;
  DatabaseReference _testRef1 = FirebaseDatabase.instance.ref().child('blinkDuration1');
  DatabaseReference _testRef2 = FirebaseDatabase.instance.ref().child('blinkDuration2');
  DatabaseReference _testRef3 = FirebaseDatabase.instance.ref().child('blinkDuration3');
  var result = "";
  late Interpreter interpreter;

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
          loadModel();
          
        });
      }
    });
    
  }
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/converted_model.tflite');
    setState(() {
      _isLoading = false;
    });
    //print(blinkDuration1);
    //print(blinkDuration2);
    //print(blinkDuration3);
    runModel(blinkDuration1,blinkDuration2,blinkDuration3);
  }
  Future<void> runModel(int input1, int input2, int input3) async {
  if (_isLoading) return;
  //print("Entered model ftn");

  // Assign specific values for testing

  // // Print inputs for verification
  //print(input1);
  //print(input2);
  //print(input3);

  // Perform inference
  var output = List.filled(1 * 8, 0.0).reshape([1, 8]); // Ensure output shape matches model output
  interpreter.run([input1.toDouble(), input2.toDouble(), input3.toDouble()], output);

  // Find the index of the class with the highest probability
  var maxIndex = output[0].indexOf(output[0].reduce((double curr, double next) => curr > next ? curr : next));

  // Increment maxIndex by 1 to get the predicted integer value
  var predictedValue = maxIndex + 1;
  var predictedPhrase = "";
    switch(predictedValue){
      case 1:predictedPhrase = "I feel pain";
      break;
      case 2:predictedPhrase = "I need medicine";
      break;
      case 3:predictedPhrase = "I am hungry";
      break;
      case 4:predictedPhrase = "I am thirsty";
      break;
      case 5:predictedPhrase = "I need help";
      break;
      case 6:predictedPhrase = "I need to use the washroom";
      break;
      case 7:predictedPhrase = "I feel cold";
      break;
      case 8:predictedPhrase = "I feel hot";
      break;
      default:predictedPhrase = "Unable to predict";
      break;
    }
    print("Predicted Phrase: $predictedPhrase");
    setState(() {
      //print(predictedPhrase);
      result = predictedPhrase;
    });
 
}

  Future<void> _speak(String text) async {
  await flutterTts.setLanguage('en-US');
  await flutterTts.setPitch(1);
  await flutterTts.speak(text);
}



  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String realTimeValue = '0';
  String screenValue = '0';

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
     DatabaseReference _testRef4 = FirebaseDatabase.instance.ref().child('screen');
    //listening to firebase realtime database value
    _testRef.onValue.listen(
      (event) {
        setState(() {
          //loadModel();
          realTimeValue = event.snapshot.value.toString();
        });
      },
    );

    _testRef4.onValue.listen(
      (event) {
        setState(() {
          screenValue = event.snapshot.value.toString();
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
                    receivedInputController..text = result, // Use the TextEditingController here
                readOnly: true, // Make the TextField read-only
                decoration: InputDecoration(
                  hintText: 'Received input here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Monitor:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller:
                    screenValueController..text = screenValue, // Use the TextEditingController here
                readOnly: true, // Make the TextField read-only
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Received input here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }


}



