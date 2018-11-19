//
//  JFNoticeScrollView.h
//  公告滚动
//
//  Created by yidezhang on 2018/11/15.
//  Copyright © 2018 yidezhang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface JFNoticeScrollView : UIView

@property (nonatomic, assign) NSInteger showItemCount;//显示几条数据
@property (nonatomic, copy) NSArray <NSString*> *dataSource;//显示数据
@property (nonatomic, assign) CGFloat duration;//多长时间滚动一次 
@property (nonatomic, strong) UIFont *itemFont;
@property (nonatomic, strong) UIColor *itemStrColor;

/**
 刷新view

 @param block 点击之后的回调
 */
-(void)reloadViewWithSelectAction:(void((^)(NSInteger index)))block;

@end
