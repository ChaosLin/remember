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
#import "DateUtils.h"

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
//        self.editingAccessoryType = UITableViewCellAccessoryNone;
        self.label_date = [[UILabel alloc]initWithFrame:CGRectMake(253, 35, 74, 20)];
        self.label_date.textAlignment = NSTextAlignmentRight;
        self.label_date.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.contentView addSubview:self.label_date];
        
        self.imageView_first = [[UIImageView alloc]initWithFrame:CGRectMake(24, 22, 50, 50)];
        self.imageView_first.backgroundColor = [UIColor clearColor];
        self.imageView_first.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView_first];
        
        self.imageView_second = [[UIImageView alloc]initWithFrame:CGRectMake(100, 22, 50, 50)];
        self.imageView_second.backgroundColor = [UIColor clearColor];
        self.imageView_second.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView_second];
        
        self.backgroundView = [[UIView alloc]initWithFrame:self.bounds];
    }
    return self;
}

- (void)setInfo:(id)info
{
    if ([info isKindOfClass:[ReviewItem class]])
    {
        ReviewItem* item = info;
        _info = info;
        self.label_date.text = [DateUtils changeToDateFormateWithDayID:item.dateId_created];
        NSString* str_file1 = [item getImagePathAtIndex:0];
        NSString* str_file2 = [item getImagePathAtIndex:1];
        if (str_file1)
        {
            [self.imageView_first setThumbnailImageWithPath:str_file1 size:CGSizeMake(100, 100)];
        }
        else
        {
            [self.imageView_second setThumbnailImageWithPath:nil size:CGSizeMake(100, 100)];
        }
        
        if (str_file2)
        {
            [self.imageView_second setThumbnailImageWithPath:str_file2 size:CGSizeMake(100, 100)];
        }
        else
        {
            [self.imageView_second setThumbnailImageWithPath:nil size:CGSizeMake(100, 100)];
        }
    }
}
@end
