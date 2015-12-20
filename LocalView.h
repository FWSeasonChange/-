//
//  LocalView.h
//  手势解锁
//
//  Created by 付玮 on 15/7/25.
//  Copyright (c) 2015年 付玮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocalView;
//设置代理协议把密码给控制器
@protocol LocalViewDelegate <NSObject>

- (void)lockViewDidClickWithView:(LocalView *)localView andPassWord:(NSString *)passWord;

@end

@interface LocalView : UIView


@property (nonatomic, weak) id<LocalViewDelegate> delegate
;
@end
