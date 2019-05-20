## Radar iOS SDK 接入指南
### 简介
**Radar**是一个提供了一系列检测客户端性能问题工具的SDK,其中包括了监控`主线程卡顿`,`页面打开耗时`,`内存预警`,`内存泄露`,`大内存分配`功能,提供了线上跟踪功能.

### 接入
`Radar` 提供了手动接入和 `cocoapods`两种接入方式.更加推荐cocoapods方式进行集成.

##### 通过cocoaPods方式接入:
在Podfile中添加如下文本

```c
  pod 'Radar'
```
保存并执行`pod install`,然后用后缀为`.xcworkspace`的文件打开工程。
##### 手动接入
* 下载[Radar SDK](https://s.momocdn.com/w/u/others/2019/04/26/1556270662866-Radar.zip)
* 拖拽`Radar.framework`文件到Xcode工程内(注意勾选Copy items if needed选项)
* 添加依赖库：(project->target->build phases->Link Binary With Libraries)
    - libz.tbd
    - libc++.tbd

### 使用
* 在工程的`AppDelegate.m`中导入Radar头文件.

Objective-C
通过RadarConfig可以设置一些自定义参数,例如自定义版本号,自定义渠道等

RadarDelegate:
`aliasForViewController:` **Radar** 在检测到性能问题时默认会使用NSStringFromClass(currentController.class)方式记录当前页面的名字, 如果你的工程中使用了一些脚本语言进行跨平台开发或者其他用途, 那么很有可能用来展示这种页面的 `viewController` 的 `class` 是一样的, 可以实现这个方法返回可以区分页面的标识.
 
```objc
#import <Radar/Radar.h>

@interface AppDelegate ()<RadarDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    RadarConfig *config = [RadarConfig new];
    config.channel = @"Appstore";
    config.customAppVersion = @"0.1.1";
    config.delegate = self;
    [Radar startWithAppId:@"56e61d33cefc4e2cab629715b6aa34eb" enableOptions:RAPerformanceDetectorEnableOptionAll config:config];
    return YES;
}

- (NSString *)aliasForViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[LuaViewController class]]) {
        return [(LuaViewController *)viewController pageName];
    }
    return nil;
}

@end
```
Swift

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    Radar.start(withAppId: "your app id", enableOptions: RAPerformanceDetectorEnableOptionAll, config: nil);
    return true
}
```

    
### 上传符号表

**重要:**`Radar`和[`Rifle`](https://github.com/cosmos33/Rifle-iOS/blob/master/ios/jie-ru-zhi-nan.md)使用同样的appId和appKey,使用同一套符号表后台管理系统,所以如果项目中已经接入了`Rifle`,并且已经上传了符号表请跳过此步骤.

符号表上传有两种方式：

* 自动上传 (默认方式)
* 手动上传

推荐使用自动上传，如果自动上传失败或者需要从`AppStore`下载符号表上传，则使用手动上传。
##### 自动上传
自动上传脚本位于`Radar.framework`文件夹内，在将`Radar.framework`通过`cocoPods`或者手动方式添加到工程中之后，在`Xcode`工程里的 `Targets - Build Phases`处添加脚本
![symbolScript](https://cosmos.momocdn.com/cosmosimage/33/81/3381515A-E79D-9CB3-0F6C-985034071B2920190515_L.jpg)
![script](https://cosmos.momocdn.com/cosmosimage/83/27/8327AE67-CF51-4046-E03C-58493798F79A20190515_L.jpg)

脚本可以复制下面的内容

```
####################################################################
#       请注意配置app-id 和 app-key
####################################################################
APP_ID="app-id"
APP_KEY="app-key"

####################################################################
#       符号表默认只在非DEBUG下上传，如果想在DEBUG下上上传
#       打开 RIFLE_FORCE_UPLOAD
####################################################################
#export RIFLE_FORCE_UPLOAD="EN"

####################################################################
#       下面脚本会在构建阶段自动异步上传符号表,注意不要写错脚本地址
####################################################################
# 如果手动接入,使用下面命令
./RadarDemo/Radar/Radar.framework/run ${APP_ID} ${APP_KEY}
# 如果使用cocoapods,使用下面命令,将下面注释打开
# ./Pods/Radar/Radar_iOS/Radar.framework/run ${APP_ID} ${APP_KEY} 

```

##### 手动上传

将 `upload_dsym`、 `dump_dsymbols`脚本和要解析的`.dsym`文件放在同一个目录下，执行以下脚本

```
./upload_dsym ./xxxxxx.dsym app-version app-id app-key
```

则会看到执行的log信息，并且在当前目录下会生成symbols.zip的文件

如果只是生成符号表文件，暂时不上传，可以执行

```
./upload_dsym ./xxxxxx.dsym
```

如果要查看帮助信息，执行

```
./upload_dsym --help
```

会看到如下信息：

```
⚠️ 注意： 1. 如果需要上传符号表到Rifle服务器，需要传递四个参数

	第一个参数是  .dsym文件的路径，ex: ./RadarDemo.app.dSYM, 其中 RadarDemo 须和APP名称保持一致
	第二个参数是 app-version 
	第三个参数是app-id 
	第四个参数是app-key 
🔹 如果只是解析符号表，只需要传递第一个参数即可 
2. 必须把可执行文件 dump_symbols 和upload_dsym放在同一目录下，否则解析符号表会失败！
3. 上传过程中会把最终的符号表拷贝到当前目录下，文件名为 symbols.zip,如果上传失败，可以通过网址：www. 手动上传. 
```



    

