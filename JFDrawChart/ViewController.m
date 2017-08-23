//
//  ViewController.m
//  JFDrawChart
//
//  Created by Terminator on 2017/3/27.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import "ViewController.h"
#import "ChartViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *testArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonAction:(UIButton *)sender {
    switch (sender.tag) {
        case 1://折线图
        {
            [self jumpPage:JFChartTypeLine];
        }
            break;
        case 2://条形图
        {
            [self jumpPage:JFChartTypeBar];
        }
            break;
        case 3://饼状图
        {
            [self jumpPage:JFChartTypePie];
        }
            break;
        default:
            break;
    }
}

- (void)jumpPage:(JFChartType)chartType {
    ChartViewController *chartVC = [[ChartViewController alloc] init];
    chartVC.chartType = chartType;
    [self.navigationController pushViewController:chartVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
