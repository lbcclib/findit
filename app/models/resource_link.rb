# frozen_string_literal: true

PROXY_PREFIX = 'https://ezproxy.libweb.linnbenton.edu/login?url='

# Creates links that bring users to resources
class ResourceLink
  def initialize(unproxied_url)
    @proxied_url = PROXY_PREFIX + unproxied_url
  end

  def to_s
    @proxied_url
  end
end
