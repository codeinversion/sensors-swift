Pod::Spec.new do |spec|

    spec.name                   = 'SwiftySensors'
    spec.version                = '0.4.0'
    spec.summary                = 'BLE Fitness Sensors Communication Utilities for iOS and OSX'

    spec.homepage               = 'https://github.com/kinetic-fit/sensors-swift'
    spec.license                = { :type => 'MIT', :file => 'LICENSE' }    
    spec.author                 = { 'Kinetic' => 'admin@kinetic.fit' }
    
    spec.ios.deployment_target  = '8.2'
    #spec.osx.deployment_target  = '10.11'

    spec.source                 = { :git => 'https://github.com/kinetic-fit/sensors-swift.git',
                                    :tag => spec.version.to_s,
                                    :submodules => true }
    spec.source_files           = 'Sources/**/*.swift'
    spec.pod_target_xcconfig    = { 'SWIFT_VERSION' => '4.0' }

    spec.dependency     'Signals', '~> 5.0'


    spec.subspec 'Serializers' do |serial|
        serial.source_files     = 'Sources/*Serializer.swift', 'Sources/Operators.swift'
    end
    
end
