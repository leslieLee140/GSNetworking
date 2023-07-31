Pod::Spec.new do |s|
  s.name         = "GSNetworking"
  s.version      = "1.0.0"
  s.summary      = "GSNetworking"
  s.description  = "GSNetworking"
  s.homepage     = "https://github.com/leslieLee140/GSNetworking.git"
  s.social_media_url   = "www.baicu.com"
  s.license= { :type => "MIT", :file => "LICENSE" }
  s.author       = { "leslieLee" => "lisl@xiaoji.com" }
  s.source       = { :git => "https://github.com/leslieLee140/GSNetworking.git", :tag => s.version }
  s.source_files = "GSNetworking/GSNetworking/*.{h,m}"
  s.ios.deployment_target = '13.0'
  s.frameworks   = 'UIKit'
  s.requires_arc = true

end