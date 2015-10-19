//
//  HomeViewController.m
//  WikiSearch
//
//  Created by Rameez Hussain on 08/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "HomeViewController.h"
#import "WikiManager.h"
#import "UIViewController+CommonOperations.h"
#import "WikiSearchResult.h"
#import "WikiSearchResultViewController.h"

@interface HomeViewController ()

@property (nonatomic, strong) IBOutlet UITableView *wikiSearchResultsTable;
@property (nonatomic, strong) IBOutlet UISearchBar *wikiSearchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Home";
    self.wikiSearchResultsTable.tableHeaderView = self.wikiSearchBar;
    [self.wikiSearchResultsTable reloadData];
    [self.wikiSearchBar setShowsCancelButton:NO];
    [self initSearchResultsState];
}

- (void) viewWillAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self unregisterKeyboardNofifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search related methods.

- (void) initSearchResultsState {
    self.searchResults = [NSMutableArray new];
    self.wikiSearchBar.text = @"";
    [self.wikiSearchResultsTable reloadData];
}

- (void) handleSuccessfulSearchResponse: (id) responseObject {
    self.searchResults = [NSMutableArray new];
    NSArray *allResponses = responseObject;
    NSArray *responseStrings = allResponses[1];
    NSArray *links = allResponses[3];
    if (responseStrings) {
        for (int i = 0; i < responseStrings.count; i++) {
            NSString *result = responseStrings[i];
            NSString *link = links[i];
            WikiSearchResult *searchResult = [WikiSearchResult getSearchResultWithText:result andLink:link];
            [self.searchResults addObject:searchResult];
        }
        [self.wikiSearchResultsTable reloadData];
    }
}

- (void) performSearch {
    NSString *searchString = self.wikiSearchBar.text;
    if (searchString.length > 0) {
        [self showLoader];
        [[WikiManager sharedManager] performSearchWithString:searchString withSuccess:^(id responseObject) {
            NSLog(@"Got response for search - %@", responseObject);
            [self hideLoader];
            [self handleSuccessfulSearchResponse:responseObject];
        } andFailure:^(NSError *error) {
            NSLog(@"Search operation failed - %@", error.debugDescription);
            [self hideLoader];
        }];
    } else {
        [self initSearchResultsState];
    }
}


#pragma mark - UISearchBarDelegate methods

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
    [self performSearch];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self performSelector:@selector(performSearch) withObject:nil afterDelay:0.5];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
    [self.wikiSearchBar setShowsCancelButton:NO];
}

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.wikiSearchBar setShowsCancelButton:YES];
    return YES;
}

#pragma mark - UITableViewDelegate methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    WikiSearchResult *searchResult = self.searchResults[indexPath.row];
    cell.textLabel.text = searchResult.text;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WikiSearchResult *searchResult = self.searchResults[indexPath.row];
    WikiSearchResultViewController *searchResultViewController = [[WikiSearchResultViewController alloc] initWithNibName:@"WikiSearchResultViewController" bundle:nil];
    searchResultViewController.searchResult = searchResult;
    [self.navigationController pushViewController:searchResultViewController animated:YES];
}

#pragma mark - Keyboard notifications and operations.

- (void) setupViewToHideKeyboard: (UIView *) view {
    for (UIView* subView in view.subviews) {
        if (![subView isKindOfClass:[UITextView class]] && ![subView isKindOfClass:[UITextField class]]) {
            UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
            [hideKeyboard setCancelsTouchesInView:NO];
            [subView addGestureRecognizer:hideKeyboard];
        }
        
        [self setupViewToHideKeyboard:subView];
    }
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardDidShow: (NSNotification *) notification{
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updateContentScrollViewSize: keyboardSize];
}

- (void)keyboardWillHide: (NSNotification *) notification{
    [self updateContentScrollViewSize];
}

- (void) updateContentScrollViewSize: (CGSize) keyboardSize {
    [self.wikiSearchResultsTable setContentSize:[self getContentScrollViewSizeToBeSet:keyboardSize]];
}

- (void) updateContentScrollViewSize {
    [self updateContentScrollViewSize:CGSizeZero];
}

- (CGSize) getContentScrollViewSizeToBeSet: (CGSize) keyboardSize {
    CGSize targetSize = [self getScreenSize];
    targetSize.height += keyboardSize.height;
    return targetSize;
}

@end
