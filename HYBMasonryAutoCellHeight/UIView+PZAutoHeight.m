//
//  UITableViewCell+PZAutoHeight.m
//  Equery
//
//  Created by phil zhang on 16/4/8.
//  Copyright © 2016年 benning. All rights reserved.
//

#import "UIView+PZAutoHeight.h"
#import <objc/runtime.h>

static const void *__PZLastView = "__PZLastView";
static const void *__PZBottomPadding = "__PZBottomPadding";
static const void *__PZSetDataSel = "__PZSetDataSel";

static const void *__PZHeightKey = "__PZHeightKey";
static const void *__PZHeightValue = "__PZHeightValue";

#define HeightCacheCount 500

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

@implementation UIView (PZAutoHeight)
static UIView               *__mTempInstance;

+ (CGFloat)heightByData:(id)data
{
    NSTimeInterval begin = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    NSTimeInterval now;
    NSString *key = [NSString stringWithFormat:@"%@/%@", [self class], [self objToDic:data]];
    now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    NSLog(@"/////==objToDic==%f ms", (now - begin) * 1000);
    if ([self checkHasCacheByKey:key]) {
        now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
        NSLog(@"/////==cache[%@]==%f ms", [self class], (now - begin) * 1000);
        return [self getHeightCacheByKey:key];
    }
    /**
     *  do-while 主要为了解决Cell嵌套的问题
     */
    do
    {
        [[self mTempInstance] setData:data];
    }while (![__mTempInstance isKindOfClass:[self class]]);
    
    [[self mTempInstance] layoutIfNeeded];
    NSNumber *height = @(CGRectGetMaxY([self mTempInstance].pzLastSubView.frame) + [self mTempInstance].pzBottomOffset);
    [self addHeightCache:key withHeight:height];
    now = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    NSLog(@"/////==no cache[%@]==%f ms", [self class], (now - begin) * 1000);
    return [height floatValue];
}

/**
 *  添加高度缓存,由于限定缓存数量,所以每次添加缓存的时候会判断已缓存数量
 *
 *  @param key    数据模型key
 *  @param height 高度
 */
+ (void)addHeightCache:(id)key withHeight:(NSNumber *)height
{
    if ([self mHeightKey].count == HeightCacheCount) {
        [[self mHeightKey] removeObjectAtIndex:0];
        [[self mHeightValue] removeObjectAtIndex:0];
    }
    [[self mHeightKey] addObject:key];
    [[self mHeightValue] addObject:height];
}

/**
 *  通过key获取已缓存的高度
 *
 *  @param key 数据模型key
 *
 *  @return 获取到的高度
 */
+ (float)getHeightCacheByKey:(id)key
{
    NSInteger index = [[self mHeightKey] indexOfObject:key];
    return [[[self mHeightValue] objectAtIndex:index] floatValue];
}

/**
 *  检查是否存在此key的缓存
 *
 *  @param key 数据模型为key
 *
 *  @return true为有缓存,false为无缓存
 */
+ (BOOL)checkHasCacheByKey:(id)key
{
    return [[self mHeightKey] containsObject:key];
}

+ (NSMutableArray *)mHeightKey
{
    NSMutableArray *__mHeightKey = objc_getAssociatedObject(self, __PZHeightKey);
    if (__mHeightKey == nil) {
        __mHeightKey = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, __PZHeightKey, __mHeightKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return __mHeightKey;
}

+ (NSMutableArray *)mHeightValue
{
    NSMutableArray *__mHeightValue = objc_getAssociatedObject(self, __PZHeightValue);
    if (__mHeightValue == nil) {
        __mHeightValue = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, __PZHeightValue, __mHeightValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return __mHeightValue;
}

+ (UIView *)mTempInstance
{
    if (__mTempInstance == nil || ![__mTempInstance isKindOfClass:[self class]]) {
        __mTempInstance = [[[self class] alloc] init];
    }
    return __mTempInstance;
}

- (void)setData:(id)data
{
    SEL sel = [self pzSetDataSel];
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:data];
    }
}

#pragma mark -你自己SetData方法
- (void)setPzSetDataSel:(SEL)pzSetDataSel
{
    objc_setAssociatedObject(self, __PZSetDataSel, NSStringFromSelector(pzSetDataSel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SEL)pzSetDataSel
{
    return NSSelectorFromString(objc_getAssociatedObject(self, __PZSetDataSel));
}

#pragma mark -最底部控件
- (UIView *)pzLastSubView
{
    return objc_getAssociatedObject(self, __PZLastView);
}

- (void)setPzLastSubView:(UIView *)pzLastSubView
{
    objc_setAssociatedObject(self, __PZLastView, pzLastSubView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -底部offset
- (CGFloat)pzBottomOffset
{
    NSNumber *offset = objc_getAssociatedObject(self, __PZBottomPadding);
    return offset.floatValue;
}

- (void)setPzBottomOffset:(CGFloat)pzBottomOffset
{
    objc_setAssociatedObject(self, __PZBottomPadding, @(pzBottomOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark -把NSObject转为NSDictionary,以此作为缓存key
+ (NSDictionary*)objToDic:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);//获得属性列表
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称
        id value = [obj valueForKey:propName];//kvc读值
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];//自定义处理数组，字典，其他类
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self objToDic:obj];
}

@end
