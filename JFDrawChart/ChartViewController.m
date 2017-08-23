//
//  ChartViewController.m
//  JFDrawChart
//
//  Created by Terminator on 2017/3/27.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import "ChartViewController.h"

@interface ChartViewController ()

@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    ChartView *chartView = [[ChartView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.width) chartType:_chartType];
    chartView.backgroundColor = [UIColor blackColor];
    NSArray *dataArray = @[@"90", @"10", @"30", @"80", @"50", @"75", @"60"];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:dataArray];
    chartView.pointArray = arr;
    [self.view addSubview:chartView];
}

@end
