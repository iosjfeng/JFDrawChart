//
//  ChartView.h
//  JFDrawChart
//
//  Created by Terminator on 2017/3/27.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, JFChartType) {
    JFChartTypeLine,
    JFChartTypeBar,
    JFChartTypePie
};

@interface ChartView : UIView <CAAnimationDelegate>

@property (nonatomic, unsafe_unretained) JFChartType chartType;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, unsafe_unretained) CGPoint startPoint;
@property (nonatomic, unsafe_unretained) CGPoint endPoint;
@property (nonatomic, unsafe_unretained) NSInteger currentNum;

- (instancetype)initWithFrame:(CGRect)frame chartType:(JFChartType)chartType;

@end
