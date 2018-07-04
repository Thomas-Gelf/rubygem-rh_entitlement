Gem::Specification.new do |s|
  s.name        = 'rh_entitlement'
  s.version     = '0.5.1'
  s.date        = '2018-07-04'
  s.summary     = 'RH Entitlement Certificates'
  s.description = 'Helper library allowing one to deal with RH entitlement certs'
  s.executables << 'rh-entitlement'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.authors     = ['Thomas Gelf']
  s.email       = 'thomas@gelf.net'
  s.homepage    =
      'https://github.com/Thomas-Gelf/rubygem-rh_entitlement'
  s.license     = 'GPL-2.0'
end
