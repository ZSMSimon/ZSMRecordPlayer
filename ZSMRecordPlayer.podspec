Pod::Spec.new do |s|
  s.name          = "ZSMRecordPlayer"
  s.version       = "1.0.0"
  s.summary       = "Audio player function integration(本地音频播放功能集成)"
  s.description   = <<-DESC
                    iOS Audio player function integration by Simon (iOS本地音频播放功能集成) 
                   DESC
  s.homepage      = "https://github.com/ZSMSimon/ZSMRecordPlayer"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Simon" => "18320832089@163.com" }
  s.platform      = :ios, "8.0"
  s.source        = { :git => "https://github.com/ZSMSimon/ZSMRecordPlayer.git", :tag => s.version.to_s }
  s.requires_arc  = true
  s.source_files  = "RecordPlayer/*.{h,m}"
end