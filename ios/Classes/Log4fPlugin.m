#import "Log4fPlugin.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Logan.h"

@implementation Log4fPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"log4f"
            binaryMessenger:[registrar messenger]];
  Log4fPlugin* instance = [[Log4fPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  
  FlutterMethodChannel* loganChannel = [FlutterMethodChannel
        methodChannelWithName:@"flutter_logan"
              binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:loganChannel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    SEL sel = NSSelectorFromString([call.method stringByAppendingString:@":result:"]);
    if(sel && [self respondsToSelector:sel]){
        ((void(*)(id,SEL,NSDictionary *,FlutterResult))objc_msgSend)(self,sel,call.arguments,result);
    }else{
        result(FlutterMethodNotImplemented);
    }
}

- (void)doLog: (NSDictionary *)args result: (FlutterResult)result {
    NSString *level = args[@"level"];
    NSString *tag = args[@"tag"];
    NSString *msg = args[@"msg"];
    NSString *trace = args[@"trace"];
    
    NSString *heart = @"💜[2]";
    NSUInteger type = 2;
    if([@"d" isEqualToString: level]) {
        type = 3;
        heart = @"💚[23]";
    } else if([@"i" isEqualToString: level]) {
        type = 4;
        heart = @"💙[234]";
    } else if([@"w" isEqualToString: level]) {
        type = 5;
        heart = @"💛[2345]";
    } else if([@"e" isEqualToString: level]) {
        type = 6;
        heart = @"❤️[23456]";
    } else if([@"wtf" isEqualToString: level]) {
        type = 7;
        heart = @"💔[234567]";
    }
    
    if(trace != nil) {
        NSLog(@"%@ [%@] [%@]: %@ \n %@", heart, level, tag, msg, trace);
    } else {
        NSLog(@"%@ [%@] [%@]: %@", heart, level, tag, msg);
    }
    
    
    NSNumber* write = args[@"write"];
    if([[args allKeys] containsObject: @"logType"]) {
        NSNumber *logType = args[@"logType"];
        type = logType.integerValue;
    }
    
    if(write.boolValue) {
        logan(type, msg);
    }
    result(@(YES));
}

- (void)init:(NSDictionary *)args result:(FlutterResult)result{
    if(![args isKindOfClass:[NSDictionary class]]){
        result(@(NO));
        return;
    }
    NSString *key = args[@"aesKey"];
    NSString *iv = args[@"aesIv"];
    NSNumber *maxFileLen = args[@"maxFileLen"];
    if(key.length >0 && iv.length >0){
        loganInit([NSData dataWithBytes:key.UTF8String length:key.length],[NSData dataWithBytes:iv.UTF8String length:iv.length] , maxFileLen.integerValue);
        result(@(YES));
    }else{
        result(@(NO));
    }
}

- (void)log:(NSDictionary *)args result:(FlutterResult)result{
    if(![args isKindOfClass:[NSDictionary class]]){
        result(nil);
        return;
    }
    NSNumber *type = args[@"type"];
    NSString *log = args[@"log"];
    logan(type.integerValue, log);
    result(nil);
}

- (void)flush:(NSDictionary *)args result:(FlutterResult)result{
    loganFlush();
    result(nil);
}

- (void)getUploadPath:(NSDictionary *)args result:(FlutterResult)result{
    if(![args isKindOfClass:[NSDictionary class]]){
        result(@"");
        return;
    }
    NSString *date = args[@"date"];
    if(date.length >0){
        loganUploadFilePath(date, ^(NSString * _Nullable filePath) {
            result(filePath);
        });
    }else{
        result(@"");
    }
}

- (void)upload:(NSDictionary *)args result:(FlutterResult)result{
    if(![args isKindOfClass:[NSDictionary class]]){
        result(@NO);
        return;
    }
    NSString *urlStr = args[@"serverUrl"];
    NSString *date = args[@"date"];
    NSString *appid = args[@"appId"];
    NSString *unionId = args[@"unionId"];
    NSString *deviceId = args[@"deviceId"];
    loganUpload(urlStr,date,appid,unionId,deviceId,^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error){
        if(error){
            result(@NO);
        }else{
            result(@YES);
        }
    });
}

- (void)cleanAllLogs:(NSArray *)param result:(FlutterResult)result{
    loganClearAllLogs();
    result(nil);
}

@end
