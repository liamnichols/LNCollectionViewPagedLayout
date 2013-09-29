//
// Created by Liam Nichols on 06/08/2013.
// Copyright (c) 2013 Liam Nichols. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LNCollectionViewPagedLayout.h"

#define RELEVANT_DIMENSION(rect) [blockself getRelevantDimension:rect]
#define RELEVANT_SIZE(size) [blockself getRelevantSize:size]
#define RELEVANT_POINT(rect) [blockself getRelevantPoint:rect]
#define RELEVANT_INSET(insets) [blockself getRelevantInset:insets]
#define RELEVANT_END_INSET(insets) [blockself getRelevantEndInset:insets]

@interface LNCollectionViewPagedLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic) CGFloat totalContentLength;
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableDictionary *footerAttributes;
@property (nonatomic, strong) NSMutableDictionary *pageNumberLookupDictionary;

@end

@implementation LNCollectionViewPagedLayout


#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

#pragma mark - common setup / teardown

- (void)commonInit {
    _minimumRowSpacing = 10.0f;
    _startAllSectionsOnNewPage = NO;
    _itemSize = CGSizeZero;
    _footerSize = CGSizeZero;
    _pageContentInset = UIEdgeInsetsZero;
    _scrollDirection = UICollectionViewScrollDirectionVertical;
}

- (void)dealloc {
    [_itemAttributes removeAllObjects];
    _itemAttributes = nil;

    [_footerAttributes removeAllObjects];
    _footerAttributes = nil;

    [_pageNumberLookupDictionary removeAllObjects];
    _pageNumberLookupDictionary = nil;
}

#pragma mark - Invalidating Setters

- (void)setMinimumRowSpacing:(CGFloat)minimumRowSpacing {
    if (_minimumRowSpacing != minimumRowSpacing) {
        _minimumRowSpacing = minimumRowSpacing;
        [self invalidateLayout];
    }
}

- (void)setStartAllSectionsOnNewPage:(BOOL)startAllSectionsOnNewPage {
    if (_startAllSectionsOnNewPage != startAllSectionsOnNewPage) {
        _startAllSectionsOnNewPage = startAllSectionsOnNewPage;
        [self invalidateLayout];
    }
}

- (void)setPageContentInset:(UIEdgeInsets)pageContentInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_pageContentInset, pageContentInset) != YES) {
        _pageContentInset = pageContentInset;
        [self invalidateLayout];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        [self invalidateLayout];
    }
}

- (void)setItemSize:(CGSize)itemSize {
    if (CGSizeEqualToSize(_itemSize, itemSize) != YES) {
        _itemSize = itemSize;
        [self invalidateLayout];
    }
}

- (void)setFooterSize:(CGSize)footerSize {
    if (CGSizeEqualToSize(_footerSize, footerSize) != YES) {
        _footerSize = footerSize;
        [self invalidateLayout];
    }
}

#pragma mark - Getting Properties

