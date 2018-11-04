//
//  ViewController.m
//  隐私
//
//  Created by yide zhang on 2018/11/4.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "ViewController.h"

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <MessageUI/MessageUI.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CNContactViewControllerDelegate,CNContactPickerDelegate,MFMessageComposeViewControllerDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,copy) NSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataSource = @[@"通讯录",@"短信获取",@"短信发送",@"通话记录",@"拨打电话"];
    [self createTableView];
}

-(void)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ddd"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
//            CNMutableContact *contact = [[CNMutableContact alloc] init];
//            CNContactViewController *contactController = [CNContactViewController viewControllerForNewContact:contact];
//            contactController.delegate = self;
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:contactController];
//            [self presentViewController:nav animated:YES completion:nil];
            //让用户给权限,没有的话会被拒的各位
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if (status == CNAuthorizationStatusNotDetermined) {
                CNContactStore *store = [[CNContactStore alloc] init];
                [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"没有授权, 需要去设置中心设置授权");
                    }else
                    {
                        NSLog(@"用户已授权限");
                        CNContactPickerViewController * picker = [CNContactPickerViewController new];
                        picker.delegate = self;
                        // 加载手机号
                        picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
                        [self presentViewController: picker  animated:YES completion:nil];
                    }
                }];
            }
            
            if (status == CNAuthorizationStatusAuthorized) {
                
                //有权限时
                CNContactPickerViewController * picker = [CNContactPickerViewController new];
                picker.delegate = self;
                picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
                [self presentViewController: picker  animated:YES completion:nil];
            }
            else{
                NSLog(@"您未开启通讯录权限,请前往设置中心开启");
            }
        }
            break;
        case 1:
        {
            //获取短信
        }
            break;
        case 2:
        {
            //发送短信
            if( [MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
                controller.recipients = @[@"10086"];//发送短信的号码，数组形式入参
                controller.navigationBar.tintColor = [UIColor redColor];
                controller.body = @"body"; //此处的body就是短信将要发生的内容
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:nil];
                [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"title"];//修改短信界面标题
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息"
                                                                message:@"该设备不支持短信功能"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
            
        default:
            break;
    }
}

-(void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(CNContact *)contact
{
    NSLog(@"%@",contact);
}

/**
 逻辑:  在该代理方法中会调出手机通讯录界面, 选中联系人的手机号, 会将联系人姓名以及手机号赋值给界面上的TEXT1和TEXT2两个UITextFiled上.
 功能: 调用手机通讯录界面, 获取联系人姓名以及电话号码.
 */
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
    
    CNContact *contact = contactProperty.contact;
    
    NSLog(@"%@",contactProperty);
    NSLog(@"givenName: %@, familyName: %@", contact.givenName, contact.familyName);
    
//    self.TEXT1.text = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
    if (![contactProperty.value isKindOfClass:[CNPhoneNumber class]]) {
        NSLog(@"提示用户选择11位的手机号");
        return;
    }
    
    CNPhoneNumber *phoneNumber = contactProperty.value;
    NSString * Str = phoneNumber.stringValue;
    NSCharacterSet *setToRemove = [[ NSCharacterSet characterSetWithCharactersInString:@"0123456789"]invertedSet];
    NSString *phoneStr = [[Str componentsSeparatedByCharactersInSet:setToRemove]componentsJoinedByString:@""];
    if (phoneStr.length != 11) {
        
        NSLog(@"提示用户选择11位的手机号");
    }
    
    NSLog(@"-=-=%@",phoneStr);
//    self.TEXT2.text = phoneStr;
}

//mesage代理
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
}


@end
