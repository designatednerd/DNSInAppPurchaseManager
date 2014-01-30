Pod::Spec.new do |s|
  s.name         = "DNSInAppPurchaseManager"
  s.version      = '1.0'
  s.summary      = "DNSInAppPurchaseManager - Internal Repo"
  s.description  = <<-DESC
                    Internal repo for Designated Nerd Software.

                    * If you see this elsewhere...
                    * I fucked up. 
                   DESC
  s.homepage     = "http://www.designatednerd.com"
  s.license      = 'MIT'
  s.author       = { "Ellen Shapiro" => "designatednerd@gmail.com" }
  s.source       = { :git => "https://designatednerd@bitbucket.org/designatednerd/dnsinapppurchasemanager.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Library'
end