- (BOOL)shouldStartSectionOnNewPage:(NSInteger)section {
    id <LNCollectionViewDelegatePagedLayout> del = (id <LNCollectionViewDelegatePagedLayout>) self.collectionView.delegate;

    //Check if the delegate responds
    if ([del respondsToSelector:@selector(collectionView:layout:shouldStartSectionOnNewPage:)])
        return [del collectionView:self.collectionView layout:self shouldStartSectionOnNewPage:section];

    //If the delegate doesn't respond, get the default value for all sections
    return self.startAllSectionsOnNewPage;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id <LNCollectionViewDelegatePagedLayout> del = (id <LNCollectionViewDelegatePagedLayout>) self.collectionView.delegate;

    //Check if the delegate responds
    if ([del respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
        return [del collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];

    //If the delegate doesn't respond, get the default value for all items
    return self.itemSize;
}

- (CGSize)sizeForFooterOnPage:(NSInteger)pageNumber {
    id <LNCollectionViewDelegatePagedLayout> del = (id <LNCollectionViewDelegatePagedLayout>) self.collectionView.delegate;

    if ([del respondsToSelector:@selector(collectionView:layout:sizeForFooterOnPage:)]) {
        return [del collectionView:self.collectionView layout:self sizeForFooterOnPage:pageNumber];
    }
    return self.footerSize;
}

#pragma mark - creating the layout

- (void)prepareLayout {
    [self.itemAttributes removeAllObjects];
    [self.footerAttributes removeAllObjects];
    [self.pageNumberLookupDictionary removeAllObjects];

    self.itemCount = [self getTotalItemCount];

    self.itemAttributes = [NSMutableDictionary dictionaryWithCapacity:self.itemCount];

    self.pageNumberLookupDictionary = [NSMutableDictionary dictionaryWithCapacity:self.itemCount];

    self.footerAttributes = [NSMutableDictionary new];

    //Using the bounds to get the pageRect was not stable as the origin is not always CGPointZero.
    __block LNCollectionViewPagedLayout *blockself = self;
    CGRect zeroOriginBounds = (CGRect) {.origin = CGPointZero, .size = blockself.collectionView.frame.size};
    __block CGRect pageRect = UIEdgeInsetsInsetRect(zeroOriginBounds, self.pageContentInset);
    __block NSInteger currentPage = 0;
    __block CGFloat currentOffset = RELEVANT_INSET(self.pageContentInset);

    __block void(^addFooterToPage)(CGFloat startOffset, CGSize footerSize) = ^(CGFloat startOffset, CGSize footerSize) {

        //Get the footer rect
        CGRect footerRect = CGRectZero;

        //Get the offset for the footer
        CGFloat offsetForFooter = startOffset + (RELEVANT_INSET(blockself.pageContentInset) + (RELEVANT_DIMENSION(pageRect) - RELEVANT_SIZE(footerSize)));

        //Apply the footer
        switch (blockself.scrollDirection) {
            case UICollectionViewScrollDirectionVertical: {
                if (footerSize.width == 0)
                    footerSize.width = CGRectGetWidth(pageRect);

                //Get the x of this footer
                CGFloat x = CGRectGetWidth(blockself.collectionView.frame) / 2 - footerSize.width / 2;

                //Update the cell rect
                footerRect.size = footerSize;
                footerRect.origin.y = offsetForFooter;
                footerRect.origin.x = x;
                break;
            }
            case UICollectionViewScrollDirectionHorizontal: {
                if (footerSize.height == 0)
                    footerSize.height = CGRectGetHeight(pageRect);

                //Get the y of this footer
                CGFloat y = CGRectGetHeight(blockself.collectionView.frame) / 2 - footerSize.height / 2;

                //Update the cell rect
                footerRect.size = footerSize;
                footerRect.origin.y = y;
                footerRect.origin.x = offsetForFooter;
                break;
            }
        }

        //Create our layout attributes for this footer
//        NSIndexPath *footerIndexPath = [[self.pageNumberLookupDictionary allKeysForObject:@(currentPage)] lastObject];
        NSIndexPath *footerIndexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
        UICollectionViewLayoutAttributes *footerLayoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];

        //Set the frame on the attributes
        footerLayoutAttributes.frame = footerRect;

        //Add the attributes to our dictionary
        [blockself.footerAttributes setObject:footerLayoutAttributes forKey:footerIndexPath];

    };

    [self enumerateIndexPaths:^(NSIndexPath *indexPath, BOOL isLast) {

        //Get the size of this cell
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];

        if (self.collectionView.pagingEnabled)
        {
            //Assert if the item is too tall
            NSAssert(itemSize.height <= CGRectGetHeight(pageRect), @"Cell must not exceed the page size");
            //Assert if the item is too wide
            NSAssert(itemSize.width <= CGRectGetWidth(pageRect), @"Cell must not exceed the page size");

            //Get the offset for the start of this page
            CGFloat startOffsetForThisPage = (RELEVANT_DIMENSION(blockself.collectionView.frame) * currentPage);

            //Get the current offset before adding this cell
            CGFloat currentOffsetOnThisPageBeforeThisCell = currentOffset - startOffsetForThisPage;

            //Get the spacing to place above this cell (if needed)
            CGFloat spacingAboveThisCell = currentOffsetOnThisPageBeforeThisCell == RELEVANT_INSET(blockself.pageContentInset) ? 0 : blockself.minimumRowSpacing;

            //Get the offset after adding this cell
            CGFloat offsetOnThisPageAfterThisCell = currentOffsetOnThisPageBeforeThisCell + spacingAboveThisCell + RELEVANT_SIZE(itemSize);

            //Get the size of the footer for this page
            CGSize footerSizeForThisPage = [self sizeForFooterOnPage:currentPage];

            //Check if this would lap over onto a new page
            BOOL wouldNeedNewPage = (offsetOnThisPageAfterThisCell - spacingAboveThisCell) > (RELEVANT_INSET(blockself.pageContentInset) + (RELEVANT_DIMENSION(pageRect) - (RELEVANT_SIZE(footerSizeForThisPage) + RELEVANT_END_INSET(blockself.pageContentInset))));

            //Check if a new page is going to be forced
            if (indexPath.section != 0 && indexPath.row == 0 && [blockself shouldStartSectionOnNewPage:indexPath.section])
                wouldNeedNewPage = YES;

            //If we do want a new page, move to it.
            if (wouldNeedNewPage) {
                if (!CGSizeEqualToSize(CGSizeZero, footerSizeForThisPage)) {
                    addFooterToPage(startOffsetForThisPage, footerSizeForThisPage);
                }

                //Update the global variables for a new page
                currentPage++;
                currentOffset = RELEVANT_DIMENSION(blockself.collectionView.frame) * currentPage + RELEVANT_POINT(pageRect);
            }

            CGRect cellRect = CGRectZero;

            //Detect if we are at the top of a page
            BOOL isAtTheStartOfAPage = currentOffset == RELEVANT_DIMENSION(blockself.collectionView.frame) * currentPage + RELEVANT_POINT(pageRect);

            //Get the offset for this cell
            CGFloat offsetForCell = isAtTheStartOfAPage ? currentOffset : currentOffset + blockself.minimumRowSpacing;

            switch (blockself.scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    if (itemSize.width == 0)
                        itemSize.width = CGRectGetWidth(pageRect);

                    //Get the x of this cell
                    CGFloat x = CGRectGetWidth(blockself.collectionView.frame) / 2 - itemSize.width / 2;

                    //Update the cell rect
                    cellRect.size = itemSize;
                    cellRect.origin.y = offsetForCell;
                    cellRect.origin.x = x;
                    break;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    if (itemSize.height == 0)
                        itemSize.height = CGRectGetHeight(pageRect);

                    //Get the y of this cell
                    CGFloat y = CGRectGetHeight(blockself.collectionView.frame) / 2 - itemSize.height / 2;

                    //Update the cell rect
                    cellRect.size = itemSize;
                    cellRect.origin.y = y;
                    cellRect.origin.x = offsetForCell;
                    break;
                }
            }

            //Update the current offset
            currentOffset = offsetForCell + RELEVANT_SIZE(cellRect.size);

            //Create our layout attributes for this item
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            //Set the frame on the attributes
            layoutAttributes.frame = cellRect;

            //Add the attributes to our dictionary
            [blockself.itemAttributes setObject:layoutAttributes forKey:indexPath];

            //Update the pageNumberFoIndexPathLookup
            blockself.pageNumberLookupDictionary[indexPath] = @(currentPage);

            if (isLast) {
                CGFloat n = RELEVANT_DIMENSION(blockself.collectionView.frame);
                CGFloat x = currentOffset;
                blockself.totalContentLength = ceilf(x / n) * n;

                CGFloat currentOffsetForFinalPage = blockself.totalContentLength - n;

                footerSizeForThisPage = [self sizeForFooterOnPage:currentPage];
                if (!CGSizeEqualToSize(CGSizeZero, footerSizeForThisPage)) {
                    addFooterToPage(currentOffsetForFinalPage, footerSizeForThisPage);
                }
            }
        }
        else
        {
            CGRect cellRect = CGRectZero;

            switch (blockself.scrollDirection) {
                case UICollectionViewScrollDirectionVertical: {
                    if (itemSize.width == 0)
                        itemSize.width = CGRectGetWidth(pageRect);

                    //Get the x of this cell
                    CGFloat x = CGRectGetWidth(blockself.collectionView.frame) / 2 - itemSize.width / 2;

                    //Update the cell rect
                    cellRect.size = itemSize;
                    cellRect.origin.y = currentOffset;
                    cellRect.origin.x = x;
                    break;
                }
                case UICollectionViewScrollDirectionHorizontal: {
                    if (itemSize.height == 0)
                        itemSize.height = CGRectGetHeight(pageRect);

                    //Get the y of this cell
                    CGFloat y = CGRectGetHeight(blockself.collectionView.frame) / 2 - itemSize.height / 2;

                    //Update the cell rect
                    cellRect.size = itemSize;
                    cellRect.origin.y = y;
                    cellRect.origin.x = currentOffset;
                    break;
                }
            }

            //Create our layout attributes for this item
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

            //Set the frame on the attributes
            layoutAttributes.frame = cellRect;

            //Add the attributes to our dictionary
            [blockself.itemAttributes setObject:layoutAttributes forKey:indexPath];

            if (isLast)
            {
                //Update the current offset
                currentOffset = currentOffset + RELEVANT_SIZE(cellRect.size) + RELEVANT_END_INSET(blockself.pageContentInset);

                //set the totalContentLength
                blockself.totalContentLength = currentOffset;
            }
            else
            {
                //Update the current offset
                currentOffset = currentOffset + RELEVANT_SIZE(cellRect.size) + blockself.minimumRowSpacing;
            }
        }
    }];

}

