//
//  AGIPCAssetsController.m
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import "AGIPCAssetsController.h"

#import "AGImagePickerController+Helper.h"
#import "MJPhotoBrowser.h"

#import "AGIPCGridCell.h"
#import "AGIPCToolbarItem.h"
#import "MJPhoto.h"

@interface AGIPCAssetsController ()
{
    ALAssetsGroup *_assetsGroup;
    NSMutableArray *_assets;
    AGImagePickerController *_imagePickerController;
}

@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UIButton* buttonItem_done;
@property (nonatomic, strong) UIButton* buttonItem_preview;
@property (nonatomic, strong) UIView* bottomViewBar;
@property (nonatomic, strong) UITableView* tableView;

@end

@interface AGIPCAssetsController (Private)

- (void)changeSelectionInformation;

- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (void)didChangeLibrary:(NSNotification *)notification;
- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification;

- (BOOL)toolbarHidden;

- (void)loadAssets;
- (void)reloadData;

- (void)setupToolbarItems;

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)doneAction:(id)sender;
- (void)selectAllAction:(id)sender;
- (void)deselectAllAction:(id)sender;
- (void)customBarButtonItemAction:(id)sender;

- (void)loadCameraRollWhenAssetsIsNil;
@end

@implementation AGIPCAssetsController

#pragma mark - Properties

@synthesize assetsGroup = _assetsGroup, assets = _assets, imagePickerController = _imagePickerController;

- (BOOL)toolbarHidden
{
    return NO;
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
    @synchronized (self)
    {
        if (_assetsGroup != theAssetsGroup)
        {
            _assetsGroup = theAssetsGroup;
            [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];

            [self reloadData];
        }
    }
}

- (ALAssetsGroup *)assetsGroup
{
    ALAssetsGroup *ret = nil;
    
    @synchronized (self)
    {
        ret = _assetsGroup;
    }
    
    return ret;
}

- (NSArray *)selectedAssets
{
    NSMutableArray *selectedAssets = [NSMutableArray array];
    
	for (AGIPCGridItem *gridItem in self.assets) 
    {		
		if (gridItem.selected)
        {	
			[selectedAssets addObject:gridItem.asset];
		}
	}
    
    return selectedAssets;
}

#pragma mark - Object Lifecycle

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController andAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    self = [super init];
    if (self)
    {
        _assets = [[NSMutableArray alloc] init];
        self.assetsGroup = assetsGroup;
        self.imagePickerController = imagePickerController;
        self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Loading", nil, [NSBundle mainBundle], @"Loading...", nil);
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        
        // Start loading the assets
        [self loadAssets];
    }
    
    return self;
}

- (void)dealloc
{
    [self unregisterFromNotifications];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (! self.imagePickerController) return 0;
    
    double numberOfAssets = (double)self.assetsGroup.numberOfAssets;
    NSInteger nr = ceil(numberOfAssets / self.imagePickerController.numberOfItemsPerRow);
    
    return nr;
}

- (NSArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.imagePickerController.numberOfItemsPerRow];
    
    NSUInteger startIndex = indexPath.row * self.imagePickerController.numberOfItemsPerRow, 
                 endIndex = startIndex + self.imagePickerController.numberOfItemsPerRow - 1;
    if (startIndex < self.assets.count)
    {
        if (endIndex > self.assets.count - 1)
            endIndex = self.assets.count - 1;
        
        for (NSUInteger i = startIndex; i <= endIndex; i++)
        {
            [items addObject:(self.assets)[i]];
        }
    }
    
    return items;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    AGIPCGridCell *cell = (AGIPCGridCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {		        
        cell = [[AGIPCGridCell alloc] initWithImagePickerController:self.imagePickerController items:[self itemsForRowAtIndexPath:indexPath] andReuseIdentifier:CellIdentifier];
    }	
	else 
    {		
		cell.items = [self itemsForRowAtIndexPath:indexPath];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect itemRect = self.imagePickerController.itemRect;
    return itemRect.size.height + itemRect.origin.y;
}

#pragma mark - View Lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Reset the number of selections
    [AGIPCGridItem performSelector:@selector(resetNumberOfSelections)];
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fullscreen
//    if (self.imagePickerController.shouldChangeStatusBarStyle) {
//        self.wantsFullScreenLayout = YES;
//    }
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height - 45) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.bottomViewBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 45, 320, 45)];
    self.bottomViewBar.backgroundColor = [UIColor grayColor];
    self.bottomViewBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.bottomViewBar];
    
    // Setup Notifications
    [self registerForNotifications];
    
    [self loadCameraRollWhenAssetsIsNil];
    // Setup toolbar items
    [self setupToolbarItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Destroy Notifications
//    [self unregisterFromNotifications];
}

