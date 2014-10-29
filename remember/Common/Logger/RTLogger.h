//
//
//  Created by RentonTheUncoped on 14-10-15.
//

#import <Foundation/Foundation.h>

//让外面来提供文件名太傻了
//使用RTLogger功能的话，请添加一个事件，然后在下面那个数组里面加上对应的文件名
typedef enum : NSUInteger {
    LOG_NilValueOrKey = 0u,//{nil:xx, xx:nil};
    LOG_NilString,//[NSString stringWithString:nil];
    LOG_NilInitString,//[NSString alloc] initWithString:nil];
    LOG_NSMutableDictionaryNilKey, //[mutableDic setValue:xx forKey:nil];
    LOG_SameItem
} LOG_Type;

#define LOG_logFileNames @[@"Log_dic_literal_crash", @"Log_string_withNilString_crash",@"Log_init_With_stringNil_crash", @"Log_mutableDic_setValueForNilKey", @"Log_sameItem"];

@interface RTLogger : NSObject

+ (instancetype)sharedInstance;
+ (void)destroy;

- (NSString*)readLogWithLogType:(LOG_Type)type error:(NSError**)error;

//使用时只用使用这两个方法就可以了
//在需要的地方捕获异常，然后写日志
- (BOOL)writeLogWithLogType:(LOG_Type)type logInfo:(NSString*)log;
//在启动的时候上传日志
- (void)uploadLogForLogType:(LOG_Type)type;

- (BOOL)removeLogForLogType:(LOG_Type)type;
@end
