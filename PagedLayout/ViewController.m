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
    return [[self datasource] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[[self datasource] objectAtIndex:section] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat n = [[[[self datasource] objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] floatValue];

    switch (collectionViewLayout.scrollDirection)
    {
        case UICollectionViewScrollDirectionHorizontal:
            return CGSizeMake(n, CGRectGetHeight(collectionView.bounds) - 20);
        case UICollectionViewScrollDirectionVertical:
            return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 20, n);
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //animations do not currently work property.. reloadData however works fine for now.
//    //Reload the item (will calculate a new random size)
//    [[[self datasource] objectAtIndex:indexPath.section] setObject:@100 atIndex:indexPath.row];
//
//    NSArray *paths = @[indexPath];
//    [collectionView reloadItemsAtIndexPaths:paths];
}

-(NSMutableArray *)datasource
{
    static NSMutableArray *datasource = nil;
    if (datasource == nil)
    {
        datasource = [NSMutableArray new];

        NSMutableArray *section1 = [NSMutableArray new];
        [section1 addObject:@50];
        [section1 addObject:@60];
        [section1 addObject:@70];
        [section1 addObject:@50];
        [section1 addObject:@70];
        [section1 addObject:@40];
        [section1 addObject:@60];

        NSMutableArray *section2 = [NSMutableArray new];
        [section2 addObject:@60];
        [section2 addObject:@50];
        [section2 addObject:@60];
        [section2 addObject:@60];
        [section2 addObject:@70];
        [section2 addObject:@60];
        [section2 addObject:@70];

        [datasource addObject:section1];
        [datasource addObject:section2];
    }
    return datasource;
}

@end
