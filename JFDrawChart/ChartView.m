//
//  ChartView.m
//  JFDrawChart
//
//  Created by Terminator on 2017/3/27.
//  Copyright © 2017年 Terminator. All rights reserved.
//

#import "ChartView.h"

#define TOP 10
#define LEFT 30
#define BOTTOM 30
#define RIGHT 10
#define VIEW_WIDHT self.frame.size.width
#define VIEW_HEIGHT self.frame.size.height
//饼形图需要的宏定义
#define kAnimationDuration 1.0f
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define kPieBackgroundColor [UIColor grayColor]
#define kPieFillColor [UIColor clearColor].CGColor
#define kPieRandColor [UIColor colorWithRed:arc4random() % 255 / 255.0f green:arc4random() % 255 / 255.0f blue:arc4random() % 255 / 255.0f alpha:1.0f]
#define kLabelLoctionRatio (1.2*bgRadius)

@interface ChartView ()
{
    //饼形图需要的变量
    CGFloat _total;
    CAShapeLayer *_bgCircleLayer;
}
//饼形图颜色数据
@property(nonatomic ,strong)NSArray *colorItems;
@end

@implementation ChartView

- (instancetype)initWithFrame:(CGRect)frame chartType:(JFChartType)chartType
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemArray = @[@"iOS", @"Java", @"PHP", @"HTML", @"Android", @"C语言", @"C++"];
        _currentNum = 0;
        _chartType = chartType;
        if (_chartType != JFChartTypePie) {
            [self drawTick];
        }
    }
    return self;
}

//绘制刻度
- (void)drawTick {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(LEFT, TOP)];
    [bezierPath addLineToPoint:CGPointMake(LEFT, VIEW_HEIGHT - BOTTOM)];
    [bezierPath moveToPoint:CGPointMake(LEFT, VIEW_HEIGHT - BOTTOM)];
    [bezierPath addLineToPoint:CGPointMake(VIEW_WIDHT - RIGHT, VIEW_HEIGHT - BOTTOM)];
    
    CGFloat yPadding = (VIEW_HEIGHT - TOP - BOTTOM) / 10;
    for (int i = 0; i < 10; i ++) {
        [bezierPath moveToPoint:CGPointMake(LEFT, VIEW_HEIGHT - BOTTOM - i * yPadding)];
        [bezierPath addLineToPoint:CGPointMake(LEFT + 2, VIEW_HEIGHT - BOTTOM - i * yPadding)];
        
        UILabel *yLabel = [[UILabel alloc]initWithFrame:CGRectMake(LEFT - 20, VIEW_HEIGHT - BOTTOM - i * yPadding - 10, 20, 20)];
        yLabel.textColor = [UIColor redColor];
        yLabel.font = [UIFont systemFontOfSize:10];
        yLabel.textAlignment = NSTextAlignmentCenter;
        yLabel.text = [NSString stringWithFormat:@"%d",i * 10];
        [self addSubview:yLabel];
    }
    
    CGFloat xPadding = (VIEW_HEIGHT - TOP - BOTTOM) / (_itemArray.count + 1);
    for (int i = 0; i < _itemArray.count + 1; i ++) {
        [bezierPath moveToPoint:CGPointMake(LEFT + xPadding * i, VIEW_HEIGHT - BOTTOM)];
        [bezierPath addLineToPoint:CGPointMake(LEFT + xPadding * i, VIEW_HEIGHT - BOTTOM - 2)];
        if (i > 0) {
            UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT + xPadding * i - xPadding / 2, VIEW_HEIGHT - BOTTOM, xPadding, 20)];
            xLabel.textColor = [UIColor redColor];
            xLabel.font = [UIFont systemFontOfSize:10];
            xLabel.textAlignment = NSTextAlignmentCenter;
            xLabel.text = [_itemArray objectAtIndex:i - 1];
            [self addSubview:xLabel];
        }
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 1.0;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:shapeLayer];
}

