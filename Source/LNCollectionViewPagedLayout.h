//
// Created by Liam Nichols on 06/08/2013.
// Copyright (c) 2013 Liam Nichols. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface LNCollectionViewPagedLayout : UICollectionViewLayout

///The size of the cells
///The default value is { 10, 10 }.
@property (nonatomic) CGSize itemSize;

///The minimum space between each cell
///The default value is 10.0.
@property (nonatomic) CGFloat minimumRowSpacing;

///When set to YES, the first row of a section will appear on a new page.
///The default value is NO.
@property (nonatomic) BOOL startAllSectionsOnNewPage;

///The insets for the content of each page
///The default value is UIEdgeInsetsZero
@property (nonatomic) UIEdgeInsets pageContentInset;

@end


@protocol LNCollectionViewDelegatePagedLayout <UICollectionViewDelegate>

@optional

///Retrieve the size of a cell at a specified indexPath
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

///Start a specified section on a new page rather than underneath an old section
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout shouldStartSectionOnNewPage:(NSInteger)section;

@end