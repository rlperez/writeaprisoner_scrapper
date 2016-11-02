require 'nokogiri'
require 'restclient'
require 'mechanize'
require 'csv'

def main
  agent = Mechanize.new
  agent.history_added = proc { sleep 0.5 }

  ('A'..'Z').each do |char|
    page = agent.get("http://www.writeaprisoner.com/Classic/byAlpha_c.aspx?sL=#{char}")
    links = links(page)
    CSV.open('output.csv', 'w') do |c|
      c << output_header
      links.each do |profile|
        vals = profile.css('.nsmText').map { |p| sanitize_page(p) }
        c << vals.to_csv
      end
    end
  end
end

def sanitize_page(page)
  page.squeeze.gsub("\r\n", '').strip
end

def output_header(profile)
  profile.css('.nsmTitle').map { |p| p.content.gsub("\r\n", '').delete(':').strip }
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