//绘制折线图
- (void)drawLineChart {
    //绘制最后一个点
    if (_currentNum == _pointArray.count) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        // 添加圆到path
        [bezierPath addArcWithCenter:_startPoint radius:3.0 startAngle:0.0 endAngle:M_PI*2 clockwise:YES];
        // 设置描边宽度（为了让描边看上去更清楚）
        // 描边和填充
        [bezierPath stroke];
        [bezierPath fill];
        
        CAShapeLayer *shaperLayer = [CAShapeLayer layer];
        shaperLayer.path = bezierPath.CGPath;
        shaperLayer.lineWidth = 2.0;
        shaperLayer.strokeColor = [UIColor whiteColor].CGColor;
        shaperLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:shaperLayer];
        return;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:_startPoint radius:3.0 startAngle:0.0 endAngle:M_PI * 2 clockwise:YES];
    [bezierPath moveToPoint:_startPoint];
    [bezierPath addLineToPoint:_endPoint];
    [bezierPath stroke];
    [bezierPath fill];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 2.0;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [UIColor whiteColor].CGColor;
    
    CABasicAnimation *basicAnimation = [CABasicAnimation animation];
    basicAnimation.delegate = self;
    basicAnimation.fromValue = @0;
    basicAnimation.toValue = @1;
    basicAnimation.duration = .25;
    [shapeLayer addAnimation:basicAnimation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [self.layer addSublayer:shapeLayer];

    _startPoint = _endPoint;
}

//绘制条形图
- (void)drawBarChart {
    UIBezierPath *path = [UIBezierPath bezierPath];
    //绘制折线图
    [path moveToPoint:_startPoint];
    [path addLineToPoint:_endPoint];
    path.lineJoinStyle = kCGLineJoinRound;
    //设置layer层
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.path = path.CGPath;
    CGFloat scaleX = (self.frame.size.width - LEFT - RIGHT) / 8.0;
    shaperLayer.lineWidth = scaleX;
    shaperLayer.strokeColor = kPieRandColor.CGColor;
    shaperLayer.fillColor = kPieRandColor.CGColor;
    //设置动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    anim.delegate = self;
    anim.fromValue = @0;
    anim.toValue = @1;
    anim.duration = .25;
    
    [shaperLayer addAnimation:anim forKey:NSStringFromSelector(@selector(strokeEnd))];
    [self.layer addSublayer:shaperLayer];
}

//绘制饼状图
- (void)drawPieChart {
//    self.hidden =  YES;
    self.backgroundColor = kPieBackgroundColor;
    
    //1.pieView中心点
    CGFloat centerWidth = self.frame.size.width * 0.5f;
    CGFloat centerHeight = self.frame.size.height * 0.5f;
    CGFloat centerX = centerWidth;
    CGFloat centerY = centerHeight;
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    CGFloat radiusBasic = centerWidth > centerHeight ? centerHeight : centerWidth;
    
    //计算红绿蓝部分总和
    _total = 0.0f;
    for (int i = 0; i < _pointArray.count; i++) {
        _total += [_pointArray[i] floatValue];
    }
    
    //线的半径为扇形半径的一半，线宽是扇形半径，这样就能画出圆形了
    //2.背景路径
    CGFloat bgRadius = radiusBasic * 0.5;
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                          radius:bgRadius
                                                      startAngle:-M_PI_2
                                                        endAngle:M_PI_2 * 3
                                                       clockwise:YES];
    _bgCircleLayer = [CAShapeLayer layer];
    _bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
    _bgCircleLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    _bgCircleLayer.strokeStart = 0.0f;
    _bgCircleLayer.strokeEnd   = 1.0f;
    _bgCircleLayer.zPosition   = 1;
    _bgCircleLayer.lineWidth   = bgRadius * 2.0f;
    _bgCircleLayer.path        = bgPath.CGPath;
    
    //3.子扇区路径
    CGFloat otherRadius = radiusBasic * 0.5 - 3.0;
    UIBezierPath *otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                             radius:otherRadius
                                                         startAngle:-M_PI_2
                                                           endAngle:M_PI_2 * 3
                                                          clockwise:YES];
    CGFloat start = 0.0f;
    CGFloat end = 0.0f;
    for (int i = 0; i < _pointArray.count; i++) {
        //4.计算当前end位置 = 上一个结束位置 + 当前部分百分比
        end = [_pointArray[i] floatValue] / _total + start;
        
        //图层
        CAShapeLayer *pie = [CAShapeLayer layer];
        [self.layer addSublayer:pie];
        pie.fillColor   = kPieFillColor;
        if (i > _colorItems.count - 1 || !_colorItems  || _colorItems.count == 0) {//如果传过来的颜色数组少于item个数则随机填充颜色
            pie.strokeColor = kPieRandColor.CGColor;
        } else {
            pie.strokeColor = ((UIColor *)_colorItems[i]).CGColor;
        }
        pie.strokeStart = start;
        pie.strokeEnd   = end;
        pie.lineWidth   = otherRadius * 2.0f;
        pie.zPosition   = 2;
        pie.path        = otherPath.CGPath;
        
        //计算百分比label的位置
        CGFloat centerAngle = M_PI * (start + end);
        CGFloat labelCenterX = kLabelLoctionRatio * sinf(centerAngle) + centerX;
        CGFloat labelCenterY = -kLabelLoctionRatio * cosf(centerAngle) + centerY;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, radiusBasic * 0.7f, radiusBasic * 0.7f)];
        label.center = CGPointMake(labelCenterX, labelCenterY);
        label.text = [NSString stringWithFormat:@"%ld%%",(long)((end - start + 0.005) * 100)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.layer.zPosition = 3;
        [self addSubview:label];
        //计算下一个start位置 = 当前end位置
        start = end;
    }
    self.layer.mask = _bgCircleLayer;
