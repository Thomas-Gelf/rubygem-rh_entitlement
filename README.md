# RH Entitlement

This Ruby Gem helps to extract information (especially repository URLs) from
your RedHat entitlement certificates. This is helpful when dealing with multiple
RH subscriptions and the requirement to figure out which certificate / which ID
to use for what repository.

It can be used as a library and ships a related CLI command.

## Installation

    gem install rh_entitlement

**Requires Ruby 1.9.3 or later.**

## Usage

### CLI command

```
usage: rh-entitlement <command> [<args>]

commands:

  urls  List all repository URLs in the given certificate
  find  Find the best certificate for a given repository URL

urls
----
usage: rh-entitlement urls <cert-file>

cert-file:
  Absolute paths to an entitlement certificate file, like
  /etc/pki/entitlement/9999999999.pem

find
----
usage: rh-entitlement find <repo-url> [<cert-file>[ ...]]

repo-url:
  Relative repository URL, like
  /content/beta/rhel/server/5/$releasever/$basearch/highavailability/os

cert-file:
  One or more absolute paths to entitlement certificate files. All <numeric>.pem
  files in /etc/pki/entitlement will be used if no <cert-file> has been given
```

#### Examples

##### List repository URLs

Get all URLs from a specific entitlement certificate:

    rh-entitlement urls /etc/pki/entitlement/9999999999.pem

Sample output:

```
Type: Basic
/content/beta/rhel/server/5/$releasever/$basearch/highavailability/debug
/content/beta/rhel/server/5/$releasever/$basearch/highavailability/os
/content/beta/rhel/server/5/$releasever/$basearch/highavailability/source/SRPMS
/content/beta/rhel/server/6/$releasever/$basearch/highavailability/debug
/content/beta/rhel/server/6/$releasever/$basearch/highavailability/os
/content/beta/rhel/server/6/$releasever/$basearch/highavailability/source/SRPMS
/content/beta/rhel/server/7/$basearch/highavailability/debug
/content/beta/rhel/server/7/$basearch/highavailability/os
/content/beta/rhel/server/7/$basearch/highavailability/source/SRPMS
...
```

##### Certificate lookup

Find the correct certificate for a specific repository URL:

```sh
rh-entitlement find-cert \
  '/content/beta/rhel/server/6/$releasever/$basearch/highavailability/os' \
  /etc/pki/entitlement/*.pem
```

When a matching certificate has been found, the script exits with code 0 and
outputs the certificate path on a single line:

    /etc/pki/entitlement/9999999999.pem

In case there was no matching certificate, an error message is shown, exit code
is 1:

    ERROR: no certificate has been found for /content/beta/rhel/...

### As a library

Add `rh_entitlement` to your Gemfile and run the `bundle` command to install it:

```ruby
gem "rh_entitlement"
```

#### Sample code

```ruby
require 'rh_entitlement'

cert = RhEntitlement::Certificate.new(
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

Questions or problems? Please post them on the [issue tracker](https://github.com/Thomas-Gelf/rubygem-rh_entitlement/issues).
You can contribute changes by forking the project and submitting a pull request.

This gem has been created by Thomas Gelf and is under the GPLv2 License.
