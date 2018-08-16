

Pod::Spec.new do |s|

  s.name         = "AI_Face"
  s.version      = "1.0.0"
  s.summary      = "人脸识别"
  s.description  = <<-DESC
  					静态图片人脸特征识别、动态人脸扫描识别
                   DESC
  s.homepage      = "https://github.com/Dongxk/AI_Face.git"
  s.license       = "MIT"
  s.author             = { "Dongxk" => "1043643016@qq.com" }
  s.platform      = :ios
  s.ios.deployment_target = "8.0"
  s.source        = { :git => "https://github.com/Dongxk/AI_Face.git", :tag => "#{s.version}" }
  s.source_files  = "AI_Face/*.{h,m}"
  
  # s.resources 	  = "Resources/*.png"
  # s.frameworks = "Framework", "AnotherFramework"

 

end
