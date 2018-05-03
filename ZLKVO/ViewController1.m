//
//  ViewController1.m
//  ZLKVO
//
//  Created by zhaoliang chen on 2018/5/3.
//  Copyright © 2018年 test. All rights reserved.
//

#import "ViewController1.h"
#import "ViewController2.h"

@interface ViewController1 ()

@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton* btn = [[UIButton alloc]initWithFrame:CGRectMake(30, 100, 100, 50)];
    btn.backgroundColor = [UIColor yellowColor];
    [btn setTitle:@"进入下一页" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClick {
    ViewController2* vc = [[ViewController2 alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
