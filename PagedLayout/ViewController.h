//
//  ViewController.h
//  PagedLayout
//
//  Created by Liam Nichols on 06/08/2013.
//  Copyright (c) 2013 Liam Nichols. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNCollectionViewPagedLayout.h"

@interface ViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, LNCollectionViewDelegatePagedLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end
