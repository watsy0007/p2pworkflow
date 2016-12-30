# -*- coding: utf-8 -*-
require 'net/http'
require 'nokogiri'
require 'alfredo'

def noko_html(url)
  uri = URI.parse(url)

  body = Net::HTTP.get(uri)
  Nokogiri::HTML(body)
end

def parse_list(url)
  html = noko_html(url)
  html.css('.g h2 a').each do |el|
    yield el.text, 'open this page in your browser', el['href'] if el.text != ''
  end
end

def parse_link(url)
  html = noko_html(url)
  sub_title = []
  link = ''
  html.css('#result p').each do |el|
    if el.text.include?('magnet')
      link = el.text.gsub('磁力链接: ', '')
      next
    end
    sub_title << el.text
  end
  yield sub_title.join(' '), link
end

def search(query)
  url = "http://www.btkiki.com/s/#{query}.html"

  workflow = Alfredo::Workflow.new
  parse_list(url) do |title, sub_title, url_link|
    parse_link url_link do |sub_title, resource_link|
      workflow << Alfredo::Item.new(
        title: title,
        subtitle: sub_title,
        arg: resource_link
      )
    end
  end

  workflow.output!
end


search(ARGV[0])

