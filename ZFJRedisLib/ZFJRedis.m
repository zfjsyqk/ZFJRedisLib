//
//  ZFJRedis.m
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//

#import "ZFJRedis.h"
#import "ZFJTable.h"
#import "ZFJRedisModel.h"
#import "FMDatabase.h"
#import "NSObject+ZFJModel.h"
#import "ZFJSimpleObject.h"
#import <objc/message.h>

@interface ZFJRedis ()

@property (nonatomic,  copy) NSString *tableName;

@end

@implementation ZFJRedis

+ (void)initialize{
    [ZFJTable zfj_createTable:ZFJRedisModel.class];
}


//value=123$$type=String
+ (id)zfj_valueForKey:(NSString *)key{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where key = '%@'", self.tableName, key];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSMutableArray *models = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [models addObject:dict];
    }
    
    [set close];
    
    if(models.count == 0){
        return nil;
    }
    
    NSArray *valueArr = [[models.firstObject objectForKey:@"value"] componentsSeparatedByString:@"$$"];
    NSError *error;
    
    if([valueArr.lastObject isEqualToString:@"NSString"]){
        NSString *str = valueArr.firstObject;
        return str;
    }else if ([valueArr.lastObject isEqualToString:@"NSArray"]){
        NSData *data = [valueArr.firstObject dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return array;
    }else if ([valueArr.lastObject isEqualToString:@"NSDictionary"]){
        NSData *data = [valueArr.firstObject dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return dictionary;
    }else if ([valueArr.lastObject isEqualToString:@"NSNumber"]){
        NSNumber *object = [NSNumber numberWithInteger:[valueArr.firstObject integerValue]];
        return object;
    }else if ([valueArr.lastObject isEqualToString:@"NSObject"]){
        NSData *data = [valueArr.firstObject dataUsingEncoding:NSUTF8StringEncoding];
        NSObject *object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        return object;
    }else if ([valueArr.lastObject isEqualToString:@"NSData"]){
        NSData *data = [valueArr.firstObject dataUsingEncoding:NSUTF8StringEncoding];
        return data;
    }else{
        @try {
            NSData *data = [valueArr.firstObject dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            Class class = NSClassFromString(valueArr.lastObject);
            id object = ((id(*)(id, SEL))objc_msgSend)(class, NSSelectorFromString(@"new"));
            [object setValuesForKeysWithDictionary:dict];
            return object;
        } @catch (NSException *exception) {
            return nil;
        }
    }
}

+ (void)zfj_setValue:(id)value forKey:(NSString *)key{
    if(value == nil){
        [self zfj_removeObjectForKey:key];
    }else{
        NSData *data = nil;
        NSString *type = nil;
        if([value isKindOfClass:[NSString class]]){
            type = @"NSString";
            data = [value dataUsingEncoding:NSUTF8StringEncoding];
        }else if([value isKindOfClass:[NSArray class]]){
            type = @"NSArray";
            data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
        }else if([value isKindOfClass:[NSDictionary class]]){
            type = @"NSDictionary";
            data = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:nil];
        }else if([value isKindOfClass:[NSNumber class]]){
            type = @"NSNumber";
            value = [NSString stringWithFormat:@"%@",value];
            data = [value dataUsingEncoding:NSUTF8StringEncoding];
        }else if([value isKindOfClass:[NSData class]]){
            type = @"NSData";
            data = value;
        }else{
            type = NSStringFromClass([value class]);
            data = [NSJSONSerialization dataWithJSONObject:[value zfj_modelToDict] options:NSJSONWritingPrettyPrinted error:nil];
        }
        NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSString *valueStr = [NSString stringWithFormat:@"%@$$%@",dataStr, type];
        
        BOOL isScu = NO;
        NSString *sqlStr = nil;
        if([self zfj_valueForKey:key] == nil){
            //插入
            sqlStr = [NSString stringWithFormat:@"insert into %@ (key, value) values('%@', '%@')",self.tableName, key, valueStr];
            isScu = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
        }else{
            //修改
            sqlStr = [NSString stringWithFormat:@"update %@ set value = '%@' where key = '%@'",self.tableName, valueStr, key];
            isScu = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
        }
        if(!isScu){
            [self zfj_printError];
        }
    }
}

+ (void)zfj_setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues{
    [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self zfj_setValue:obj forKey:key];
    }];
}

+ (void)zfj_removeObjectForKey:(NSString *)key{
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where key = '%@'",self.tableName, key];
    BOOL isScu = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    if(!isScu){
        [self zfj_printError];
    }
}

+ (void)zfj_removeObjectsForKeys:(NSArray<NSString *> *)keys{
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self zfj_removeObjectForKey:obj];
    }];
}

+ (void)zfj_removeAllObjects{
    NSMutableString *sqlStr = [[NSMutableString alloc]initWithFormat:@"delete from %@",self.tableName];
    BOOL isScu = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    if(!isScu){
        [self zfj_printError];
    }
}

+ (NSDictionary *)zfj_dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (NSString *key in keys) {
        id value = [self zfj_valueForKey:key];
        [dict setObject:value forKey:key];
    }
    return dict;
}

+ (NSArray *)zfj_allKeys{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",self.tableName];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [mutableDict setValue:dict[@"value"] forKey:dict[@"key"]];
    }
    [set close];
    
    return mutableDict.allKeys;
}

+ (NSArray *)zfj_allValues{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",self.tableName];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        [mutableDict setValue:dict[@"value"] forKey:dict[@"key"]];
    }
    [set close];
    return mutableDict.allValues;
}

+ (NSInteger)zfj_count{
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) count from %@",self.tableName];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSInteger count = -1;
    while ([set next]) {
        count = [set intForColumn:@"count"];
    }
    return count;
}

+ (NSString *)tableName{
    return [ZFJRedisModel zfj_tableName];
}

+ (BOOL)zfj_isExistkey:(NSString *)key{
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) count from %@ where key = '%@'",self.tableName, key];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSInteger count = -1;
    while ([set next]) {
        count = [set intForColumn:@"count"];
    }
    return count > 0 ? YES : NO;
}

+ (NSError *)zfj_lastRedisError{
    return [ZFJSimpleObject manager].dataBase.lastError;
}

+ (void)zfj_printError{
    if([ZFJSimpleObject manager].printRedisError){
        NSLog(@"ZFJRedis Error == %@",[ZFJSimpleObject manager].dataBase.lastError);
    }
}

@end
