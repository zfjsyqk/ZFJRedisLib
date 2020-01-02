//
//  ZFJRedisModel.h
//  ZFJRedisLibDemo
//
//  Created by ZFJMBPro on 2019/12/6.
//  Copyright © 2019 Administrator. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFJRedisModel : NSObject

@property (nonatomic,  copy) NSString *key;
@property (nonatomic,  copy) id value;

@end

NS_ASSUME_NONNULL_END
