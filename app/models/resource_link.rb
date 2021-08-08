# frozen_string_literal: true

PROXY_PREFIX = 'https://ezproxy.libweb.linnbenton.edu/login?url='


# Creates links that bring users to resources
class ResourceLink
  delegate :to_s, to: :@proxied_url
  def initialize(unproxied_url)
    @proxied_url = "#{PROXY_PREFIX}#{unproxied_url}"
  end
end
