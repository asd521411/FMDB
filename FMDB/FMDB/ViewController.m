//
//  ViewController.m
//  FMDB
//
//  Created by 草帽~小子 on 2019/4/12.
//  Copyright © 2019 OnePiece. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
@interface ViewController (){
    FMDatabase *db;
}

@property (nonatomic,assign) int stuid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *sex;
@property (nonatomic,assign) int age;
@property (nonatomic, strong) UIButton *insertDBBtn;
@property (nonatomic, strong) UIButton *selectDBBtn;
@property (nonatomic, strong) UIButton *deleteDBBtn;
@property (nonatomic, strong) UIButton *updateDBBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    一、FMDB简介
//    1.什么是 FMDB
//    FMDB 是 iOS 平台的 SQLite 数据库框架, OC 的方式封装了 SQLite 的 C 语言 API
//    2.FMDB的优点
//    使用起来更加面向对象，省去了很多麻烦、冗余的C语言代码
//    对比苹果自带的Core Data框架，更加轻量级和灵活
//    提供了多线程安全的数据库操作方法，有效地防止数据混乱
//    二、cocopads 引入 FMDB 库
//    pod 'FMDB'
//    三、核心类
//    FMDB有三个主要的类
//    （1）FMDatabase
//    一个FMDatabase对象就代表一个单独的SQLite数据库
//    用来执行SQL语句
//    （2）FMResultSet
//    使用FMDatabase执行查询后的结果集
//    （3）FMDatabaseQueue
//    用于在多线程中执行多个查询或更新，它是线程安全的
    
//    四、打开数据库
    //啰嗦一句：获取沙盒的Documents目录
    /**
     * @param NSDocumentDirectory  获取Document目录
     * @param NSUserDomainMask     是在当前沙盒范围内查找
     * @param YES                  展开路径，NO是不展开
     * @return Documents文件的路径
     */
    //1、
    NSString *path1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    //2、
    NSString *path2 = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    //2.1、文件目录Preferences由系统维护，不需要我们手动的获取文件路径进行操作,而是需要借助NSUserDefault来操作
    //但是我们是可以获取到这个文件的路径
    NSString *path22 = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Prefrences"];
    //例如
    [[NSUserDefaults standardUserDefaults] setObject:@"尼古拉斯赵四" forKey:@"zhao"];//此时Library/Caches/Prefrences 文件中多了一个plist文件，可见NSUserDefaults也是以plist文件存储在本地的
    
    //3 获取tmp文件路径
    /**
     * 获取tmp文件目录下的文件路径
     *
     * @return tmp的文件路径
     */
    NSString *filePath = NSTemporaryDirectory();
    NSLog(@"==========%@", path1);
    if (!path1) {
        NSLog(@"-------未找到文件路径");
    }else {
        NSString *filePaht = [path1 stringByAppendingPathComponent:@"test.txt"];
        NSArray *array = [NSArray arrayWithObjects:@"code",@"change", @"world", @"OK", @"", @"是的", nil];
        [array writeToFile:filePaht atomically:YES];
    }
    
    //操作数据库
    
    NSString *dataPath = [path1 stringByAppendingPathComponent:@"student.sqlite"];
    db = [FMDatabase databaseWithPath:dataPath];
    if (db) {
        if ([db open]) {
            NSLog(@"打开数据库");
            BOOL setUpSql = [db executeUpdate:@"create table if not exists stu(stuid integer primary key autoincrement, name varchar(255),sex varchar(255),age integer)"];
            
            if (setUpSql) {
                NSLog(@"建表成功！");
            }else {
                NSLog(@"建表失败！");
            }
            
        }else{
            NSLog(@"数据库打开失败!");
        }
    }else {
        NSLog(@"数据库创建失败!");
    }
    
