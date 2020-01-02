//
//  ZFJSimpleObject.h
//  ZFJRedisLib
//
//  Created by ZFJMBPro on 2019/12/5.
//  Copyright © 2019 ZFJ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;

@interface ZFJSimpleObject : NSObject

+ (ZFJSimpleObject *)manager;

/// 数据库FMDB
@property (nonatomic,retain) FMDatabase *dataBase;

/// 信号量
@property (nonatomic,strong) dispatch_semaphore_t dsema;

/// 数据库路径
@property (nonatomic,  copy) NSString *dataBasePath;

/// 是否打印Reddis错误
@property (nonatomic,assign) BOOL printRedisError;

@end
