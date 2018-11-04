//
//  YDPhotoGroupViewController.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoGroupViewController.h"
#import "YDPhotoGroupTableViewCell.h"
#import "YDPhotoAlbumManager.h"
#import "YDPhotoAlbumViewController.h"

@interface YDPhotoGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,copy) NSArray *dataSouce;

@property(nonatomic,strong) UITableView *tableView;

@end

@implementation YDPhotoGroupViewController

static NSString *const cellIdent = @"cellIdent";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self resetDataSource];
    [self initTableView];
}
-(void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:YDPhotoGroupTableViewCell.class forCellReuseIdentifier:cellIdent];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem  *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancleAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)cancleAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)resetDataSource
{
    [YDPhotoAlbumManager fetchPhotoGroup:^(NSArray<YDPhotoGroupModel *> *array) {
        self.dataSouce = array;
        [self.tableView reloadData];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSouce.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDPhotoGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    YDPhotoGroupModel *model = self.dataSouce[indexPath.item];
    
    cell.nameLabel.text = model.name;
    cell.numLabel.text = [NSString stringWithFormat:@"%ld张",(long)model.count];
    cell.pictureImage.image = model.image;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YDPhotoGroupModel *model = self.dataSouce[indexPath.item];
    YDPhotoAlbumViewController *controllr = [[YDPhotoAlbumViewController alloc] init];
    
    controllr.dataSouce = model.items;
    [self.navigationController pushViewController:controllr animated:YES];
}

@end











