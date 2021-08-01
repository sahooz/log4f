package com.sahooz.log4f;

import android.util.Log;

import androidx.annotation.NonNull;

import com.dianping.logan.Logan;
import com.sahooz.log4f.logan.Logan4flutterPlugin;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** Log4fPlugin */
public class Log4fPlugin implements FlutterPlugin, MethodCallHandler {

  public static final int MAX_SINGLE_LENGTH  = 2000;
  
  private MethodChannel channel;
  private Logan4flutterPlugin logan = new Logan4flutterPlugin();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "log4f");
    channel.setMethodCallHandler(this);
    logan.onAttachedToEngine(flutterPluginBinding);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    logan.onDetachedFromEngine(binding);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("doLog")) {
      result.success(log((Map<String, Object>)call.arguments));
    } else {
      result.notImplemented();
    }
  }

  private boolean log(Map<String, Object> arguments) {
    String level = null;
    String tag = null;
    String msg = null;
    String trace = null;
    
    if(arguments.containsKey("level")) {
      level = (String) arguments.get("level");
    }

    if(arguments.containsKey("tag")) {
      tag = (String) arguments.get("tag");
    }

    if(arguments.containsKey("msg")) {
      msg = (String) arguments.get("msg");
    }

    if(arguments.containsKey("trace")) {
      trace = (String) arguments.get("trace");
    }
    
    if(level == null || tag == null || msg == null) {
      return false;
    }
    
    int intLevel;
    switch (level) {
      case "d":
        intLevel = Log.DEBUG;
        break;
      case "i":
        intLevel = Log.INFO;
        break;
      case "w":
        intLevel = Log.WARN;
        break;
      case "e":
        intLevel = Log.ERROR;
        break;
      case "wtf":
        intLevel = Log.ASSERT;
        break;
      case "v":
      default:
        intLevel = Log.VERBOSE;
        break;
    }
    
    String log = msg;
    if(trace != null) {
      log = msg + "\n" + trace;
    }
    print(intLevel, tag, log);

    Object obj = arguments.get("write");
    boolean write = obj instanceof Boolean? (Boolean)obj : false;
    if(write) {
      int logType = intLevel;
      if(arguments.containsKey("logType")) {
        logType = (Integer) arguments.get("logType");
      }
      Logan.w(log, logType);
    }

    return true;
  }

  public void print(int level, @NonNull String tag, @NonNull String log) {
    // 小于最大长度直接打印
    if(log.length() < MAX_SINGLE_LENGTH) {
      Log.println(level, tag, log);
      return;
    }

    int len = log.length();
    int printTime = len / MAX_SINGLE_LENGTH;

    int index = 0;
    for (int i = 0; i < printTime; i++) {
      Log.println(len, tag, log.substring(index, index + MAX_SINGLE_LENGTH));
      index += MAX_SINGLE_LENGTH;
    }

    // 继续打印剩余部分
    if(index != len) {
      Log.println(len, tag, log.substring(index, len));
    }
  }
}
