//
//  UITableViewCell+PZAutoHeight.h
//
//
//  Created by phil zhang on 16/4/8.
//  Copyright © 2016年 iphil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PZAutoHeight)

/**
 *  view或是cell中最底部的控件
 */
@property (nonnull, nonatomic, strong)  UIView           *pzLastSubView;

/**
 *  view或是cell中最底部控件距离cell底部的高度
 */
@property (nonatomic, assign)           CGFloat          pzBottomOffset;

/**
 *  设置为你自己的数据填充方法
 */
@property (nonatomic, assign, nullable) SEL              pzSetDataSel;

/**
 *  view或Cell填充data的方法，如果你的项目里面已经有了类似的方法，那么，你可以有两种方法使用
 *  1.在你的cell或view里面实现此方法，在方法内部调用你的view或是cell的数据填充方法
 *  2.设置pzSetDataSel=你的view或是cell的数据填充方法
 *
 *  @param data 数据模型
 */
- (void)setData:(id _Nullable)data;

/**
 *  根据数据模型获取cell高度
 *
 *  @param data 数据模型
 *
 *  @return 计算好的高度
 */
+ (CGFloat)heightByData:(id _Nullable)data;

@end
