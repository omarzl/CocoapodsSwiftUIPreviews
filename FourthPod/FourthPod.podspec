Pod::Spec.new do |s|
  s.name                  = 'FourthPod'
  s.version               = '1.0.0'
  s.summary               = 'A short description of FourthPod'
  s.homepage              = '...'
  s.license               = 'MIT'
  s.author                = { 'Omar Zuniga' => 'omarzl@hotmail.es' }
  s.source                = { git: 'git@some.git', tag: s.version.to_s }
  s.source_files          = 'Sources/**/*.swift'
  s.ios.deployment_target = '17.0'
end