//    注意创建数据库时路径的问题 路径可以是以下三种方式之一
//
//    　　1.文件路径 该文件路径真实存在，如果不存在回自动创建
//
//    　　2.空字符串@"" 表示会在临时目录里创建一个空的数据库 当FMDataBase连接关闭时 文件也会被删除
//
//    　　3.NULL 将创建一个内在数据库 同样的 当FMDataBase连接关闭时 数据将会被销毁
//
    self.insertDBBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.insertDBBtn.frame = CGRectMake(100, 200, 200, 80);
    self.insertDBBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.insertDBBtn];
    [self.insertDBBtn setTitle:@"insert" forState:UIControlStateNormal];
    [self.insertDBBtn addTarget:self action:@selector(insertDataToDb) forControlEvents:UIControlEventTouchUpInside];

    self.selectDBBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectDBBtn.frame = CGRectMake(100, 300, 200, 80);
    self.selectDBBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.selectDBBtn];
    [self.selectDBBtn setTitle:@"查询" forState:UIControlStateNormal];
    [self.selectDBBtn addTarget:self action:@selector(selectDataFormDb) forControlEvents:UIControlEventTouchUpInside];

    self.deleteDBBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteDBBtn.frame = CGRectMake(100, 400, 200, 80);
    self.deleteDBBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.deleteDBBtn];
    [self.deleteDBBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteDBBtn addTarget:self action:@selector(deleteAllDbData) forControlEvents:UIControlEventTouchUpInside];

    self.updateDBBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.updateDBBtn.frame = CGRectMake(100, 500, 200, 80);
    self.updateDBBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.updateDBBtn];
    [self.updateDBBtn setTitle:@"更新数据" forState:UIControlStateNormal];
    [self.updateDBBtn addTarget:self action:@selector(updateDbData) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view.
}
//    向数据库中添加数据  查找数据 和 删除数据

//向数据库中插入数据
- (void)insertDataToDb{
    NSArray *array = @[@"13141",@"13142",@"13143",@"13144",@"13145"];
    for (int i = 0; i < 5; i ++) {
        NSString *insertSql = @"insert into stu(stuid,name,sex,age) values(?,?,?,?)";
        //不确定的参数用%@，%d等来占位
//        NSString *sql = @"insert into t_student (name,age) values (%@,%i)";
//        [db executeUpdateWithFormat:sql, @"zhangsan", 18];
        BOOL success = [db executeUpdate:insertSql,array[i],[NSString stringWithFormat:@"tian%d",i],@"男",@20];
        if (success) {
            NSLog(@"数据插入成功");
        }
    }
}

//查询数据库 //查询所有的数据库数据
- (void)selectDataFormDb{
    NSString *selectSql = @"select *from stu";
    FMResultSet *result = [db executeQuery:selectSql];
    while ([result next]) {
        NSLog(@"%@ %@ %@ %d",[result stringForColumn:@"stuid"],[result stringForColumn:@"name"],[result stringForColumn:@"sex"],[result intForColumn:@"age"]);
    }
    
}

//清空数据库
- (void)deleteAllDbData {
    NSString *deleteSql = @"delete from stu";
    BOOL success = [db executeUpdate:deleteSql];
    if (success) {
        NSLog(@"删除数据成功");
    }
}

//修改数据库中的数据
- (void)updateDbData {
    
    //tian6是新值 代替数据库中name = tian1的值
    
    NSString *updateSql = @"update stu set stuid = ? where stuid = ? ";
    BOOL success  = [db executeUpdate:updateSql,@"12000",@"13143"];
    
    if (success) {
        [self selectDataFormDb];
    }
    
   
}

//队列和线程安全
//在多线程中同时使用 FMDatabase 单例是极其错误的想法，会导致每个线程创建一个 FMDatabase 对象。不要跨线程使用单例，也不要同时跨多线程，不然会奔溃或者异常。
//因此不要实例化一个 FMDatabase 单例来跨线程使用。
//相反，使用 FMDatabaseQueue，下面就是它的使用方法：


@end
