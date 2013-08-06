//
//  ViewController.m
//  PagedLayout
//
//  Created by Liam Nichols on 06/08/2013.
//  Copyright (c) 2013 Liam Nichols. All rights reserved.
//

#import "ViewController.h"

#define DEBUG_LAYOUT 1

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];

    LNCollectionViewPagedLayout *layout = [[LNCollectionViewPagedLayout alloc] init];

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];

    [self.view addSubview:self.collectionView];

#if DEBUG_LAYOUT
    self.view.backgroundColor = [UIColor redColor];
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor greenColor];
#endif
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2 + arc4random() % 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5 + arc4random() % 15;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 20, (arc4random()%(600-100))+100);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    NSInteger textLabelTag = 6;
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:textLabelTag];
    if (textLabel == nil)
    {
        textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.tag = textLabelTag;
        textLabel.frame = cell.contentView.bounds;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        [cell.contentView addSubview:textLabel];
    }

    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

    textLabel.text = [NSString stringWithFormat:@"%@\n[%i, %i]", NSStringFromCGSize(cell.contentView.bounds.size),indexPath.section, indexPath.row];
    textLabel.backgroundColor = color;

    return cell;
}

@end
