//
//  ItemListCell.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-23.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ItemListCell.h"
#import "ReviewItem.h"
#import "UIImageView+setPath.h"

@interface ItemListCell ()
@property (nonatomic, strong) UILabel* label_date;
@property (nonatomic, strong) UIImageView* imageView_first;
@property (nonatomic, strong) UIImageView* imageView_second;

@end

@implementation ItemListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.editingAccessoryType = UITableViewCellAccessoryNone;
        self.label_date = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
        [self.contentView addSubview:self.label_date];
        
        self.imageView_first = [[UIImageView alloc]initWithFrame:CGRectMake(150, 0, 40, 40)];
        self.imageView_first.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView_first];
        
        self.imageView_second = [[UIImageView alloc]initWithFrame:CGRectMake(200, 0, 40, 40)];
        self.imageView_second.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.imageView_second];
    }
    return self;
}

- (void)setInfo:(id)info
{
    if ([info isKindOfClass:[ReviewItem class]])
    {
        ReviewItem* item = info;
        _info = info;
        self.label_date.text = [NSString stringWithFormat:@"%d", item.dateId_created];
        NSString* str_file1 = [item getImagePathAtIndex:0];
        NSString* str_file2 = [item getImagePathAtIndex:1];
        [self.imageView_first setThumbnailImageWithPath:str_file1 size:CGSizeMake(50, 50)];
        [self.imageView_second setThumbnailImageWithPath:str_file2 size:CGSizeMake(50, 50)];
    }
}
@end
