//
//  ZFJTable.m
//  ZFJRedisLibDemo
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 Administrator. All rights reserved.
//

#import "ZFJTable.h"
#import "ZFJSimpleObject.h"
#import "NSObject+ZFJModel.h"
#import "FMDatabase.h"
#import <objc/message.h>

@interface ZFJTable ()

@end

@implementation ZFJTable

+ (BOOL)zfj_createTable:(Class)modelClass{
    NSString *tableName = [modelClass zfj_tableName];
    NSArray *propertyNames = [modelClass zfj_propertyNames];
    NSString *propertyNamesStr = [propertyNames componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@(%@)",tableName, propertyNamesStr];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    return ret;
}

+ (BOOL)zfj_removeTable:(Class)modelClass{
    NSString *tableName = [modelClass zfj_tableName];
    NSMutableString *sqlStr = [[NSMutableString alloc]initWithFormat:@"drop table %@",tableName];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    return ret;
}

+ (BOOL)zfj_removeAllTables{
    [[ZFJSimpleObject manager].dataBase close];
    [ZFJSimpleObject manager].dataBase = nil;
    BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:[ZFJSimpleObject manager].dataBasePath error:nil];
    return ret;
}

+ (BOOL)zfj_clearTable:(Class)modelClass{
    NSString *tableName = [modelClass zfj_tableName];
    NSMutableString *sqlStr = [[NSMutableString alloc]initWithFormat:@"delete from %@",tableName];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    return ret;
}

+ (void)zfj_insertModel:(NSObject *)model completed:(void(^)(NSError *error))completed{
    NSDictionary *modelDict = [model zfj_modelToDict];
    NSString *tableName = [model zfj_tableName];
    NSArray *fieldNameArr = modelDict.allKeys;
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<fieldNameArr.count; i++) {
        NSString *value = [modelDict objectForKey:fieldNameArr[i]];
        [valueArr addObject:[NSString stringWithFormat:@"'%@'",value]];
    }
    NSString *fieldNameAll = [fieldNameArr componentsJoinedByString:@","];
    NSString *valueAll = [valueArr componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(%@) values(%@)",tableName,fieldNameAll,valueAll];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret ? nil : [ZFJSimpleObject manager].dataBase.lastError);
    }
}

+ (void)zfj_insertModels:(NSArray *)models completed:(void(^)(NSError *error))completed{
    dispatch_semaphore_wait([ZFJSimpleObject manager].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        [models enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL * _Nonnull stop) {
            [self zfj_insertModel:model completed:^(NSError *error) {
                if (error) {*stop = YES;}
                if(completed && error){
                    completed([ZFJSimpleObject manager].dataBase.lastError);
                }
            }];
        }];
    }
    dispatch_semaphore_signal([ZFJSimpleObject manager].dsema);
}

+ (BOOL)zfj_deleteModel:(Class)modelClass where:(NSString *)sqlStr{
    NSString *tableName = [modelClass zfj_tableName];
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@",tableName, sqlStr];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:deleteSql];
    return ret;
}

+ (void)zfj_updateModel:(NSObject *)model byKey:(NSString *)key completed:(void(^)(NSError *error))completed{
    NSString *tableName = [model zfj_tableName];
    NSDictionary *modelDict = [model zfj_modelToDict];
    NSArray *fieldNameArr = modelDict.allKeys;
    NSMutableArray *valueArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<fieldNameArr.count; i++) {
        NSString *value = [modelDict objectForKey:fieldNameArr[i]];
        value = [NSString stringWithFormat:@"%@ = '%@'",fieldNameArr[i],value];
        [valueArr addObject:value];
    }
    NSString *valueAll = [valueArr componentsJoinedByString:@","];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set %@ where %@ = '%@'",tableName, valueAll, key, [modelDict objectForKey:key]];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:sqlStr];
    if(completed){
        completed(ret ? nil : [ZFJSimpleObject manager].dataBase.lastError);
    }
}

+ (void)zfj_updateModels:(NSArray *)models byKey:(NSString *)key completed:(void(^)(NSError *error))completed{
    dispatch_semaphore_wait([ZFJSimpleObject manager].dsema, DISPATCH_TIME_FOREVER);
    @autoreleasepool {
        [models enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL * _Nonnull stop) {
            [self zfj_updateModel:model byKey:key completed:^(NSError *error) {
                if (error) {*stop = YES;}
                if(completed && error){
                    completed([ZFJSimpleObject manager].dataBase.lastError);
                }
            }];
        }];
    }
    dispatch_semaphore_signal([ZFJSimpleObject manager].dsema);
}

+ (void)zfj_selectTable:(Class)modelClass completed:(void(^)(NSError *error, NSArray *models))completed{
    NSString *tableName = [modelClass zfj_tableName];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",tableName];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        id object = ((id(*)(id, SEL))objc_msgSend)(modelClass, NSSelectorFromString(@"new"));
        [object setValuesForKeysWithDictionary:dict];
        [mutableArr addObject:object];
    }
    [set close];
    if(completed){
        completed([ZFJSimpleObject manager].dataBase.lastError, mutableArr);
    }
}

+ (void)zfj_selectTable:(Class)modelClass where:(NSString *)sqlStr completed:(void(^)(NSError *error, NSArray *models))completed{
    NSString *tableName = [modelClass zfj_tableName];
    sqlStr = [NSString stringWithFormat:@"select * from %@ where %@",tableName, sqlStr];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
    while ([set next]){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        for (int i = 0; i<set.columnCount; i++) {
            [dict setValue:[set stringForColumnIndex:i] forKey:[set columnNameForIndex:i]];
        }
        id object = ((id(*)(id, SEL))objc_msgSend)(modelClass, NSSelectorFromString(@"new"));
        [object setValuesForKeysWithDictionary:dict];
        [mutableArr addObject:object];
    }
    [set close];
    if(completed){
        completed([ZFJSimpleObject manager].dataBase.lastError, mutableArr);
    }
}

+ (NSInteger)zfj_selectTableCount:(Class)modelClass{
    NSString *tableName = [modelClass zfj_tableName];
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) count from %@",tableName];
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSInteger totalCount = -1;
    while ([set next]) {
        totalCount = [set intForColumn:@"count"];
    }
    return totalCount;
}

/// 根据条件查询某个表部分数据条数
/// @param modelClass model class
/// @param parameters 参数键值对
+ (NSInteger)zfj_selectTableCount:(Class)modelClass where:(NSString *)sqlStr{
    NSString *tableName = [modelClass zfj_tableName];
    if(sqlStr.length > 0){
        sqlStr = [NSString stringWithFormat:@"select count(*) count from %@ where %@",tableName, sqlStr];
    }else{
        sqlStr = [NSString stringWithFormat:@"select count(*) count from %@",tableName];
    }
    FMResultSet *set = [[ZFJSimpleObject manager].dataBase executeQuery:sqlStr];
    NSInteger totalCount = -1;
    while ([set next]) {
        totalCount = [set intForColumn:@"count"];
    }
    return totalCount;
}

+ (BOOL)zfj_addProperty:(Class)modelClass propertyName:(NSString *)propertyName{
    NSString *tableName = [modelClass zfj_tableName];
    NSString *alertStr = [NSString stringWithFormat:@"alter table %@ add %@",tableName, propertyName];
    BOOL ret = [[ZFJSimpleObject manager].dataBase executeUpdate:alertStr];
    return ret;
}

+ (NSError *)zfj_lastTableError{
    return [ZFJSimpleObject manager].dataBase.lastError;
}

@end