//    [self stroke];
}

//绘制动画（饼形图）
- (void)stroke
{
    //画图动画
    self.hidden = NO;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = kAnimationDuration;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [_bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
}

- (void)setPointArray:(NSArray *)pointArray {
    if (pointArray) {
        if (!_pointArray) {
            _pointArray = [NSMutableArray array];
        }
        if (_chartType == JFChartTypeLine) {
            [_pointArray addObjectsFromArray:[self disposePointArray:pointArray]];
            _startPoint = CGPointFromString([_pointArray objectAtIndex:0]);
            [self getStartPointAndEndPoint];
        } else if (_chartType == JFChartTypeBar){
            [_pointArray addObjectsFromArray:[self disposePointArray:pointArray]];
            _startPoint = CGPointMake((VIEW_WIDHT - LEFT - RIGHT) / 8 + LEFT, VIEW_HEIGHT - BOTTOM);
            _endPoint = CGPointFromString([_pointArray objectAtIndex:0]);
            [self setNeedsDisplay];
        }else {
            [_pointArray addObjectsFromArray:[self disposePointArray:pointArray]];
            [self setNeedsDisplay];
        }
    }
}

//把坐标点转换成绘图时需要的真实的坐标点
- (NSMutableArray *)disposePointArray:(NSArray *)array {
    if (_chartType == JFChartTypePie) {
        NSMutableArray *points = [NSMutableArray array];
        CGFloat allFloat = 0.0;
        for (NSString *string in array) {
            allFloat = allFloat + [string floatValue];
        }
        for (NSString *string in array) {
            CGFloat f = [string floatValue] / allFloat;
            [points addObject:[NSString stringWithFormat:@"%.2f",f]];
        }
        return points;
    } else {
        NSMutableArray *mutableArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++) {
            NSString *string = [array objectAtIndex:i];
            CGFloat y = (VIEW_HEIGHT - BOTTOM) - ([string floatValue] / 100.0 * (VIEW_HEIGHT - BOTTOM - TOP));
            CGPoint point = CGPointMake(LEFT + ((VIEW_WIDHT - LEFT - RIGHT) / (_itemArray.count + 1) * (i + 1)), y);
            [mutableArray addObject:NSStringFromCGPoint(point)];
        }
        return mutableArray;
    }
}

//获取绘制的开始点和结束点
- (void)getStartPointAndEndPoint {
    _currentNum ++;
    if (_chartType == JFChartTypeLine) {
        if (_currentNum < _pointArray.count) {
            NSString *pointStr = [_pointArray objectAtIndex:_currentNum];
            _endPoint = CGPointFromString(pointStr);
            [self setNeedsDisplay];
        } else if (_currentNum == _pointArray.count){
            [self setNeedsDisplay];
        } else {}
    } else if (_chartType == JFChartTypeBar){
        if (_currentNum < _pointArray.count) {
            CGFloat scaleX = (VIEW_WIDHT - LEFT - RIGHT) / 8.0;
            _startPoint = CGPointMake((VIEW_WIDHT - LEFT - RIGHT) / 8 + LEFT + scaleX * _currentNum, VIEW_HEIGHT - BOTTOM);
            NSString *pointStr = [_pointArray objectAtIndex:_currentNum];
            _endPoint = CGPointFromString(pointStr);
            [self setNeedsDisplay];
        }
    }
}

#pragma mark CAAnimationDelegate 监听动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self getStartPointAndEndPoint];
    }
}

- (void)drawRect:(CGRect)rect {
    if (_chartType == JFChartTypeLine) {
        [self drawLineChart];
    } else if (_chartType == JFChartTypeBar) {
        [self drawBarChart];
    } else {
        [self drawPieChart];
    }
}

@end
