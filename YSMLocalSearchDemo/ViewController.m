//
//  ViewController.m
//  YSMLocalSearchDemo
//
//  Created by ysmeng on 15/5/21.
//  Copyright (c) 2015年 广州七升网络科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "PinYin4Objc.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *listView;     //!<列表
@property (nonatomic,retain) NSMutableArray *dataSource;        //!<数据源
@property (nonatomic,retain) NSMutableArray *searchDataSource;  //!<搜索结果数据源

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    ///初始化数据
    self.dataSource = [NSMutableArray arrayWithObjects:
                       @"北京",
                       @"shanghai",
                       @"哈尔滨",
                       @"廣州",
                       @"成du",
                       @"chong庆",
                       @"佛山",
                       @"wuhan",
                       @"呼爾浩特",
                       @"临沂",
                       @"珠海",
                       @"zhongshan",
                       @"惠zou",
                       @"he源",
                       @"san亚",
                       @"海kou",
                       @"玉林",
                       @"南甯",
                       @"梧州",
                       @"鄭州",
                       @"茂名",
                       @"阿城",
                       @"南京",
                       @"徐州",
                       @"連雲港",
                       @"淮安",
                       @"無錫",
                       @"蘇州",
                       @"增城",nil];
    self.searchDataSource = [NSMutableArray arrayWithArray:self.dataSource];
    
    ///重新刷新列表
    [self.listView reloadData];
    
}

#pragma mark - 列表设置
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.searchDataSource count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *normalCell = @"normalCell";
    UITableViewCell *cellNormal = [tableView dequeueReusableCellWithIdentifier:normalCell];
    if (nil == cellNormal) {
        
        cellNormal = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCell];
        
        ///取消选择样式
        cellNormal.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    ///更新标题
    cellNormal.textLabel.text = self.searchDataSource[indexPath.row];
    
    return cellNormal;

}

#pragma mark - 搜索内容改变时，进行联想搜索
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    ///每次搜索内容变动，先清空原数据
    [self.searchDataSource removeAllObjects];

    ///判断搜索是否清空，清空则重源为原始数据源
    if (0 >= [searchText length]) {
        
        [self.searchDataSource addObjectsFromArray:self.dataSource];
        [self.listView reloadData];
        return;
        
    }
    
#if 0
    ///输入内容存在汉字：可以直接就用汉字搜索
    if ([self isIncludeChineseInString:searchText]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",searchText];
        [self.searchDataSource addObjectsFromArray:[self.dataSource filteredArrayUsingPredicate:predicate]];
        
        [self.listView reloadData];
        
        return;
        
    }
#endif
    
    ///拼音转码器
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    
    ///将输入内容转为拼音
    NSString *searchPY = [PinyinHelper toHanyuPinyinStringWithNSString:searchText withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
    
    for (int i = 0;i < self.dataSource.count;i++) {
        
        ///临时模型
        NSString *localString = self.dataSource[i];
        
        if ([self isIncludeChineseInString:localString]) {
            
            NSString *tempPinYinStr = [PinyinHelper toHanyuPinyinStringWithNSString:localString withHanyuPinyinOutputFormat:outputFormat withNSString:@"<>"];
            
            NSRange titleResult = [tempPinYinStr rangeOfString:searchPY options:NSCaseInsensitiveSearch];
            
            ///全拼包函
            if (titleResult.length > 0) {
                
                [self.searchDataSource addObject:localString];
                continue;
                
            }
            
            ///首字母包函
            NSArray *tempArray = [tempPinYinStr componentsSeparatedByString:@"<>"];
            NSMutableString *tempPinYinHeadStr = [NSMutableString string];
            for (int i = 0; i < [tempArray count]; i++) {
                
                NSString *singleWord = tempArray[i];
                if ([singleWord length] > 0) {
                    
                    char firstChar = [singleWord characterAtIndex:0];
                    if (firstChar >= 97 && firstChar <= 122) {
                        
                        [tempPinYinHeadStr appendString:[singleWord substringToIndex:1]];
                        
                    }
                    
                }
                
            }
            
            NSRange titleHeadResult = [tempPinYinHeadStr rangeOfString:searchPY options:NSCaseInsensitiveSearch];
            
            if (titleHeadResult.length > 0) {
                
                [self.searchDataSource addObject:localString];
                
            }
            
        } else {
            
            NSRange titleResult = [localString rangeOfString:searchPY options:NSCaseInsensitiveSearch];
            if (titleResult.length > 0) {
                
                [self.searchDataSource addObject:localString];
                
            }
            
        }
        
    }
    
    ///刷新数据
    [self.listView reloadData];

}

- (BOOL)isIncludeChineseInString:(NSString*)str
{
    
    for (int i=0; i<str.length; i++) {
        
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            
            return true;
            
        }
        
    }
    
    return false;
    
}

@end
