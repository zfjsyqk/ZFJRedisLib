//
//  ZFJTable.h
//  ZFJRedisLibDemo
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFJTable : NSObject

/// 创建表
/// @param modelClass model class
+ (BOOL)zfj_createTable:(Class)modelClass;

/// 删除表
/// @param modelClass model class
+ (BOOL)zfj_removeTable:(Class)modelClass;

/// 删除数据库
+ (BOOL)zfj_removeAllTables;

/// 清空表
/// @param modelClass model class
+ (BOOL)zfj_clearTable:(Class)modelClass;

/// 根据数据模型插入一条数据
/// @param model 数据模型
/// @param completed 操作回调
+ (void)zfj_insertModel:(NSObject *)model completed:(void(^)(NSError *error))completed;

/// 根据数据模型数组插入多条数据
/// @param models 数据模型数组
/// @param completed 操作回调
+ (void)zfj_insertModels:(NSArray *)models completed:(void(^)(NSError *error))completed;

/// 删除数据
/// @param modelClass model class
/// @param sqlStr sql语句
+ (BOOL)zfj_deleteModel:(Class)modelClass where:(NSString *)sqlStr;

/// 根据key修改单条数据
/// @param model 数据模型
/// @param key key
/// @param completed 操作回调
+ (void)zfj_updateModel:(NSObject *)model byKey:(NSString *)key completed:(void(^)(NSError *error))completed;

/// 根据key修改多条数据
/// @param models 数据模型数组
/// @param key key
/// @param completed 操作回调
+ (void)zfj_updateModels:(NSArray *)models byKey:(NSString *)key completed:(void(^)(NSError *error))completed;

/// 查询某个表的全部数据
/// @param modelClass model class
/// @param completed 操作回调
+ (void)zfj_selectTable:(Class)modelClass completed:(void(^)(NSError *error, NSArray *models))completed;

/// 根据条件查询某个表的数据
/// @param modelClass model class
/// @param sqlStr sql
/// @param completed 操作回调
+ (void)zfj_selectTable:(Class)modelClass where:(NSString *)sqlStr completed:(void(^)(NSError *error, NSArray *models))completed;

/// 查询某个表的全部数据条数
/// @param modelClass model class
+ (NSInteger)zfj_selectTableCount:(Class)modelClass;

/// 根据条件查询某个表部分数据条数
/// @param modelClass model class
/// @param sqlStr sql
+ (NSInteger)zfj_selectTableCount:(Class)modelClass where:(NSString *)sqlStr;

/// 向某个表添加一个字段
/// @param modelClass model class
/// @param propertyName 属性字段
+ (BOOL)zfj_addProperty:(Class)modelClass propertyName:(NSString *)propertyName;

/// 最后一条错误信息
+ (NSError *)zfj_lastTableError;

@end

NS_ASSUME_NONNULL_END
