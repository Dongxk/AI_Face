# AI_Face


人脸登录:   静态图片人脸特征识别、 动态活体人脸扫描识别


##### 第一步：开启刷脸功能：

拍照或从相册选择一张静态照片进行人脸识别（不包含人脸是识别不出来的） 识别成功后将图片存在本地

##### 第二步：活体人脸扫描：

动态扫描 “活体人脸”

##### 第三步：匹配：

用两张图片去匹配 判断是否是本人



#### CocoaPods 使用方法
To integrate AI_Face into your Xcode project using CocoaPods, specify it in your Podfile:

```
source 'https://github.com/Dongxk/AI_Face.git'
platform :ios, '8.0'
target 'TargetName' do
pod  AI_Face
end
```
