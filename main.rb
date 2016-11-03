require 'nokogiri'
require 'restclient'
require 'mechanize'
require 'csv'

def main
  agent = Mechanize.new
  agent.history_added = proc { sleep 0.5 }
  profiles = []
  ('A'..'Z').each do |char|
    page = agent.get("http://www.writeaprisoner.com/Classic/byAlpha_c.aspx?sL=#{char}")
    links = links(page)
    profiles << profile_data(links)
  end
  write_csv(profiles)
end

def profile_data(links)
  profiles = []
  links.each do |link|
    profile = link.click
    keys = profile_keys(profile) << 'Address'
    vals = profile_vals(link) << address(profile)
    profiles << keys.zip(vals)
  end
  profiles
end

def write_csv(profiles)
  CSV.open('output_file.csv', 'w') do |c|
    c << profiles.first[0].map{ |h| h[0] }
    profiles.each do |profile|
      c << profile.map{ |p| h[1] }
    end
  end
end

def address(profile)
  profile.css('#CPH_Content_LabelHeader').children.find(&:text).children.children.map(&:text).join('|')
end

def profile_keys(profile)
  profile.css('.nsmTitle').map { |p| p.content.delete("\r\n", '').delete(':').strip }
end

def profile_vals(profile)
  profile.css('.nsmText').map { |p| sanitize_page(p) }
end

def sanitize_page(page)
  page.squeeze.gsub("\r\n", '').strip
end

def links(page)
  page.links_with(css: 'div>div>div>div>#CPH_Content_ListFemale_itemPlaceholderContainer>div>a') +
    page.links_with(css: 'div>div>div>div>#CPH_Content_ListMale_itemPlaceholderContainer>div>a')
end

def random_user_agent
  user_agents = [
    'Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US) AppleWebKit/534.4 (KHTML, like Gecko) Chrome/6.0.481.0 Safari/534.4',
    'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0',
    'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:22.0) Gecko/20130328 Firefox/22.0',
    'Mozilla/5.0 (X11; U; Linux amd64; rv:5.0) Gecko/20100101 Firefox/5.0 (Debian)',
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36 OPR/32.0.1948.25',
    'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0',
    'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
  ].freeze
  user_agents.sample
end
