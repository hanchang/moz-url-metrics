require 'base64'
require 'cgi'
require 'json'
require 'openssl'
require 'open-uri'

class Moz
  TITLE          = 1 # ut
  CANONICAL_URL  = 4 # uu
  SUBDOMAIN      = 8 # ufq
  ROOT_DOMAIN    = 16 # upl
  EXTERNAL_LINKS = 32 # ueid
  SUBDOMAIN_EXTERNAL_LINKS = 64 # feid
  ROOT_DOMAIN_EXTERNAL_LINKS = 128 # peid
  EQUITY_LINKS = 256 #ujid
  SUBDOMAINS_LINKING = 512 # uifq
  ROOT_DOMAINS_LINKING = 1024 # uipl
  LINKS = 2048 # uid
  SUBDOMAIN_SUBDOMAINS_LINKING = 4096 # fid
  ROOT_DOMAIN_ROOT_DOMAINS_LINKING = 8192 # pid
  # TODO: The rest...

  ALL_COLUMNS = 103079215104

  def mozRequestBatch(urls, access_id, secret_key, cols)
    expires = Time.now.to_i + 30

    # A new linefeed is necessary between your AccessID and Expires.
    string_to_sign = "#{access_id}\n#{expires}"

    # Get the "raw" or binary output of the hmac hash.
    binary_signature = OpenSSL::HMAC.digest('sha1', secret_key, string_to_sign)

    # We need to base64-encode it and then url-encode that.
    url_safe_signature = CGI::escape(Base64.encode64(binary_signature).chomp)

    # Now put your entire request together.
    # This example uses the Mozscape URL Metrics API.
    request_url = "http://lsapi.seomoz.com/linkscape/url-metrics/?Cols=#{cols}&AccessID=#{access_id}&Expires=#{expires}&Signature=#{url_safe_signature}"

    # Go and fetch the URL
    uri = URI.parse("#{request_url}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    # Put your URLS into an array and json_encode them.
    request.body = urls.to_json
    response = http.request(request)

    response.body
  end
end