#pragma mark - Private

- (void)setupToolbarItems
{
//    if (self.imagePickerController.toolbarItemsForManagingTheSelection != nil)
//    {
//        NSMutableArray *items = [NSMutableArray array];
//        
//        // Custom Toolbar Items
//        for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection)
//        {
//            NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
//            
//            ((AGIPCToolbarItem *)item).barButtonItem.target = self;
//            ((AGIPCToolbarItem *)item).barButtonItem.action = @selector(customBarButtonItemAction:);
//            
//            [items addObject:((AGIPCToolbarItem *)item).barButtonItem];
//        }
//        
//        self.toolbarItems = items;
//    } else {
//        // Standard Toolbar Items
//        UIBarButtonItem *selectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.SelectAll", nil, [NSBundle mainBundle], @"Select All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllAction:)];
//        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        UIBarButtonItem *deselectAll = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"AGIPC.DeselectAll", nil, [NSBundle mainBundle], @"Deselect All", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(deselectAllAction:)];
//        
//        NSArray *toolbarItemsForManagingTheSelection = @[selectAll, flexibleSpace, deselectAll];
//        self.toolbarItems = toolbarItemsForManagingTheSelection;
//    }
//    UIImage* image_preview = [[UIImage imageNamed:@"btn_iwant_choose_photo_preview.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9,9,9,9)];
//    UIImageView* image_back_preview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 27)];
//    image_back_preview.image = image_preview;
//    UILabel* label_preview = [[UILabel alloc]initWithFrame:image_back_preview.bounds];
//    label_preview.backgroundColor = [UIColor clearColor];
//    label_preview.textColor = [UIColor colorWithHex:0x6e3e8e];
//    label_preview.textAlignment = UITextAlignmentCenter;
//    label_preview.text = @"预览";
//    label_preview.font = [UIFont systemFontOfSize:13];
//    [image_back_preview addSubview:label_preview];
    UIButton* button_preview = [[UIButton alloc]initWithFrame:CGRectMake(11, 10, 48, 27)];
//    [button_preview setBackgroundImage:image_preview forState:UIControlStateNormal];
    [button_preview setBackgroundColor:[UIColor grayColor]];
//    [button_preview setTitleColor:[UIColor colorWithHex:0x6e3e8e] forState:UIControlStateNormal];
    [button_preview setTitle:NSLocalizedString(@"TitlePreview", nil) forState:UIControlStateNormal];
    [button_preview addTarget:self action:@selector(onPreviewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button_preview.titleLabel.font = [UIFont systemFontOfSize:13];
    self.buttonItem_preview = button_preview;
    
//    UIImage* image_back_done = [[UIImage imageNamed:@"btn_iwant_choose_photo_determine.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9,9,9,9)];
//    UILabel* label_done = [[UILabel alloc]initWithFrame:image_back_done.bounds];
//    label_done.backgroundColor = [UIColor clearColor];
//    label_done.textColor = [UIColor whiteColor];
//    label_done.textAlignment = UITextAlignmentCenter;
//    label_done.text = @"确定";
//    label_done.font = [UIFont systemFontOfSize:13];
//    label_done.tag = 10086;
//    [image_back_done addSubview:label_done];
    UIButton* button_done = [[UIButton alloc]initWithFrame:CGRectMake(246, 10, 65, 27)];
    [button_done addTarget:self action:@selector(onFinishedBUttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button_done setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
//    [button_done setBackgroundImage:image_back_done forState:UIControlStateNormal];
    [button_done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button_done.titleLabel.font = [UIFont systemFontOfSize:13];
    self.buttonItem_done = button_done;
    
//    UIView* view_topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 1)];
//    view_topLine.backgroundColor = [UIColor colorWithHex:0xe1e1e1];
//    [self.bottomViewBar addSubview:view_topLine];
    
    [self.bottomViewBar addSubview:button_preview];
    [self.bottomViewBar addSubview:self.buttonItem_done];
}

- (void)onPreviewButtonClicked:(id)sender
{
    if (0 >= self.selectedAssets.count)
    {
        return;
    }
    MJPhotoBrowser*  browser = [[MJPhotoBrowser alloc]init];
    
    __weak NSArray* arr_assets = self.selectedAssets;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //转成图片，并刷新
        NSMutableArray* arr_images = [NSMutableArray arrayWithCapacity:6];
        for (ALAsset* set in arr_assets)
        {
            ALAssetRepresentation* presentation = [set defaultRepresentation];
            UIImage* image = [UIImage imageWithCGImage:[presentation fullScreenImage] scale:presentation.scale orientation:UIImageOrientationUp];
            if (image)
            {
                MJPhoto* photo = [MJPhoto new];
                photo.image = image;
                [arr_images addObject:photo];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^(void){
            browser.photos = arr_images;
            if (0 != browser.photos.count)
            {
                [browser show];
            }
        });

    });
}

- (void)onFinishedBUttonClicked:(id)sender
{
    [self.imagePickerController performSelector:@selector(didFinishPickingAssets:) withObject:self.selectedAssets];
}

- (void)onCancelButtonClicked:(id)sender
{
     [self.imagePickerController performSelector:@selector(didCancelPickingAssets)];
}

- (void)loadAssets
{
    [self.assets removeAllObjects];
    
    __ag_weak AGIPCAssetsController *weakSelf = self;
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
        __strong AGIPCAssetsController *strongSelf = weakSelf;
        
        @autoreleasepool {
            [strongSelf.assetsGroup enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result == nil) 
                {
                    return;
                }
                if (strongSelf.imagePickerController.shouldShowPhotosWithLocationOnly) {
                    CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
                    if (!assetLocation || !CLLocationCoordinate2DIsValid([assetLocation coordinate])) {
                        return;
                    }
                }
                
                AGIPCGridItem *gridItem = [[AGIPCGridItem alloc] initWithImagePickerController:self.imagePickerController asset:result andDelegate:self];
                
                // Drawing must be exectued in main thread. springox(20131220)
                /*
                if (strongSelf.imagePickerController.selection != nil &&
                    [strongSelf.imagePickerController.selection containsObject:result])
                {
                    gridItem.selected = YES;
                }
                 */
                
                //[strongSelf.assets addObject:gridItem];
                // Descending photos, springox(20131225)
                [strongSelf.assets addObject:gridItem];

            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [strongSelf reloadData];
            
        });
    
//    });
}

- (void)reloadData
{
    // Don't display the select button until all the assets are loaded.
//    [self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
    
    [self.tableView reloadData];
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    if (0 < rows)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:0];
        @try {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    //[self setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
    [self changeSelectionInformation];
    
    /*
    NSInteger totalRows = [self.tableView numberOfRowsInSection:0];
    //Prevents crash if totalRows = 0 (when the album is empty).
    if (totalRows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
     */
}

- (void)doneAction:(id)sender
{
    [self.imagePickerController performSelector:@selector(didFinishPickingAssets:) withObject:self.selectedAssets];
}

- (void)selectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = YES;
    }
}

- (void)deselectAllAction:(id)sender
{
    for (AGIPCGridItem *gridItem in self.assets) {
        gridItem.selected = NO;
    }
}

- (void)customBarButtonItemAction:(id)sender
{
//    for (id item in self.imagePickerController.toolbarItemsForManagingTheSelection)
//    {
//        NSAssert([item isKindOfClass:[AGIPCToolbarItem class]], @"Item is not a instance of AGIPCToolbarItem.");
//        
//        if (((AGIPCToolbarItem *)item).barButtonItem == sender)
//        {
//            if (((AGIPCToolbarItem *)item).assetIsSelectedBlock) {
//                
//                NSUInteger idx = 0;
//                for (AGIPCGridItem *obj in self.assets) {
//                    obj.selected = ((AGIPCToolbarItem *)item).assetIsSelectedBlock(idx, ((AGIPCGridItem *)obj).asset);
//                    idx++;
//                }
//                
//            }
//        }
//    }
    
}

- (void)changeSelectionInformation
{
//    if (self.imagePickerController.shouldDisplaySelectionInformation ) {
//        if (0 == [AGIPCGridItem numberOfSelections] ) {
//            self.navigationController.navigationBar.topItem.prompt = nil;
//        } else {
//            //self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
//            // Display supports up to select several photos at the same time, springox(20131220)
//            NSInteger maxNumber = _imagePickerController.maximumNumberOfPhotosToBeSelected;
//            if (0 < maxNumber) {
//                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], maxNumber];
//            } else {
//                self.navigationController.navigationBar.topItem.prompt = [NSString stringWithFormat:@"(%d/%d)", [AGIPCGridItem numberOfSelections], self.assets.count];
//            }
//        }
//    }
}

#pragma mark - AGGridItemDelegate Methods

- (void)agGridItem:(AGIPCGridItem *)gridItem didChangeNumberOfSelections:(NSNumber *)numberOfSelections
{
    self.buttonItem_done.enabled = self.buttonItem_preview.enabled = (numberOfSelections.unsignedIntegerValue > 0);
//    self.navigationItem.rightBarButtonItem.enabled = (numberOfSelections.unsignedIntegerValue > 0);
    NSString* title = (0 == numberOfSelections.unsignedIntegerValue) ? NSLocalizedString(@"OK", nil):[NSString stringWithFormat:@"%@(%d)", NSLocalizedString(@"OK", nil), numberOfSelections.unsignedIntegerValue];
    [self.buttonItem_done setTitle:title forState:UIControlStateNormal];
    [self changeSelectionInformation];
}

- (BOOL)agGridItemCanSelect:(AGIPCGridItem *)gridItem
{
    if (self.imagePickerController.selectionMode == AGImagePickerControllerSelectionModeSingle && self.imagePickerController.selectionBehaviorInSingleSelectionMode == AGImagePickerControllerSelectionBehaviorTypeRadio) {
        for (AGIPCGridItem *item in self.assets)
            if (item.selected)
                item.selected = NO;
        
        return YES;
    } else {
        if (self.imagePickerController.maximumNumberOfPhotosToBeSelected > 0)
            return ([AGIPCGridItem numberOfSelections] < self.imagePickerController.maximumNumberOfPhotosToBeSelected);
        else
            return YES;
    }
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(didChangeLibrary:) 
                                                 name:ALAssetsLibraryChangedNotification 
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:ALAssetsLibraryChangedNotification 
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification
{
    NSLog(@"here.");
}

#pragma mark - modify

- (void)loadCameraRollWhenAssetsIsNil
{
    __ag_weak AGIPCAssetsController *weakSelf = self;
    if (!self.assetsGroup)
    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
            @autoreleasepool {
                
                void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
                {
                    if (group == nil)
                    {
                        return;
                    }
                    
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                        weakSelf.assetsGroup = group;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self reloadWhenAssetsIsNil];
                        });
                        *stop = YES;
                    }
                };
                
                void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                    NSLog(@"A problem occured. Error: %@", error.localizedDescription);
                    [self.imagePickerController performSelector:@selector(didFail:) withObject:error];
                };
                
                [[AGImagePickerController defaultAssetsLibrary] enumerateGroupsWithTypes:ALAssetsGroupAll
                                                                              usingBlock:assetGroupEnumerator
                                                                            failureBlock:assetGroupEnumberatorFailure];
                
            }
            
//        });
    }
}

- (void)reloadWhenAssetsIsNil
{
    self.title = NSLocalizedStringWithDefaultValue(@"AGIPC.Loading", nil, [NSBundle mainBundle], @"Loading...", nil);
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [self loadAssets];
}
@end
