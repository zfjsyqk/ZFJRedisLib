//
//  ZFJRedis.h
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFJRedis : NSObject

/// 根据Key获取值
/// @param key key
+ (id)zfj_valueForKey:(NSString *)key;

/// 根据key重新赋值
/// @param value value
/// @param key key
+ (void)zfj_setValue:(id)value forKey:(NSString *)key;

/// 根据keys数组重新赋值
/// @param keyedValues (key:value)数组
+ (void)zfj_setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;

/// 根据key删除数据
/// @param key key
+ (void)zfj_removeObjectForKey:(NSString *)key;

/// 根据keys数组删除数据
/// @param keys keys数组
+ (void)zfj_removeObjectsForKeys:(NSArray<NSString *> *)keys;

/// 删除全部的数据
+ (void)zfj_removeAllObjects;

/// 根据keys数组获取对应的字典
/// @param keys keys数组
+ (NSDictionary *)zfj_dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;

/// 获取所以的keys
+ (NSArray *)zfj_allKeys;

/// 获取所以的values
+ (NSArray *)zfj_allValues;

/// 获取数据条数
+ (NSInteger)zfj_count;

/// 检查某个key是否存在
+ (BOOL)zfj_isExistkey:(NSString *)key;

/// 最后一条错误信息
+ (NSError *)zfj_lastRedisError;

/// 废弃方法
- (nullable id)valueForKey:(NSString *)key NS_UNAVAILABLE;
- (void)setValue:(nullable id)value forKey:(NSString *)key NS_UNAVAILABLE;
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
