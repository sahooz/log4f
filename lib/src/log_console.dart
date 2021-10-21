import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:log4f/log4f.dart';

class LogConsole extends StatefulWidget {
  const LogConsole({Key? key}) : super(key: key);

  @override
  _LogConsoleState createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole> implements LogListener {

  bool _reverse = false;

  List<Log> _logs = Log4f.logContainer.logs;
  List<Log> _all = Log4f.logContainer.logs;
  String level = 'v';
  bool autoScroll = false;

  TextEditingController textController = TextEditingController();
  ScrollController listController = ScrollController();

  @override
  void initState() {
    super.initState();
    Log4f.addLogListener(this);
    textController.addListener(() {
      filter();
    });
  }

  void filter() {
    _logs = List.from(_all.where(filterLog));
    if(mounted) {
      setState(() { });
    }
  }

  bool filterLog(Log value) {
    var text = textController.value.text.toLowerCase();
    var containsText = value.tag.toLowerCase().contains(text)
        || value.msg.toLowerCase().contains(text)
        || value.trace.toLowerCase().contains(text);
    var levelMatch = value.levelHigherThan(level);
    return containsText && levelMatch;
  }

  @override
  void dispose() {
    super.dispose();
    Log4f.removeLogListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Text("Log Console", style: TextStyle(color: Colors.white),),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_horiz),
            itemBuilder: (context) => [
              PopupMenuItem(child: Text("Toggle Auto Scroll"), onTap: () {
                setState(() {
                  autoScroll = ! autoScroll;
                  if(autoScroll) {
                    listController.jumpTo(listController.position.maxScrollExtent);
                  }
                });
              }),
              PopupMenuItem(child: Text("Toogle Reverse"), onTap: () {
                setState(() {
                  _reverse = !_reverse;
                });
              }),
              PopupMenuItem(child: Text("Copy Logs"), onTap: (){
                setState(() {
                  copy();
                });
              }),
              PopupMenuItem(child: Text("Clear Logs"), onTap: () {
                setState(() {
                  _all.clear();
                  _logs.clear();
                  Log4f.logContainer.clear();
                });
              }),
            ],
          )

        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: listController,
              itemBuilder: (context, index) {
                var log = _logs[index];
                var text = "${log.displayTime}  ${log.level.toUpperCase()}  ${log.tag}: ${log.msg}";
                if(log.trace.isNotEmpty) {
                  text += log.trace;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(text, style: TextStyle(color: Log4f.colorMap[log.level]),),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: _logs.length,
              reverse: _reverse,
            )
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: false,
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Filter...",
                      contentPadding: EdgeInsets.only(left: 12, right: 12),
                      border: OutlineInputBorder()
                    ),
                  )
                ),
                SizedBox(width: 8,),
                Text("LEVEL:"),
                SizedBox(width: 8,),
                DropdownButton<String>(
                  value: level,
                  onChanged: (value) {
                    level = value as String;
                    filter();
                  },
                  items: [
                    getDropDownItem('v'),
                    getDropDownItem('d'),
                    getDropDownItem('i'),
                    getDropDownItem('w'),
                    getDropDownItem('e'),
                    getDropDownItem('wtf'),
                  ]
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  DropdownMenuItem<String> getDropDownItem(String level) {
    return DropdownMenuItem(
      value: level,
      child: Text(level.toUpperCase()),
    );
  }

  void copy() {
    StringBuffer sb = new StringBuffer();
    _logs.forEach((log) {
      sb.writeln("${log.displayTime}  ${log.level.toUpperCase()}  ${log.tag}: ${log.msg}");
      sb.write(log.trace);
    });
    Clipboard.setData(ClipboardData(text: sb.toString()));
  }

  @override
  void onLog(Log log) {
    if(mounted) {
      setState(() {
        _all.add(log);
        if(filterLog(log)) {
          _logs.add(log);
        }
        if(autoScroll) {
          listController.jumpTo(listController.position.maxScrollExtent);
        }
      });
    }
  }
}
