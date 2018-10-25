//
//  UIColor+Catalog.h
//  OLinPiKe
//
//  Created by  on 16/6/20.
//  Copyright © 2016年 alta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIColor(ARCatalog)
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert alpha:(CGFloat)alpha;
@end
