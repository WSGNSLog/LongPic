//
//  ViewController.m
//  LongPic
//
//  Created by shiguang on 2018/9/5.
//  Copyright © 2018年 shiguang. All rights reserved.
//

#import "ViewController.h"
#import "LocalAlbumController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}
- (IBAction)next:(UIButton *)sender {
    
    LocalAlbumController *album = [[LocalAlbumController alloc]init];
    [self.navigationController pushViewController:album animated:YES];
}



@end
