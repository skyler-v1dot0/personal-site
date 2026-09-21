#!/usr/bin/env ruby
# Fetches RSS/Atom feeds listed in _data/news_sources.yml and writes the
# combined, sorted result to _data/news.yml for the /news/ page to render.
#
# Run manually with: ruby scripts/fetch_news.rb
# Run on a schedule by .github/workflows/news.yml

require "net/http"
require "uri"
require "rexml/document"
require "time"
require "yaml"

ROOT = File.expand_path("..", __dir__)
SOURCES_FILE = File.join(ROOT, "_data", "news_sources.yml")
OUTPUT_FILE = File.join(ROOT, "_data", "news.yml")

PER_SOURCE_LIMIT = 15
TOTAL_LIMIT = 40
USER_AGENT = "skyverse-news-bot/1.0 (+https://skyverse.cloud)"

def fetch_body(url, redirects_left = 5)
  raise "too many redirects for #{url}" if redirects_left.zero?

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = (uri.scheme == "https")
  http.open_timeout = 10
  http.read_timeout = 15

  request = Net::HTTP::Get.new(uri.request_uri)
  request["User-Agent"] = USER_AGENT

  response = http.request(request)

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    fetch_body(response["location"], redirects_left - 1)
  else
    raise "HTTP #{response.code} fetching #{url}"
  end
end

def text_at(element, xpath)
  node = REXML::XPath.first(element, xpath)
  return nil if node.nil?

  (node.text || "").strip
end

def parse_items(xml, source_name)
  doc = REXML::Document.new(xml)
  root = doc.root
  raise "empty or invalid XML" if root.nil?

  items = []

  if root.name == "rss"
    REXML::XPath.each(doc, "//channel/item") do |item|
      title = text_at(item, "title")
      link = text_at(item, "link")
      pub_date = text_at(item, "pubDate")
      next unless title && link

      published = begin
        pub_date ? Time.parse(pub_date) : Time.now
      rescue ArgumentError
        Time.now
      end

      items << { "title" => title, "url" => link, "source" => source_name, "published" => published }
    end
  elsif root.name == "feed"
    REXML::XPath.each(doc, "//*[local-name()='entry']") do |entry|
      title = text_at(entry, "*[local-name()='title']")
      link_node = REXML::XPath.first(entry, "*[local-name()='link']")
      link = link_node ? link_node.attributes["href"] : nil
      updated = text_at(entry, "*[local-name()='updated']") || text_at(entry, "*[local-name()='published']")
      next unless title && link

      published = begin
        updated ? Time.parse(updated) : Time.now
      rescue ArgumentError
        Time.now
      end

      items << { "title" => title, "url" => link, "source" => source_name, "published" => published }
    end
  else
    raise "unrecognized feed format (root=#{root.name})"
  end

  items.sort_by { |i| -i["published"].to_i }.first(PER_SOURCE_LIMIT)
end

sources = YAML.safe_load(File.read(SOURCES_FILE)) || []
all_items = []

sources.each do |source|
  name = source["name"]
  url = source["url"]

  begin
    body = fetch_body(url)
    items = parse_items(body, name)
    warn "warning: no items parsed from #{name} (#{url})" if items.empty?
    all_items.concat(items)
  rescue StandardError => e
    warn "warning: failed to fetch/parse #{name} (#{url}): #{e.message}"
  end
end

if all_items.empty?
  warn "error: no news items fetched from any source; leaving existing _data/news.yml untouched"
  exit 1
end

all_items = all_items.sort_by { |i| -i["published"].to_i }.first(TOTAL_LIMIT)

output = {
  "updated_at" => Time.now.utc.iso8601,
  "items" => all_items.map do |i|
    {
      "title" => i["title"],
      "url" => i["url"],
      "source" => i["source"],
      "published" => i["published"].utc.iso8601,
    }
  end,
}

File.write(OUTPUT_FILE, output.to_yaml)
puts "wrote #{all_items.size} items to #{OUTPUT_FILE}"
