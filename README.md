LNCollectionViewPagedLayout
===========================

The LNCollectionViewPagedLayout class organises the items in the collection view so that they do not get cut off when the scroll view is configured for paging. This is achieved by placing an item onto a different page if it could not be fully displayed on the previous screen without cutting off content.

A paged layout works by configuring a few basic properties or implementing the LNCollectionViewDelegatePagedLayout protocol on your collection view’s delegate instance to determine the size of items and footers. Using the LNCollectionViewDelegatePagedLayout protocol you can dynamically size specific items instead of applying the same values to each individual item.

Paged layouts ay out their content using a fixed distance in one direction and a scrollable distance in the other. For example, in a vertically scrolling table, the width of the content is constrained to the width of the corresponding collection view while the height of the content adjusts dynamically to match the number of pages required by the datasource. The layout is configured to scroll vertically by default but you can configure the scrolling direction using the scrollDirection property.

Each section in a flow layout can have its own custom footer. To configure the footer for a page, you must configure the size of the footer to be something other than CGSizeZero. You can do this by implementing the appropriate delegate methods or by assigning appropriate values to the footerSize property. If the footer size is CGSizeZero, the corresponding view is not added to the collection view.

Positioning of content on pages can be adjusted by assigning different values to the pageContentInset and minimumRowSpacing properties.


Requirements
---
- iOS 6  
- ARC  

Preview
---
![](https://raw.github.com/liamnichols/LNCollectionViewPagedLayout/master/example.gif)

Usage
---
**Creating an instance of LNCollectionViewPagedLayout with basic configuration:**

    LNCollectionViewPagedLayout *layout = [[LNCollectionViewPagedLayout alloc] init];
    layout.pageContentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.startAllSectionsOnNewPage = YES;
    layout.minimumRowSpacing = 10.0f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];

See the demo application for more advanced usage.

TODO
---   
- Add to cocoapods.  
