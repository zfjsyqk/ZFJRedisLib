//
//  ZFJSimpleObject.m
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//

#import "ZFJSimpleObject.h"
#import "FMDatabase.h"
#import "ZFJRedisModel.h"
#import "ZFJTable.h"

// 数据库名字
#define KDataBaseName @"ZFJRedisDataBase.sqlite"
//数据库路径
#define KDataBasePath [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",KDataBaseName]]

@interface ZFJSimpleObject ()

@end

@implementation ZFJSimpleObject

static ZFJSimpleObject *simObj;

+ (ZFJSimpleObject *)manager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        simObj = [[super allocWithZone:NULL] init];
    });
    return simObj;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [ZFJSimpleObject manager];
}

- (id)copyWithZone:(struct _NSZone *)zone{
    return [ZFJSimpleObject manager];
}

- (id)init{
    if (self = [super init]){
        self.dsema = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - 懒加载
- (FMDatabase *)dataBase{
    if(_dataBase == nil){
        NSLog(@"KDataBasePath == %@",KDataBasePath);
        _dataBase = [[FMDatabase alloc] initWithPath:KDataBasePath];
        [_dataBase open];
    }
    return _dataBase;
}

- (NSString *)dataBasePath{
    return KDataBasePath;
}

@end
