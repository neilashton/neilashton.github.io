#!/usr/bin/env ruby
# frozen_string_literal: true

# Apple intermittently returns HTTP 500 when its episode pages are checked in
# parallel. Validate every configured episode URL with one Lookup API request
# instead of sending a burst of requests to the public podcast pages.

require "json"
require "net/http"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
APPLE_LINKS_FILE = File.join(ROOT, "_data", "podcast_apple.yml")
SHOW_ID = "1745076065"
LOOKUP_URL = "https://itunes.apple.com/lookup?id=#{SHOW_ID}&entity=podcastEpisode&limit=200&country=gb"
MAX_ATTEMPTS = 3

def fetch_lookup
  uri = URI(LOOKUP_URL)
  attempts = 0

  begin
    attempts += 1
    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "NeilAshtonPodcastSite/1.0 (+https://neilashton.co.uk)"

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: true,
      open_timeout: 10,
      read_timeout: 30,
    ) { |http| http.request(request) }

    raise "Apple Lookup API returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError, IOError, SystemCallError, Timeout::Error, RuntimeError => error
    raise if attempts >= MAX_ATTEMPTS

    warn "Apple Lookup API attempt #{attempts} failed: #{error.message}; retrying"
    sleep(2**(attempts - 1))
    retry
  end
end

configured_links = YAML.safe_load(File.read(APPLE_LINKS_FILE), aliases: false)
unless configured_links.is_a?(Hash) && !configured_links.empty?
  warn "#{APPLE_LINKS_FILE} must contain at least one episode link"
  exit 1
end

lookup_results = fetch_lookup.fetch("results", [])
episodes_by_id = lookup_results
  .select { |result| result["wrapperType"] == "podcastEpisode" }
  .to_h { |result| [result.fetch("trackId").to_s, result] }

errors = []
seen_episode_ids = {}

configured_links.each do |episode_key, url|
  begin
    uri = URI(url)
    query = URI.decode_www_form(uri.query.to_s).to_h
    episode_id = query["i"]

    unless uri.scheme == "https" && uri.host == "podcasts.apple.com" && uri.path.end_with?("/id#{SHOW_ID}") && episode_id
      errors << "#{episode_key}: malformed Apple Podcasts episode URL"
      next
    end

    if seen_episode_ids.key?(episode_id)
      errors << "#{episode_key}: duplicates episode ID #{episode_id} used by #{seen_episode_ids[episode_id]}"
      next
    end
    seen_episode_ids[episode_id] = episode_key

    lookup_episode = episodes_by_id[episode_id]
    unless lookup_episode
      errors << "#{episode_key}: episode ID #{episode_id} is absent from Apple's Lookup API"
      next
    end

    canonical_url = lookup_episode["trackViewUrl"]
    errors << "#{episode_key}: expected #{canonical_url}, found #{url}" unless canonical_url == url
  rescue URI::InvalidURIError, TypeError => error
    errors << "#{episode_key}: invalid URL (#{error.message})"
  end
end

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Validated #{configured_links.length} Apple Podcasts episode links against Apple's Lookup API."
