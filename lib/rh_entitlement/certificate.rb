require 'openssl'

module RhEntitlement
  class Certificate
    OID_URLS = '1.3.6.1.4.1.2312.9.7'
    OID_TYPE = '1.3.6.1.4.1.2312.9.8'

    def initialize(cert)
      @x509 = OpenSSL::X509::Certificate.new(cert)
    end

    def urls
      @urls ||= RhEntitlement::CertificateUrls.new(extension OID_URLS)
    end

    def type
      extension OID_TYPE
    end

    def extension(id)
      extensions = raw_extensions
      return nil unless extensions[id]

      asn1 = OpenSSL::ASN1.decode(extensions[id])
      der_body(asn1.value[1])
    end

    private

    def der_body(der)
      body = nil
      OpenSSL::ASN1.traverse(der) do |depth, offset, header_len, length, constructed, tag_class, tag|
        body = der.value[header_len, length]
      end
      body
    end

    def raw_extensions
      @raw_extensions ||= Hash[@x509.extensions.collect { |ext|
        [ext.oid, ext.to_der]
      }]
    end
  end
end
