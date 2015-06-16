//
//  ViewController.m
//  6.15.UI.HW
//
//  Created by rimi on 15/6/15.
//  Copyright (c) 2015年 rectinajh. All rights reserved.
//

#define GET_URL @"http://op.juhe.cn/onebox/football/team?key=78ec0fada7ec0ef9db74b1f3b06307ea&dtype=json&team=%E7%9A%87%E5%AE%B6%E9%A9%AC%E5%BE%B7%E9%87%8C"
#define POST_URL @"http://op.juhe.cn/onebox/football/team"
#define APP_KEY @"78ec0fada7ec0ef9db74b1f3b06307ea"

#import "ViewController.h"
#import "CustomTableViewCell.h"
#import "UIImageView+WebCache.h"


@interface ViewController ()<UITableViewDataSource,NSURLConnectionDataDelegate>

@property(nonatomic, strong) UITableView        *tableView;
@property(nonatomic, strong) NSMutableArray     *dataSource;
@property(nonatomic, strong) NSMutableData      *data; //请求获得数据，拼接data
@property(nonatomic, strong) UIActivityIndicatorView    *indicatorView; //活动指示器


- (void)initializeUserInterface;

- (void)sendSynchronizedGetRequest;     //同步get

- (void)sendSynchronizedPostRequest;    //同步post
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource =[NSMutableArray array];
    self.data = [NSMutableData data];
    
    [self initializeUserInterface];
    
}


- (void)initializeUserInterface
{
    //1.创建Tableview
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    //2,设置数据源
    self.tableView.dataSource =self;
    //3,注册自定义cell
//    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Custom"];
    
    //4,设置行高
    self.tableView.rowHeight = 80;
    //5,添加到视图
    [self.view addSubview:self.tableView];
    
    //6.创建活动指示器
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.indicatorView];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
//出现一次Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1,注册之后选用tableView含有两个参数的方法进行出列
   
//    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Custom" forIndexPath:indexPath];
    
    //2,配置cell
//    cell.Team.text = self.dataSource[indexPath.row][@"c4T1"];
    
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    

    NSLog(@"%@", self.dataSource[indexPath.row][@"c53"]);
    cell.textLabel.text = self.dataSource[indexPath.row][@"c4T1"];
    

    
    
    //cell.playerLabel.text = self.dataSource[@"list" ][indexPath.row][@"C53"];
    //配置cell图片
    //NSString *album= self.dataSource[indexPath.row][@"albums"][0];
    //获取图片字符串
//    [cell.teamView sd_setImageWithURL:[NSURL URLWithString:album]];
    
    //3,返回Cell
    return cell;
    
}

#pragma mark - 网络请求
//同步get
- (void)sendSynchronizedGetRequest
{
    //1,创建URL对象
    NSURL *url = [NSURL URLWithString:GET_URL];
    //2,创建URLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //3,发送请求
    //3.1 创建error对象
    NSError *error = nil;
    
    NSData *data =[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    
    //3.2 断言（帮助快速定位到崩溃的位置，optional）
    NSString *errorString = [error localizedDescription];
    
    //当前者条件为假的时候，进行崩溃，崩溃原因为后面参数所写
    NSAssert(!error,errorString);
    //解析数据
    id obj = [self jsonWithData:data];
    
    NSLog(@"%@",obj);
    
    //判定
    if ([obj[@"error_code"] integerValue] == 0) {
        //5.1更改数据源
         [self.dataSource addObjectsFromArray:obj[@"result"][@"list"]];
        //5.2更新表格视图
        [self.tableView reloadData];
    }
    //停止动画
    [self.indicatorView stopAnimating];
    
    
}



- (IBAction)sendGetEvent:(id)sender {
    
    [self.indicatorView startAnimating];
    [self sendSynchronizedGetRequest];
    
}


- (IBAction)sendPostEvent:(id)sender {
    
    [self sendSynchronizedPostRequest];
}

#pragma mark - NSURLConnectionDataDelegate
//请求失败的时候调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"请求失败");
}
//接受到数据的时候调用（调用次数>=0）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //添加数据流
    [self.data appendData:data];
    
}
//请求完成时候调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //4，解析数据
    id obj = [self jsonWithData:self.data];
    //判定
    if ([obj[@"error_code"] integerValue] == 0) {
        //5.1更改数据源
        [self.dataSource addObjectsFromArray:obj[@"result"][@"list"]];
        //5.2更新表格视图
        [self.tableView reloadData];
    }
    //6,清空数据流，否则下次请求异常
    self.data.length = 0 ;
    
    //7,停止转动
    [self.indicatorView stopAnimating];
}



- (id)jsonWithData:(NSData *)data {
    //创建error
    NSError *error = nil;
    //解析数据
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    //创建错误字符串
    NSString *errorString = [NSString stringWithFormat:@"错误原因：%@",[error localizedDescription]];
    //断言
    NSAssert(!error,errorString);
    
    //返回
    return obj;
}
// 将中文编码成url
- (NSString *)urlEncodeString:(NSString *)string
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8));
    return result;
}

@end
