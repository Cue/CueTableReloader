Pod::Spec.new do |s|
  s.name     = 'CueTableReloader'
  s.version  = '0.0.1'
  s.license  = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.summary  = 'CueTableReloader'
  s.homepage = 'https://github.com/Cue/CueTableReloader'
  s.author   = { 'Aaron Sarazan' => 'https://github.com/Cue/CueTableReloader' }
  s.source   = { :git => 'https://github.com/Cue/CueTableReloader.git', :commit => 'eff314d703e9e8e57b07c5026af722bde9a3e94b' }
  s.description = 'A really handy class that automatically figures out insertions, deletions, moves, and reloads in UITableView based on unique item keys.'
  s.platform = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.source_files = 'CueTableReloader/**/*.{h,m}'
  s.public_header_files = 'CueTableReloader/**/*.h'
  s.framework = 'UIKit', 'QuartzCore'
  s.requires_arc = true
end
