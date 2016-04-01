Pod::Spec.new do |s|
  s.name         = "SwiftPaginator"
  s.version      = "0.0.2"
  s.summary      = "SwiftPaginator is a block based Swift class that handles pagination for you."
  s.homepage     = "https://github.com/apocolipse/SwiftPaginator"
  s.source       = { :git => "https://github.com/apocolipse/SwiftPaginator.git", :tag => s.version }
  s.license      = { :type => "Free", :text => "Do whatever you want with this piece of code (commercially or free). Attribution would be nice though." }
  s.author             = { "Chris Simpson" => "apocolipse@gmail.com" }
  s.social_media_url   = "http://twitter.com/apocolipse269"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source_files  = "SwiftPaginator/*.swift"
end
