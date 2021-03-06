//
//  RRNewsViewController.m
//  RSSReader
//
//  Created by Timofey Taran on 30.05.17.
//  Copyright © 2017 Timofey Taran. All rights reserved.
//

#import "RRNewsViewController.h"
#import "RRNewsTabCollectionViewCell.h"
#import "RRNewsTableViewCell.h"
#import "RRDescriptionNewsViewController.h"
#import "RRNewsManager.h"
#import "RRNews+CoreDataClass.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSString *currentTag;


const CGFloat RRIndentConst = 8.0;
const CGFloat RRDefaultCellHightConst = 100.0;


@interface RRNewsViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource,UICollectionViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *newsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *newsTabsCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic) UIRefreshControl *refreshControll;

@property (nonatomic) NSMutableArray<RRNews *> *arrayNews;

@end


@implementation RRNewsViewController


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControll = [[UIRefreshControl alloc] init];
    [self.refreshControll addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:self.refreshControll];
    
    
    [self showDownloadProcess:YES];
    currentTag = [[RRNewsManager sharedManager] tagWithIndex:self.currentNewsTabIndex];
    [self updateContentFromXMLParserWithTag:currentTag];
    
    [self.newsTabsCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentNewsTabIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    
    [self scrollInitialization];
    [self.newsTableView setContentOffset:CGPointMake(0, -RRIndentConst) animated:NO];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollFromSelectedNewsTag];
}


#pragma mark - UI Update

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    __weak RRNewsViewController *weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         [weakSelf scrollFromSelectedNewsTag];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


- (void)scrollInitialization
{
    self.newsTableView.scrollsToTop = YES;
    self.newsTabsCollectionView.scrollsToTop = NO;
    self.newsTableView.contentInset = UIEdgeInsetsMake(RRIndentConst, 0, 0, 0);
}


- (void)showDownloadProcess:(BOOL)show
{
    self.newsTableView.hidden = show;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = show;
    [self.refreshControll endRefreshing];
    
    if (show)
    {
        [self.newsTableView setContentOffset:CGPointMake(0, -RRIndentConst) animated:NO];
        [self.activityIndicatorView startAnimating];
    }
    else
    {
        [self.activityIndicatorView stopAnimating];
    }
}


- (void)scrollFromSelectedNewsTag
{
    NSIndexPath *indexPath = [self.newsTabsCollectionView indexPathsForSelectedItems][0];
    [self.newsTabsCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (void)updateContentFromXMLParserWithTag:(NSString *)tag
{
    [self showDownloadProcess:YES];
    
    __weak RRNewsViewController *weakSelf = self;
    
    NSArray<RRNews *> *newsArray = [[RRNewsManager sharedManager] getNewsArrayWithTag:tag updateNewsBlock:^{
        [weakSelf updateContentFromXMLParserWithTag:currentTag];
    } cancelBlock:^{
        [weakSelf showDownloadProcess:NO];
    }];
    
    if (newsArray.count > 0)
    {
        self.arrayNews = [newsArray copy];
        [self showDownloadProcess:NO];
        [self.newsTableView reloadData];
    }
}


- (void)handleRefresh:(id)sender
{
    [[RRNewsManager sharedManager] updateNewsWithTag:currentTag];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [RRNewsManager sharedManager].newsResourceArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RRNewsTagCell" forIndexPath:indexPath];
    
    RRNewsTabCollectionViewCell *newsCell = (RRNewsTabCollectionViewCell *)cell;
    newsCell.newsTagLabel.text = [[RRNewsManager sharedManager] tagWithIndex:indexPath.row];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RRNewsTabCollectionViewCell *cell = (RRNewsTabCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.currentNewsTabIndex != indexPath.row)
    {
        currentTag = cell.newsTagLabel.text;
        [self updateContentFromXMLParserWithTag:currentTag];
    }
    
    self.currentNewsTabIndex = indexPath.row;
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightRow = RRDefaultCellHightConst;
    
    if (indexPath.row >= self.arrayNews.count)
    {
        return heightRow;
    }
    
    NSString *imageURL = self.arrayNews[indexPath.row].imageURL;
    
    if (imageURL)
    {
        CGSize imageSize = CGSizeMake(420, 280);
        CGFloat imageResolution = imageSize.height / imageSize.width;
        CGFloat newHeight = (self.view.frame.size.width - 2 * RRIndentConst) * imageResolution;
        heightRow = (newHeight > imageSize.height) ? imageSize.height : newHeight;
        heightRow += RRIndentConst;
    }
    
    return heightRow;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayNews.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RRNewsTableViewCell *newsCell = [tableView dequeueReusableCellWithIdentifier:@"RRNewsCell" forIndexPath:indexPath];
    
    if (indexPath.row >= self.arrayNews.count)
    {
        return newsCell;
    }
    
    RRNews *news = self.arrayNews[indexPath.row];
    newsCell.newsDateLabel.text = [RRNewsManager formattedDateStringWithDate:news.pubDate];
    newsCell.newsHeaderLabel.text = news.header;
    
    if (news.imageURL)
    {
        [newsCell.newsImageView sd_setImageWithURL:[NSURL URLWithString:news.imageURL]
                                  placeholderImage:[UIImage imageNamed:@""]];
    }
    else
    {
        newsCell.newsImageView.image = nil;
    }
    
    return newsCell;
}


#pragma mark - TableViewCellNavigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"selectNews"])
    {
        RRDescriptionNewsViewController *descriptionNewsVC = [segue destinationViewController];

        NSIndexPath *indexPath = [self.newsTableView indexPathForCell:(UITableViewCell *)sender];
        
        if (indexPath.row < self.arrayNews.count)
        {
            descriptionNewsVC.newsData = self.arrayNews[indexPath.row];
            
            NSString *imageURL = self.arrayNews[indexPath.row].imageURL;
            
            if (imageURL && [sender isKindOfClass:RRNewsTableViewCell.class])
            {
                RRNewsTableViewCell *cell = (RRNewsTableViewCell *)sender;
                descriptionNewsVC.newsImage = cell.newsImageView.image;
            }
        }
    }
}


@end
