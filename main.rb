require 'nokogiri'
require 'restclient'
require 'mechanize'

def main
  agent = Mechanize.new
  agent.history_added = Proc.new { sleep 0.5 }

  ('A'..'Z').each do |c|
    page = agent.get("http://www.writeaprisoner.com/Classic/byAlpha_c.aspx?sL=#{c}")
    page_range = page_range(page)
  end
end

def pages_by_letter
  pages = []

  ('A'..'Z').each do |c|
    pages << sanitize_page(Nokogiri::HTML(RestClient.get("http://www.writeaprisoner.com/inmate-profiles/byAlpha.aspx?sL=#{c}",
                                                         user_agent: random_user_agent)).text)
    sleep(rand(1..10))
  end

  pages
end

def page_range(page)
  int_pager = int_paginator(page.css("span#CPH_Content_DataPager2").text)
  start_index = int_pager[1].to_i
  last_index = int_pager[2].to_i
  (start_index..last_index)
end

def int_paginator(page)
  number_paginator_pattern = /Viewing\sPage\s(\d{1})\D*of\D*(\d+)/
  page.match(number_paginator_pattern)
end

def sanitize_page(page)
  page.squeeze.gsub("\r\n", '')
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
