Pod::Spec.new do |spec|
  spec.name         = "AraratOrNot"
  spec.version      = "0.0.1"
  spec.summary      = "Detect if there is Ararat in the image or not"
  spec.description  = <<-DESC
This CocoaPods Library helps you to detect if there is Ararat in the image or not.
                   DESC

  spec.homepage     = "https://iararat.am/"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Sevak Soghoyan" => "sevak.soghoyan@smartclick.ai" }
  spec.ios.deployment_target = "11.0"
  spec.swift_version = "4.2"

  spec.source       = { :git => "https://github.com/smartclick/ararat_or_not_ios.git", :tag => "#{spec.version}" }

  spec.source_files  = "AraratOrNot","AraratOrNot/**/*.{h,m,swift}"

end
