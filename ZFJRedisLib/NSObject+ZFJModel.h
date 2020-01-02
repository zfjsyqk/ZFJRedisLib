//
//  NSObject+ZFJModel.h
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSObject (ZFJModel)

/// 获取当前对象所以的属性名称
- (NSArray *)zfj_propertyNames;

/// Model转字典
- (NSDictionary *)zfj_modelToDict;

/// 通过Key获取Value值
/// @param key Key
- (NSString *)zfj_valueForKey:(NSString *)key;

/// 根据Model获取表名
- (NSString *)zfj_tableName;

@end
