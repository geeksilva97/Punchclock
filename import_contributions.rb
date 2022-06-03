require 'uri'
require 'net/http'
require 'json'

engineers = []
repositories = []
current_date = Time.now.strftime("%Y-%m-%d")

uri = URI('https://api.github.com/search/issues?q=author:wenderjean+type:pr+created:2021-02-14')
# uri = URI('https://api.github.com/search/issues?q=author:wenderjean+type:pr+created:2021-02-14')
res = Net::HTTP.get_response(uri)
# puts res.body if res.is_a?(Net::HTTPSuccess)
items = JSON.parse(res.body)["items"]

puts items
