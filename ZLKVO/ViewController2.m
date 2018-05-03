//
//  ViewController2.m
//  ZLKVO
//
//  Created by zhaoliang chen on 2018/5/3.
//  Copyright © 2018年 test. All rights reserved.
//

#import "ViewController2.h"
#import "ViewController1.h"
#import "Person.h"
#import "NSObject+ZLKVO.h"

@interface ViewController2 ()

@property(nonatomic,strong)Person* p;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
    
    self.p = [[Person alloc]init];
    
    [self.p zl_addObserver:self forKeyPath:@"name" withBlock:^(id observer, NSString *keyPath, id oldValue, id newValue) {
        NSLog(@"oldname=%@---newname=%@",oldValue,newValue);
    }];
//    [self.p zl_addObserver:self forKeyPath:@"age" withBlock:^(id observer, NSString *keyPath, id oldValue, id newValue) {
//        NSLog(@"oldage=%zd---newage=%zd",[oldValue integerValue],[newValue integerValue]);
//    }];
    self.p.name = @"czl";
    self.p.age = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"自定义KVO销毁了！");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.p.name = [self.p.name stringByAppendingString:@"+"];
    self.p.age=1;
}

@end
