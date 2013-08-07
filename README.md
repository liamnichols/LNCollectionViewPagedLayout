LNCollectionViewPagedLayout
===========================

`UICollectionViewLayout` subclass that separates cells onto different pages if they are unable to fit on a single page.  

Requirements
---
- iOS 6  
- ARC  

Features
---
- Bidirectional scrolling configurations by using the `scrollDirection` property.  
- Adjustable content insets for the page by using the `pageContentInset` property.  
- Adjustable spacing between cells by using the `minimumRowSpacing` property.  
- Multiple section support.  
- Ability to start new sections on the next page by using the `startAllSectionsOnNewPage` property or implementing the `LNCollectionViewDelegatePagedLayout` protocol.

Usage
---
See the header and demo for usage.

	@interface LNCollectionViewPagedLayout : UICollectionViewLayout
	
	///The size of the cells
	///The default value is CGSizeZero.
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
	
	///The scroll direction of the collectionView
	///The default value is UICollectionViewScrollDirectionVertical
	@property (nonatomic) UICollectionViewScrollDirection scrollDirection;
	
	@end
	
	
	@protocol LNCollectionViewDelegatePagedLayout <UICollectionViewDelegate>
	
	@optional
	
	///Retrieve the size of a cell at a specified indexPath
	- (CGSize)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
	
	///Start a specified section on a new page rather than underneath an old section
	- (BOOL)collectionView:(UICollectionView *)collectionView layout:(LNCollectionViewPagedLayout *)collectionViewLayout shouldStartSectionOnNewPage:(NSInteger)section;
	
	@end


TODO
---  
- Add the option to place a footer view at the bottom of each/specific page(s).  
- Add to cocoapods.  
