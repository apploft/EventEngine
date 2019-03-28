Pod::Spec.new do |s|

  s.name         = "EventEngine"
  s.version      = "0.0.1"
  s.summary      = "A simple framework to count events in an app e.g. for score based rating dialog apperance."
  s.description  = <<-DESC
                   A simple framework to count events in an app. An event is basically just a named counter an 
                   can be used to implement a score engine which counts different events. These events can for 
                   instance be used to make score based decisions like showing a rating dialog when a certain 
                   score has been reached.
                   DESC

  s.homepage     = "https://github.com/apploft/EventEngine"
  s.swift_versions = ['4.1', '5.0']
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Tino Rachui" => "tino.rachui@apploft.de" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/apploft/EventEngine.git", :tag => s.version.to_s }
  s.source_files  = "EventEngine", "EventEngine/**/*.{h,m,swift}"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
end
