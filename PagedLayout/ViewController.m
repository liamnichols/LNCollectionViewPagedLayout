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
    layout.pageContentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.startAllSectionsOnNewPage = YES;
    layout.minimumRowSpacing = 10.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerCell"];

    [self.view addSubview:self.collectionView];

#if DEBUG_LAYOUT
    self.view.backgroundColor = [UIColor redColor];
    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor greenColor];
#endif
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    u_int32_t i = 2 + arc4random() % 7;
    NSLog(@"%i sections", i);
    return i;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    u_int32_t i = 5 + arc4random() % 15;
    NSLog(@"%i rows in section %i",i, section);
    return i;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (collectionViewLayout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake((arc4random()%(600-100))+100, CGRectGetHeight(collectionView.bounds) - 20);
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 20, (arc4random()%(600-100))+100);
    }
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForFooterOnPage:(NSInteger)pageNumber
{
    switch (collectionViewLayout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(20, 200);
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake(200, 20);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LNCollectionViewPagedLayout *layout = (LNCollectionViewPagedLayout *)collectionView.collectionViewLayout;
    NSInteger pageNumber = [layout pageNumberForIndexPath:indexPath];
    NSInteger itemCount = [[layout indexPathsOnPage:pageNumber] count];

    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footerCell" forIndexPath:indexPath];

    NSInteger labelTag = 8;
    UILabel *label = (UILabel *)[view viewWithTag:labelTag];
    if (label == nil)
    {
        label = [UILabel new];

        label.backgroundColor = [UIColor whiteColor];
        label.frame = view.bounds;
        label.textAlignment = NSTextAlignmentCenter;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        label.tag = labelTag;
        [view addSubview:label];
    }

    label.text = [NSString stringWithFormat:@"Page: %i Item Count: %i",pageNumber,itemCount];

    return view;
}

@end