- (CGFloat)getRelevantPoint:(CGRect)rect {
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            return CGRectGetMinY(rect);

        case UICollectionViewScrollDirectionHorizontal:
            return CGRectGetMinX(rect);
    }
}

- (CGFloat)getRelevantDimension:(CGRect)rect {
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            return CGRectGetHeight(rect);

        case UICollectionViewScrollDirectionHorizontal:
            return CGRectGetWidth(rect);
    }
}


- (CGFloat)getRelevantSize:(CGSize)size {
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            return size.height;

        case UICollectionViewScrollDirectionHorizontal:
            return size.width;
    }
}

- (CGFloat)getRelevantInset:(UIEdgeInsets)inset {
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            return inset.top;

        case UICollectionViewScrollDirectionHorizontal:
            return inset.left;
    }
}

- (CGFloat)getRelevantEndInset:(UIEdgeInsets)inset {
    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical:
            return inset.bottom;

        case UICollectionViewScrollDirectionHorizontal:
            return inset.right;
    }
}

- (CGSize)collectionViewContentSize {
    CGSize size = CGSizeZero;

    switch (self.scrollDirection) {
        case UICollectionViewScrollDirectionVertical: {
            size.width = CGRectGetWidth(self.collectionView.bounds);
            size.height = self.totalContentLength;
            break;
        }

        case UICollectionViewScrollDirectionHorizontal: {
            size.width = self.totalContentLength;
            size.height = CGRectGetHeight(self.collectionView.bounds);
            break;
        }
    }

    return size;
}

