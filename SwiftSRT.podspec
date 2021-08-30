Pod::Spec.new do |s|  
    s.name              = 'SwiftSRT'
    s.version           = '0.1.0'
    s.summary           = 'Swift bindings for SRT. Maintained by Eyevinn Technology.'
    s.homepage          = 'https://github.com/Eyevinn/swift-srt'
    s.author            = { 'Jesper Lundqvist' => 'jesper.lundqvist@eyevinn.se' }
    s.license           = { :type => "MIT", :text => "MIT License" }

    s.cocoapods_version = '>= 1.9'

    s.source            = { :git => 'https://github.com/Eyevinn/swift-srt.git', :tag => "v#{s.version}" } 
    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    s.vendored_frameworks = 'Frameworks/SwiftSRT.xcframework'
end 
