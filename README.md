# RH Subscription

This Ruby Gem helps to extract information (especially repository URLs) from
your RedHat certificates. This is helpful when dealing with multiple RH subscriptions
and the requirement to figure out which certificate / which ID to use for what
repository.

## Installation

Add to your Gemfile and run the `bundle` command to install it.

```ruby
gem "rh_subscription"
```

**Requires Ruby 1.9.3 or later.**


## Usage

```ruby
require 'rh_subscription'

cert = RhSubscription::Certificate.new(
  File.read('/etc/pki/entitlement/9999999999.pem')
)
puts "Type: #{cert.type}"
puts cert.urls.list.join("\n")

puts "YES" if cert.urls.has? '/content/dist/middleware/jws/1.0/$basearch/os'
puts "YES" if cert.urls.has? [
  '/content/dist/rhel/server/6/$releasever/$basearch/ose-jbosseap/2.2/debug',
  '/content/dist/rhel/server/6/$releasever/$basearch/ose-jbosseap/2.2/os',
  '/content/dist/rhel/server/6/$releasever/$basearch/ose-jbosseap/2.2/source/SRPMS'
]

```

## Credits

The Huffman Coding has been forked and refactored from the rspec helper in
[Candlepin](https://github.com/candlepin/candlepin).

## Development

Questions or problems? Please post them on the [issue tracker](https://github.com/Thomas-Gelf/rubygem-rh-subscription).
You can contribute changes by forking the project and submitting a pull request.

This gem has been created by Thomas Gelf and is under the GPLv2 License.
