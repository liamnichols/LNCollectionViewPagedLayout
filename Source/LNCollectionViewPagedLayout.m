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
    __block CGFloat pageHeight = CGRectGetHeight(self.collectionView.bounds);
    __block CGFloat currentPage = 0;
    __block CGFloat currentHeight = 0;
    __block CGFloat currentHeightOnPage = 10;

    [self enumerateIndexPaths:^(NSIndexPath *indexPath, BOOL isLast) {

        NSLog(@"Enumerating IndexPath: [%i, %i] isLast:%@",indexPath.section,indexPath.row,isLast ? @"YES" : @"NO");

        //Get the height of this cell
        CGSize itemSize = [self sizeForItemAtIndexPath:indexPath];

        //Assert if the item is too tall
        NSAssert(itemSize.height <= pageHeight,@"itemSize (%f) > pageHeight (%f)", itemSize,pageHeight);

        //Check if we need to start a new page...
        BOOL needNewPage = currentHeightOnPage + blockself.minimumRowSpacing + itemSize.height > pageHeight;

        //We would also need to start a new page if we are on a new section that wants to start fresh
        if (indexPath.section != 0 && indexPath.row == 0 && [self shouldStartSectionOnNewPage:indexPath.section] && needNewPage == NO)
            needNewPage = YES;

        //Start a new page if needed
        if (needNewPage)
        {
            //Increment the current page
            currentPage ++;

            //Reset the current heightOnPage
            currentHeightOnPage = 10;

            //Get the current height (of the whole content view)
            currentHeight = (pageHeight * currentPage);
        }

        //If height on page isn't 0, add some padding
        if (currentHeightOnPage != 0)
        {
            currentHeight += blockself.minimumRowSpacing;
        }

        //We now know where to put this item and how big it should be
        CGRect itemFrame = CGRectMake(CGRectGetWidth(blockself.collectionView.bounds)/2-itemSize.width/2, currentHeight, itemSize.width, itemSize.height);

        //Create our layout attributes for this item
        UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        //Set the frame on the attributes
        layoutAttributes.frame = itemFrame;

        //Add the attributes to our dictionary
        [self.itemAttributes setObject:layoutAttributes forKey:indexPath];

        //Calculate how much we need to move down for the next item
        CGFloat howMuchIveMoved = CGRectGetHeight(itemFrame);

        //Update the currentHeight to reflect how much i've moved
        currentHeight += howMuchIveMoved;

        //Update the currentHeightOnPage to reflect how much i've moved
        currentHeightOnPage += howMuchIveMoved;

        //If it is the last page, append the total height so it completes a page
        if (isLast)
        {
            blockself.totalHeight = currentHeight + (pageHeight - currentHeightOnPage);
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