module RhEntitlement
  class Lookup
    def initialize
      @entitlements = {}
    end

    def add_path(path)
      return unless File.directory? path
      Dir.glob("#{path}/*.pem").grep(/\/\d+\.pem$/).each do |filename|
        add_certificate_file(filename)
      end
      self
    end

    def add_certificate_file(filename)
      add_cert(File.basename(filename).sub('.pem', ''), File.read(filename))
    end

    def entitlements
      add_path('/etc/pki/entitlement') if @entitlements.empty?
      @entitlements
    end

    def add_cert(key, cert)
      @entitlements[key] = RhEntitlement::Certificate.new(cert)
      self
    end

    def add_certs(certs)
      certs.each do |key, cert|
        add_cert key, cert
      end
      self
    end

    def find_url(url)
      urls = self.class.make_url_variants(url)
      entitlements.each do |key, entitlement|
        urls.each do |search|
          return key if entitlement.urls.has?(search)
        end
      end

      nil
    end

    def self.make_url_variants(url)
      urls = [url]
      if url.match(/\dServer/)
        urls.push(url.gsub(/\dServer/, '$releasever'))
      else
        urls.push(url.gsub('$releasever', '6Server'))
        urls.push(url.gsub('$releasever', '7Server'))
      end
    end

    def self.instance
      @@instance ||= new
    end
  end
end
