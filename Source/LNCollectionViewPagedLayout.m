//
// Created by Liam Nichols on 06/08/2013.
// Copyright (c) 2013 Liam Nichols. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LNCollectionViewPagedLayout.h"

@interface LNCollectionViewPagedLayout ()

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic) CGFloat totalHeight;
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
    _itemSize = CGSizeMake(10, 10);
    _pageContentInset = UIEdgeInsetsZero;
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
    __block CGFloat currentOffset = self.pageContentInset.top;

    [self enumerateIndexPaths:^(NSIndexPath *indexPath, BOOL isLast) {

        //Get the size of this cell
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];

        //Assert if the item is too tall
        NSAssert(itemSize.height <= CGRectGetHeight(pageRect),@"Cell must not exceed the page size");
        //Assert if the item is too wide
        NSAssert(itemSize.width <= CGRectGetWidth(pageRect),@"Cell must not exceed the page size");

        //Get the current offset before adding this cell
        CGFloat currentOffsetOnThisPageBeforeThisCell = currentOffset - (CGRectGetHeight(blockself.collectionView.bounds) * currentPage);

        //Get the spacing to place above this cell (if needed)
        CGFloat spacingAboveThisCell = currentOffsetOnThisPageBeforeThisCell == blockself.pageContentInset.top ? 0 : blockself.minimumRowSpacing;

        //Get the offset after adding this cell
        CGFloat offsetOnThisPageAfterThisCell = currentOffsetOnThisPageBeforeThisCell + spacingAboveThisCell + itemSize.height;

        //Check if this would lap over onto a new page
        BOOL wouldNeedNewPage = offsetOnThisPageAfterThisCell > (blockself.pageContentInset.top + CGRectGetHeight(pageRect));

        //Check if a new page is going to be forced
        if (indexPath.section != 0 && indexPath.row == 0 && [blockself shouldStartSectionOnNewPage:indexPath.section])
            wouldNeedNewPage = YES;

        //If we do want a new page, move to it.
        if (wouldNeedNewPage)
        {
            currentPage ++;
            currentOffset = CGRectGetHeight(blockself.collectionView.bounds) * currentPage + CGRectGetMinY(pageRect);
        }

        CGRect cellRect = CGRectZero;

        //Detect if we are at the top of a page
        BOOL isAtTheStartOfAPage = currentOffset == CGRectGetHeight(blockself.collectionView.bounds) * currentPage + CGRectGetMinY(pageRect);

        //Get the offset for this cell
        CGFloat offsetForCell = isAtTheStartOfAPage ? currentOffset : currentOffset + blockself.minimumRowSpacing;

        //Get the x of this cell
        CGFloat x = CGRectGetWidth(blockself.collectionView.bounds)/2 - itemSize.width/2;

        //Update the cell rect
        cellRect.size = itemSize;
        cellRect.origin.y = offsetForCell;
        cellRect.origin.x = x;

        //Update the current offset
        currentOffset = offsetForCell + cellRect.size.height;

        //Create our layout attributes for this item
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        //Set the frame on the attributes
        layoutAttributes.frame = cellRect;

        //Add the attributes to our dictionary
        [self.itemAttributes setObject:layoutAttributes forKey:indexPath];


        if (isLast)
        {

            CGFloat n = CGRectGetHeight(blockself.collectionView.bounds);
            CGFloat x = currentOffset;
            blockself.totalHeight =  ceilf(x / n) * n;
        }

    }];
}

- (CGSize)collectionViewContentSize
{
    CGSize size = CGSizeZero;

    size.width = CGRectGetWidth(self.collectionView.bounds);
    size.height = self.totalHeight;

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