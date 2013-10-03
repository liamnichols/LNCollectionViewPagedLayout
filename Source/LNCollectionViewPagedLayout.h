//
// Created by Liam Nichols on 06/08/2013.
// Copyright (c) 2013 Liam Nichols. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

/**
 * The LNCollectionViewPagedLayout class organises the items in the collection view so that they do not get cut off when the scroll view is configured for paging. This is achieved by placing an item onto a different page if it could not be fully displayed on the previous screen without cutting off content.
 *
 * A paged layout works by configuring a few basic properties or implementing the LNCollectionViewDelegatePagedLayout protocol on your collection view's delegate instance to determine the size of items and footers. Using the LNCollectionViewDelegatePagedLayout protocol you can dynamically size specific items instead of applying the same values to each individual item.
 *
 * Paged layouts ay out their content using a fixed distance in one direction and a scrollable distance in the other. For example, in a vertically scrolling table, the width of the content is constrained to the width of the corresponding collection view while the height of the content adjusts dynamically to match the number of pages required by the datasource. The layout is configured to scroll vertically by default but you can configure the scrolling direction using the scrollDirection property.
 *
 * Each section in a flow layout can have its own custom footer. To configure the footer for a page, you must configure the size of the footer to be something other than CGSizeZero. You can do this by implementing the appropriate delegate methods or by assigning appropriate values to the footerSize property. If the footer size is CGSizeZero, the corresponding view is not added to the collection view.
 *
 * Positioning of content on pages can be adjusted by assigning different values to the pageContentInset and minimumRowSpacing properties.
 */
@interface LNCollectionViewPagedLayout : UICollectionViewLayout



/**
 * @name Configuring the size of items
 */

/**
 * The size of each UICollectionViewCell if `collectionView:layout:sizeForItemAtIndexPath:` is not implemented.
 * Default value is CGSizeZero.
 */
@property (nonatomic) CGSize itemSize;

/**
 * The size of each footer if `collectionView:layout:sizeForFooterOnPage:` is not implemented.
 * Default value is CGSizeZero.
 */
@property (nonatomic) CGSize footerSize;



/**
 * @name Configuring the item spacing
 */

/**
 * The minimum space between rows.
 * Default value is 10.0.
 */
@property (nonatomic) CGFloat minimumRowSpacing;

/**
 * A Boolean flag that determines if a new section in the data source should start on a new page. This is only checked if `collectionView:layout:shouldStartSectionOnNewPage:` is not implemented.
 * Default value is NO.
 */
@property (nonatomic) BOOL startAllSectionsOnNewPage;

/**
 * The insets for content on each page.
 * Default value is UIEdgeInsetsZero.
 */
@property (nonatomic) UIEdgeInsets pageContentInset;




/**
 * @name Configuring the Scroll Direction
 */

/**
 * The scroll direction of the grid.
 */
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;




/**
 * @name Querying the computed layout
 */

/**
 * Queries the layout information to determine what page an indexPath is displayed on.
 *
 * @param indexPath The index path that you are checking.
 *
 * @return The page number that the specified indexPath is displayed on or NSNotFound if the indexPath could not be found in the layout.
 */
- (NSInteger)pageNumberForIndexPath:(NSIndexPath *)indexPath;

/**
 * Fetches a list of indexPaths that are displayed on a specified page.
 *
 * @param pageNumber The page number that you wish to get results for.
 *
 * @return An NSArray containing the NSIndexPath of each item present on that page or an empty array if no indexPaths where present.
 */
- (NSArray *)indexPathsOnPage:(NSInteger)pageNumber;

/**
 * Queries the layout for the total number of pages
 *
 * @return An NSInteger specifying how many pages there are in the collectionView
 */
- (NSInteger)numberOfPages;

@end


/**
 * The LNCollectionViewDelegatePagedLayout protocol defines methods that let you coordinate with a LNCollectionViewPagedLayout object to implement a paged layout. The methods of this protocol define the size of items and the spacing between item.
 *
 * All of the methods in this protocol are optional. If you do not implement a particular method, the paged layout uses values in its own properties for the appropriate spacing information instead.
 *
 * The paged layout object expects the collection view’s delegate object to adopt this protocol. Therefore, implement this protocol on object assigned to your collection view’s delegate property.
 */
@protocol LNCollectionViewDelegatePagedLayout <UICollectionViewDelegate>

@optional

/**
 * Asks the delegate for the size of a specific UICollectionViewCell.
 * If this method is not implemented by the delegate, the value will default to the itemSize property.
 *
 * @param collectionView The UICollectionView what is presenting the cell.
 * @param collectionViewLayout The LNCollectionViewPagedLayout what is positioning the cell.
 * @param indexPath The NSIndexPath of the cell that is being positioned.
 *
 * @return The size that the item should equal.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Asks the delegate if it should start a specific section on a new page or not.
 *
 * @param collectionView The UICollectionView what is presenting the cell.
 * @param collectionViewLayout The LNCollectionViewPagedLayout what is positioning the cell.
 * @param section The section that is being questioned by the LNCollectionViewPagedLayout.
 *
 * @return A Boolean value that indicates if the specified section should start on a new page or not.
 */
- (BOOL)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout shouldStartSectionOnNewPage:(NSInteger)section;

/**
 * Asks the delegate for the size of a specified footer view on a specific page.
 *
 * @param collectionView The UICollectionView what is presenting the cell.
 * @param collectionViewLayout The LNCollectionViewPagedLayout what is positioning the cell.
 * @param pageNumber The page number that the footer would be presented on.
 *
 * @return The size that the footer should equal. Returning CGSizeZero will disable presentation of a footer on that page.
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForFooterOnPage:(NSInteger)pageNumber;

/**
 * Notifies the delegate that all collectionView updates have been finalized.
 *
 * @param collectionView The UICollectionView that is having the updates applied.
 * @param collectionViewLayout The LNCollectionViewPagedLayout that has finalize the updates.
 */
- (void)collectionView:(UICollectionView *)collectionView didFinishPreparingLayout:(LNCollectionViewPagedLayout *)collectionViewLayout;

@end