Pod::Spec.new do |s|
  s.name                  = 'ThirdPod'
  s.version               = '1.0.0'
  s.summary               = 'A short description of ThirdPod'
  s.homepage              = '...'
  s.license               = 'MIT'
  s.author                = { 'Omar Zuniga' => 'omarzl@hotmail.es' }
  s.source                = { git: 'git@some.git', tag: s.version.to_s }
  s.source_files          = 'Sources/**/*.swift'
  s.ios.deployment_target = '16.0'
  s.dependency 'FourthPod'
end
