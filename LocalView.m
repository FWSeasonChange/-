//
//  LocalView.m
//  手势解锁
//
//  Created by 付玮 on 15/7/25.
//  Copyright (c) 2015年 付玮. All rights reserved.
//

#import "LocalView.h"

@interface LocalView ()
@property (nonatomic, strong) NSMutableArray *selectedBtns;
//保存移动时当前的点
@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation LocalView
#pragma mark - 懒加载
- (NSMutableArray *)selectedBtns
{
    if (_selectedBtns == nil) {
        _selectedBtns =[NSMutableArray array];
    }
    return _selectedBtns;
}



//创建自定义视图建议两个方法同时重写

//通过代码创建View调用init方法内部就是调用这个方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setp];
    }
    return  self;
}
//通过xib或者是stroyboard创建就会调用
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setp];
    }
    return self;
}
- (void)setp
{
    for (int i = 0; i < 9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        设置按钮的背景图片
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [self addSubview:btn];
//        禁止按钮点击事件，因为我们要监听出没事件
        btn.userInteractionEnabled = NO;
//        设置按钮的tag作为唯一标志，密码
        btn.tag = i;
    }
}
//设置自定义视图的frame，init方法中不能设置，设置没有用
-(void)layoutSubviews
{
#warning 一定要写
    [super layoutSubviews];
//    设置frame
    for (int i = 0; i < self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        
//        设置frame
        CGFloat btnW = 74;
        CGFloat btnH = 74;
//        间隙
        CGFloat padding = (self.frame.size.width - btnW * 3) / 4;
//        列号
        int col = i % 3;
//        行号
        int row  = i / 3;
//      btnX ＝  间隙 ＋ 列号（按钮宽度 ＋ 间隙）
        CGFloat btnX = padding + col * (btnW + padding);
//      btnY ＝   间隙 ＋ 行号（按钮宽度 ＋ 间隙）
        CGFloat btnY = padding + row * (btnW + padding);
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    CGPoint startPoint = [self getCurrentPoint:touches];
    UIButton *btn = [self btnSelectedWithPoint:startPoint];
//    数组不可以存空的值,btn会返回nil,(btn.selected != YES)不保存数组中已经有的按钮，防止重复连线
    if (btn && (btn.selected != YES)) {
        btn.selected = YES;
//        将按钮保存到数组
        [self.selectedBtns addObject:btn];
    }
//    [self setNeedsDisplay];
    
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    //    获取按下的点
    CGPoint movePoint = [self getCurrentPoint:touches];
    UIButton *btn = [self btnSelectedWithPoint:movePoint];
    //    数组不可以存空的值,btn会返回nil
    if (btn && (btn.selected != YES)) {
        btn.selected = YES;
        //        将按钮保存到数组
        [self.selectedBtns addObject:btn];
        
    }
//    存下所有的点
    self.currentPoint = movePoint;
    [self setNeedsDisplay];

}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    取出用户输入的密码
    NSMutableString *results = [NSMutableString string];
    for (UIButton *btn in self.selectedBtns) {
//        把tag数字组成一个字符串
        [results appendFormat:@"%ld",(long)btn.tag];
    }
//    通知代理用户输入完了密码
    if ([self.delegate respondsToSelector:@selector(lockViewDidClickWithView:andPassWord:)]) {
//        判断如果代理里面有这个方法就执行
        [self.delegate lockViewDidClickWithView:self andPassWord:results];
        
    }
    NSLog(@"touchesEnded --密码 = %@",results);

//    数组中每一个元素都调用次方法Selector:并且给这个方法传入Object:值
    [self.selectedBtns makeObjectsPerformSelector:@selector(setSelected:) withObject:0];
    
    [self.selectedBtns removeAllObjects];
//    设置成0，0，如果在begin中调用的setneedsdisplay,但是self.currentPoint还有数据，就会再连线，解决，不在begin中调用的setneedsdisplay，或者结束时设置为zero，画线时再判断
//    self.currentPoint = CGPointZero;
    [self setNeedsDisplay];
}
- (CGPoint)getCurrentPoint:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    //    获取按下的点
    CGPoint point = [touch locationInView:touch.view];
    return point;
}
- (UIButton *)btnSelectedWithPoint:(CGPoint)point
{
    for  (UIButton *btn in self.subviews) {
        //    判断触摸点是否在按钮范围内
        if (CGRectContainsPoint(btn.frame, point)) {
//            btn.selected = YES;
//            返回触摸到的按钮
            return btn;
        }
    }
    return nil;
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /*
     当把View设置成默认颜色（默认显示黑色）时就会有缓存，会记录显示每一条线，不会清除，当设置为其他颜色时也有，不过颜色会盖住，建议清空
     所以当为默认颜色时要清空上下文
     */
//    清空上下文
    CGContextClearRect(ctx, rect);
//    线连接按钮的点
    for (int i = 0; i < self.selectedBtns.count; i++)
    {
        UIButton *btn = self.selectedBtns[i];
        if (i == 0)
        {
            CGContextMoveToPoint(ctx, btn.center.x, btn.center.y);
        }
        else
        {
            CGContextAddLineToPoint(ctx, btn.center.x, btn.center.y);
        }
    }
//    以最后一个按钮的点作为起点，按钮外的点作为重点实现把线拖出来、
    
    if (self.selectedBtns.count != 0) {
//        判断是否有起点
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
    }
//    if (!CGPointEqualToPoint(self.currentPoint, CGPointZero)) {
////        如果两个点不同
//        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
//    }
//    设置线条颜色
    [[UIColor greenColor]set];
//    设置线条粗细
    CGContextSetLineWidth(ctx, 8);
//    设置线条两端的样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
//    设置线条转角的样式
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
//    渲染
    CGContextStrokePath(ctx);
}



@end
