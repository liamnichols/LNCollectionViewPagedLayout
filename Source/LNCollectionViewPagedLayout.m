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

@interface LNCollectionViewPagedLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic) CGFloat totalContentLength;
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;

@end

@implementation LNCollectionViewPagedLayout


#pragma mark - init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

#pragma mark - common setup / teardown

-(void)commonInit
{
    _minimumRowSpacing = 10.0f;
    _startAllSectionsOnNewPage = NO;
    _itemSize = CGSizeZero;
    _pageContentInset = UIEdgeInsetsZero;
    _scrollDirection = UICollectionViewScrollDirectionVertical;
}

-(void)dealloc
{
    [_itemAttributes removeAllObjects];
    _itemAttributes = nil;
}

#pragma mark - Invalidating Setters

- (void)setMinimumRowSpacing:(CGFloat)minimumRowSpacing
{
    if (_minimumRowSpacing != minimumRowSpacing)
    {
        _minimumRowSpacing = minimumRowSpacing;
        [self invalidateLayout];
    }
}

- (void)setStartAllSectionsOnNewPage:(BOOL)startAllSectionsOnNewPage
{
    if (_startAllSectionsOnNewPage != startAllSectionsOnNewPage)
    {
        _startAllSectionsOnNewPage = startAllSectionsOnNewPage;
        [self invalidateLayout];
    }
}

- (void)setPageContentInset:(UIEdgeInsets)pageContentInset
{
    if (UIEdgeInsetsEqualToEdgeInsets(_pageContentInset, pageContentInset) != YES)
    {
        _pageContentInset = pageContentInset;
        [self invalidateLayout];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    if (_scrollDirection != scrollDirection)
    {
        _scrollDirection = scrollDirection;
        [self invalidateLayout];
    }
}

#pragma mark - Getting Properties

- (BOOL)shouldStartSectionOnNewPage:(NSInteger)section
{
    id<LNCollectionViewDelegatePagedLayout> del = (id<LNCollectionViewDelegatePagedLayout>)self.collectionView.delegate;

    //Check if the delegate responds
    if ([del respondsToSelector:@selector(collectionView:layout:shouldStartSectionOnNewPage:)])
        return [del collectionView:self.collectionView layout:self shouldStartSectionOnNewPage:section];

    //If the delegate doesn't respond, get the default value for all sections
    return self.startAllSectionsOnNewPage;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<LNCollectionViewDelegatePagedLayout> del = (id<LNCollectionViewDelegatePagedLayout>)self.collectionView.delegate;

    //Check if the delegate responds
    if ([del respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
        return [del collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];

    //If the delegate doesn't respond, get the default value for all items
    return self.itemSize;
}

#pragma mark - creating the layout

- (void)prepareLayout
{
    [self.itemAttributes removeAllObjects];

    self.itemCount = [self getTotalItemCount];

    self.itemAttributes = [NSMutableDictionary dictionaryWithCapacity:self.itemCount];

    __block LNCollectionViewPagedLayout *blockself = self;
    __block CGRect pageRect = UIEdgeInsetsInsetRect(blockself.collectionView.bounds, self.pageContentInset);
    __block CGFloat currentPage = 0;
    __block CGFloat currentOffset = RELEVANT_INSET(self.pageContentInset);

    [self enumerateIndexPaths:^(NSIndexPath *indexPath, BOOL isLast) {

        //Get the size of this cell
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];

        //Assert if the item is too tall
        NSAssert(itemSize.height <= CGRectGetHeight(pageRect),@"Cell must not exceed the page size");
        //Assert if the item is too wide
        NSAssert(itemSize.width <= CGRectGetWidth(pageRect),@"Cell must not exceed the page size");

        //Get the current offset before adding this cell
        CGFloat currentOffsetOnThisPageBeforeThisCell = currentOffset - (RELEVANT_DIMENSION(blockself.collectionView.bounds) * currentPage);

        //Get the spacing to place above this cell (if needed)
        CGFloat spacingAboveThisCell = currentOffsetOnThisPageBeforeThisCell == RELEVANT_INSET(blockself.pageContentInset) ? 0 : blockself.minimumRowSpacing;

        //Get the offset after adding this cell
        CGFloat offsetOnThisPageAfterThisCell = currentOffsetOnThisPageBeforeThisCell + spacingAboveThisCell + RELEVANT_SIZE(itemSize);

        //Check if this would lap over onto a new page
        BOOL wouldNeedNewPage = offsetOnThisPageAfterThisCell > (RELEVANT_INSET(blockself.pageContentInset) + RELEVANT_DIMENSION(pageRect));

        //Check if a new page is going to be forced
        if (indexPath.section != 0 && indexPath.row == 0 && [blockself shouldStartSectionOnNewPage:indexPath.section])
            wouldNeedNewPage = YES;

        //If we do want a new page, move to it.
        if (wouldNeedNewPage)
        {
            currentPage ++;
            currentOffset = RELEVANT_DIMENSION(blockself.collectionView.bounds) * currentPage + RELEVANT_POINT(pageRect);
        }

        CGRect cellRect = CGRectZero;

        //Detect if we are at the top of a page
        BOOL isAtTheStartOfAPage = currentOffset == RELEVANT_DIMENSION(blockself.collectionView.bounds) * currentPage + RELEVANT_POINT(pageRect);

        //Get the offset for this cell
        CGFloat offsetForCell = isAtTheStartOfAPage ? currentOffset : currentOffset + blockself.minimumRowSpacing;

        switch (blockself.scrollDirection)
        {
            case UICollectionViewScrollDirectionVertical:
            {
                //Get the x of this cell
                CGFloat x = CGRectGetWidth(blockself.collectionView.bounds)/2 - itemSize.width/2;

                //Update the cell rect
                cellRect.size = itemSize;
                cellRect.origin.y = offsetForCell;
                cellRect.origin.x = x;
                break;
            }
            case UICollectionViewScrollDirectionHorizontal:
            {
                //Get the y of this cell
                CGFloat y = CGRectGetHeight(blockself.collectionView.bounds)/2 - itemSize.height/2;

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
        [self.itemAttributes setObject:layoutAttributes forKey:indexPath];


        if (isLast)
        {

            CGFloat n = RELEVANT_DIMENSION(blockself.collectionView.bounds);
            CGFloat x = currentOffset;
            blockself.totalContentLength =  ceilf(x / n) * n;
        }

    }];
}

- (CGFloat)getRelevantPoint:(CGRect)rect
{
    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionVertical:
            return CGRectGetMinY(rect);

        case UICollectionViewScrollDirectionHorizontal:
            return CGRectGetMinX(rect);
    }
}

- (CGFloat)getRelevantDimension:(CGRect)rect
{
    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionVertical:
            return CGRectGetHeight(rect);

        case UICollectionViewScrollDirectionHorizontal:
            return CGRectGetWidth(rect);
    }    
}


- (CGFloat)getRelevantSize:(CGSize)size
{
    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionVertical:
            return size.height;

        case UICollectionViewScrollDirectionHorizontal:
            return size.width;
    }    
}

- (CGFloat)getRelevantInset:(UIEdgeInsets)inset
{
    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionVertical:
            return inset.top;

        case UICollectionViewScrollDirectionHorizontal:
            return inset.left;   
    }   
}

- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeZero;

    switch (self.scrollDirection)
    {
        case UICollectionViewScrollDirectionVertical:
        {
            size.width = CGRectGetWidth(self.collectionView.bounds);
            size.height = self.totalContentLength;
            break;
        }

        case UICollectionViewScrollDirectionHorizontal:
        {
            size.width = self.totalContentLength;
            size.height = CGRectGetHeight(self.collectionView.bounds);
            break;
        }
    }

    return size;
}

-(void)enumerateIndexPaths:(void(^)(NSIndexPath *indexPath, BOOL isLast))block
{
    NSInteger ls = [self.collectionView numberOfSections] - 1;
    for (NSInteger s = 0; s <= ls; s++)
    {
        NSInteger lr = [self.collectionView numberOfItemsInSection:s] - 1;
        for (NSInteger r = 0; r <= lr; r++)
        {
            if (block)
            {
                BOOL last = (s == ls && r == lr);
                block([NSIndexPath indexPathForRow:r inSection:s], last);
            }
        }
    }
}

- (NSInteger)getTotalItemCount
{
    NSInteger count = 0;
    for (NSInteger i = 0; i < [self.collectionView numberOfSections]; i++)
    {
        count += [self.collectionView numberOfItemsInSection:i];
    }
    return count;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemAttributes[indexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [[self.itemAttributes allValues] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, [evaluatedObject frame]);
    }]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return NO;
}

@end