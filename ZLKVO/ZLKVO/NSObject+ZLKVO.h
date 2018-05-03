//
//  NSObject+ZLKVO.h
//  ZLKVO
//
//  Created by zhaoliang chen on 2018/5/3.
//  Copyright © 2018年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ZLKVOBlock)(id observer,NSString *keyPath,id oldValue,id newValue);

@interface NSObject (ZLKVO)

- (void)zl_addObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath withBlock:(ZLKVOBlock)block;

@end
