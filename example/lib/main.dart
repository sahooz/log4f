import 'package:flutter/material.dart';
import 'package:log4f/log4f.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  var useLogan = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
          child: Column(
            children: [
              OutlinedButton(
                  onPressed: () async {
                    useLogan = await FlutterLogan.init("0123456789012345", "0123456789012345", 1024 * 1024 * 10);
                  },
                  child: Text("Init logan")
              ),
              OutlinedButton(
                  onPressed: () async {
                    final today = DateTime.now();
                    final date = "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
                    final bool back = await FlutterLogan.upload(
                        'http://192.168.3.46:8080/logan/logan/upload.json',
                        date,
                        'FlutterTestAppId',
                        'FlutterTestUnionId',
                        'FlutterTestDeviceId'
                    );

                    Log4f.i(msg: back? 'Upload to server succeed' : 'Failed upload to server');
                  },
                  child: Text("Upload")
              ),
              OutlinedButton(
                  onPressed: () {
                    Log4f.log("v", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 0, useLogan);
                    Log4f.log("d", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 0, useLogan);
                    Log4f.log("i", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 0, useLogan);
                    Log4f.log("w", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 3, useLogan);
                    Log4f.log("e", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 3, useLogan);
                    Log4f.log("wtf", "tag", "msgmsgmsgmsgmsgmsgmsg", 0, 3, useLogan);
                  },
                  child: Text("Log")
              ),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LogConsole()));
                  },
                  child: Text("Console")
              ),
            ],
          )
      ),
    );
  }
}