- (void)enumerateIndexPaths:(void (^)(NSIndexPath *indexPath, BOOL isLast))block {
    NSInteger total = [self getTotalItemCount];
    NSInteger current = 1;

    NSInteger ls = [self.collectionView numberOfSections] - 1;
    for (NSInteger s = 0; s <= ls; s++) {
        NSInteger lr = [self.collectionView numberOfItemsInSection:s] - 1;
        for (NSInteger r = 0; r <= lr; r++) {
            if (block) {
                BOOL last = (current == total);
                block([NSIndexPath indexPathForRow:r inSection:s], last);
            }
            current++;
        }
    }
}

- (NSInteger)getTotalItemCount {
    NSInteger count = 0;
    for (NSInteger i = 0; i < [self.collectionView numberOfSections]; i++) {
        count += [self.collectionView numberOfItemsInSection:i];
    }
    return count;
}

#pragma mark - Layout Attributes

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _itemAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return _footerAttributes[indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray new];

    [attributes addObjectsFromArray:[[self.itemAttributes allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]]];

    [attributes addObjectsFromArray:[[self.footerAttributes allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]]];

    return [NSArray arrayWithArray:attributes];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

#pragma mark - Querying layout information

- (NSInteger)pageNumberForIndexPath:(NSIndexPath *)indexPath {
    NSNumber *num = self.pageNumberLookupDictionary[indexPath];

    if (num != nil)
        return num.integerValue;

    return NSNotFound;
}

- (NSArray *)indexPathsOnPage:(NSInteger)pageNumber {
    return [self.pageNumberLookupDictionary allKeysForObject:@(pageNumber)];
}

- (NSInteger)numberOfPages {
    return [[[self.pageNumberLookupDictionary allValues] valueForKeyPath:@"@max.intValue"] integerValue] + 1;
}

@end