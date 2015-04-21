Pod::Spec.new do |s|
  s.name          = "DKTabPageViewController"
  s.version       = "1.3.3"
  s.summary       = "DKTabPageViewController is an UIViewController subclass that support for multiple tab and gestures."
  s.homepage      = "https://github.com/zhangao0086/DKTabPageViewController"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Bannings" => "zhangao0086@gmail.com" }
  s.platform      = :ios, "6.0"
  s.source        = { :git => "https://github.com/zhangao0086/DKTabPageViewController.git", 
                      :tag => s.version.to_s }
  s.source_files  = "DKTabPageViewController/*.{h,m}"
  s.frameworks    = "Foundation", "UIKit"
  s.requires_arc  = true
end
