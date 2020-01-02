//
//  NSObject+ZFJModel.m
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//

#import "NSObject+ZFJModel.h"
#import <objc/runtime.h>

@implementation NSObject (ZFJModel)

/// 获取当前对象所以的属性名称
- (NSArray *)zfj_propertyNames{
    NSMutableArray *propertyNames = [[NSMutableArray alloc] init];

    /// 存储属性的个数
    unsigned int propertyCount = 0;
    
    /// 通过运行时获取当前类的属性
    objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
    
    /// 把属性放到数组中
    for (int i = 0; i < propertyCount; i ++) {
        /// 取出第一个属性
        objc_property_t property = propertys[i];
        
        const char * propertyName = property_getName(property);
        
        [propertyNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    /// 释放
    free(propertys);
    
    return propertyNames;
}

/// Model转字典
- (NSDictionary *)zfj_modelToDict{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (i = 0; i<outCount; i++){
        // 取出第一个属性
        objc_property_t property = properties[i];
        
        const char *char_f =property_getName(property);
        
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    
    free(properties);
    
    return props;
}

/// 通过Key获取Value值
/// @param key Key
- (NSString *)zfj_valueForKey:(NSString *)key{
    key = [key stringByAppendingFormat:@"_%@",key];
    Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
    NSString *pageNameValue = object_getIvar(self, ivar);
    return pageNameValue;
}

/// 根据Model获取表名
- (NSString *)zfj_tableName{
    NSString *tableName = NSStringFromClass([self class]);
    tableName = [tableName stringByAppendingString:@"_Table"];
    return tableName;
}

@end
