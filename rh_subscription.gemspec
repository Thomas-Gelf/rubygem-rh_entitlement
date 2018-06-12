Gem::Specification.new do |s|
  s.name        = 'rh_subscription'
  s.version     = '0.1.0'
  s.date        = '2018-06-12'
  s.summary     = 'RH Subscription Certificates'
  s.description = 'Helper library allowing one to deal with RH subscription certs'
  s.executables << 'rh-subscription-urls'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.authors     = ['Thomas Gelf']
  s.email       = 'thomas@gelf.net'
  s.homepage    =
      'https://github.com/Thomas-Gelf/rubygem-rh_subscription'
  s.license     = 'GPLv2'
end
