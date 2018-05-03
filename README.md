# ZLKVO
阐述系统KVO的底层实现原理，以及如何自己手写一个KVO，在系统KVO的基础上进行深度优化。

# 面试经常被问到KVO与KVC

  答：其实KVO就是使用runtime+kvc来实现的<br>
      假设有个类叫Person，里面有个属性为name，我们要使用KVO来监听name的值，<br>
      系统KVO的实现原理分三步走：<br>
      1.先动态生成一个NSKVONotifing_Person的子类<br>
      2.在子类中添加setName:方法<br>
      3.消息转发<br>
      
# 如果不用系统的KVO，我们可以自己手写一个KVO

```Objective-C

//系统的kvo需要三步，创建观察者，观察对象，销毁观察者

//创建观察者
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

//代理回调监听
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
 
 //移除观察者
 [self.person removeObserver:self forKeyPath:@"name" context:nil];

```

而我手写的KVO，只需要写一步：

```Objective-C

[self.p zl_addObserver:self forKeyPath:@"name" withBlock:^(id observer, NSString *keyPath, id oldValue, id newValue) {
    NSLog(@"oldname=%@---newname=%@",oldValue,newValue);
}];
    
```

这样就可以监听name的值，并且实现了自动销毁，不需要调用系统的移除观察者的方法。极大的简化了KVO的步骤和代码量！
