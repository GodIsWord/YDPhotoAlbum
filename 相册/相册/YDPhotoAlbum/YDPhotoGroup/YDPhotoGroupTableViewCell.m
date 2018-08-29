//
//  YDPhotoGroupTableViewCell.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoGroupTableViewCell.h"

@interface YDPhotoGroupTableViewCell()


@end

@implementation YDPhotoGroupTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubbView];
    }
    return self;
}
-(void)initSubbView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES;
    [self.contentView addSubview:imageView];
    self.pictureImage = imageView;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+5, 20, 100, 20)];
    nameLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+5, CGRectGetMaxY(nameLabel.frame)+5, 100, 20)];
    numLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:numLabel];
    self.numLabel = numLabel;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 79.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:line];
}
@end
