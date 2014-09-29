Pod::Spec.new do |s|
  s.name         = "DNSInAppPurchaseManager"
  s.version      = '1.1.1'
  s.summary      = "DNSInAppPurchaseManager"
  s.description  = <<-DESC
                   A simple In-App purchase manager for iOS.
                   DESC
  s.homepage     = "http://www.designatednerd.com"
  s.license      = 'MIT'
  s.author       = { "Ellen Shapiro" => "designatednerd@gmail.com" }
  s.source       = { :git => "https://github.com/designatednerd/DNSInAppPurchaseManager.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Library'
end
