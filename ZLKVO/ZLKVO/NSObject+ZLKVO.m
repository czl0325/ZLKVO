//
//  NSObject+ZLKVO.m
//  ZLKVO
//
//  Created by zhaoliang chen on 2018/5/3.
//  Copyright © 2018年 test. All rights reserved.
//

#import "NSObject+ZLKVO.h"
#import <objc/message.h>

@interface ZLInfo : NSObject

@property(nonatomic,weak)id observer;
@property(nonatomic,copy)NSString* keyPath;
@property(nonatomic,copy)ZLKVOBlock blockHandle;

@end

@implementation ZLInfo

- (instancetype)initWithObserver:(id)observer keyPath:(NSString* )keyPath blockHandle:(ZLKVOBlock)blockHandle {
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _blockHandle = blockHandle;
    }
    return self;
}
@end

@implementation NSObject (ZLKVO)

static NSString* const ZLKVO_Prefix = @"ZLKVO_";
static NSString* const ZLKVOAssionKey = @"ZLKVOAssionKey";

- (void)zl_addObserver:(NSObject*)observer forKeyPath:(NSString*)keyPath withBlock:(ZLKVOBlock)block {
    
    //首先判断keyPath 是成员变量还是实例变量，如果是实例变量就不添加kvo方法
    SEL setterSelector = NSSelectorFromString(setterFromGetter(keyPath));
    Method setterMethod = class_getInstanceMethod(object_getClass(self), setterSelector);
    if (setterMethod==nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@不是成员变量，没有setter方法",keyPath] userInfo:nil];
        return;
    }
    //动态创建子类
    NSString* superClassName = NSStringFromClass([self class]);
    Class newClass = [self createClassFromSuperClass:superClassName];
    //把newClass指向self,很重要,交换isa指针
    object_setClass(self, newClass);
    
    //生成set方法
    const char* type = method_getTypeEncoding(setterMethod);//获取父类class方法的类型
//    NSMethodSignature *methodSig = [self methodSignatureForSelector:NSSelectorFromString(keyPath)];
//    if (methodSig!=nil) {
//        const char* retType = [methodSig methodReturnType];
//        if (strcmp(retType, @encode(NSInteger))==0) {
//            NSLog(@"一直");
//        }
//    }
    class_addMethod(newClass, setterSelector, (IMP)ZLKVO_setter, type);
    
    //消息转发
    ZLInfo* info = [[ZLInfo alloc]initWithObserver:observer keyPath:keyPath blockHandle:block];
    
    NSMutableArray* observerArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(ZLKVOAssionKey));
    
    if (!observerArray) {
        observerArray = [NSMutableArray arrayWithCapacity:1];
        objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(ZLKVOAssionKey), observerArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [observerArray addObject:info];
    
    //编写子类的dealloc方法和父类的对换
    Method myDeallocMethod = class_getInstanceMethod(newClass, @selector(myDealloc));
    Method deallocMethod = class_getInstanceMethod(newClass, NSSelectorFromString(@"dealloc"));
    method_exchangeImplementations(myDeallocMethod, deallocMethod);
}

//动态创建子类
- (Class)createClassFromSuperClass:(NSString*)superName {
    Class superClass = NSClassFromString(superName);
    NSString* newClassName = [ZLKVO_Prefix stringByAppendingString:superName];
    Class newClass = NSClassFromString(newClassName);
    if (newClass) {
        return newClass;
    }
    /*
     动态创建子类
     1.父类，2。名字 3.空间
     */
    newClass = objc_allocateClassPair(superClass, [newClassName UTF8String], 0);
    
    //添加class方法
    Method classMethod = class_getInstanceMethod(superClass, @selector(class));//获取父类class方法
    const char* type = method_getTypeEncoding(classMethod);//获取父类class方法的类型
    class_addMethod(newClass, @selector(class), (IMP)ZLKVO_class, type);
    
    //创建完后要注册类,注册后才可以使用
    objc_registerClassPair(newClass);
    
    return newClass;
}

- (void)myDealloc {
    NSString* nowClassName = NSStringFromClass(object_getClass(self));
    NSString* superClassName = [nowClassName stringByReplacingOccurrencesOfString:ZLKVO_Prefix withString:@""];
    Class superClass = NSClassFromString(superClassName);
    object_setClass(self, superClass);
    
    NSMutableArray* observerArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(ZLKVOAssionKey));
    [observerArray removeAllObjects];
    
    [self myDealloc];
}

#pragma mark 函数区域
static Class ZLKVO_class(id self) {
    return class_getSuperclass(object_getClass(self));
}

static void ZLKVO_setter(id self, SEL _cmd, id newValue) {
    NSString* setterName = NSStringFromSelector(_cmd);
    NSString* getterName = getterFromSetter(setterName);
    if (!getterName) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ not instance getter",self] userInfo:nil];
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    [self willChangeValueForKey:getterName];
    //消息转发到父类
    void(*ZLMsgSend)(void* , SEL, id) = (void*)objc_msgSendSuper;
    
    struct objc_super zlSuperStruct = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    ZLMsgSend(&zlSuperStruct, _cmd, newValue);
    
    [self didChangeValueForKey:getterName];
    
    NSMutableArray* observerArray = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(ZLKVOAssionKey));
    
    for (ZLInfo* info in observerArray) {
        info.blockHandle(info.observer, info.keyPath, oldValue, newValue);
    }
}

static NSString* setterFromGetter(NSString* getter) {
    if (getter.length <= 0) {
        return nil;
    }
    NSString* firstString = [getter substringToIndex:1];
    firstString = [firstString uppercaseString];
    NSString* leaveString = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",firstString,leaveString];
}

static NSString* getterFromSetter(NSString* setter) {
    if (setter.length <= 0 || ![setter hasPrefix:@"set"]) {
        return nil;
    }
    NSRange range = NSMakeRange(3, setter.length-4);
    NSString* getter = [setter substringWithRange:range];
    NSString* firstString = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstString];
    return getter;
}

@end
