#!/usr/bin/env ruby
# frozen_string_literal: true

# Generates the site's first-party podcast episode pages from the public RSS
# feed while retaining the curated titles in _data/podcast_seasons.yml.
# Add each new episode to that data file, then run:
#   bundle exec ruby scripts/sync_podcast_episodes.rb

require "cgi"
require "date"
require "fileutils"
require "json"
require "open-uri"
require "rexml/document"
require "rexml/xpath"
require "time"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
RSS_URL = "https://anchor.fm/s/10a5bf2d8/podcast/rss"
PROFILE_URL = "https://creators.spotify.com/pod/profile/neilashton"
EPISODES_DIR = File.join(ROOT, "_podcast_episodes")
TRANSCRIPTS_DIR = File.join(ROOT, "assets", "transcripts")

SECTION_MARKERS = [
  "Main Topics:",
  "Main Topics",
  "Key topics",
  "Key Topics",
  "Papers",
  "Links",
  "Chapters",
  "Timestamps",
  "Keywords",
].freeze

def fetch(url)
  URI.open(
    url,
    "User-Agent" => "NeilAshtonPodcastSite/1.0 (+https://neilashton.co.uk)",
    read_timeout: 30,
  ).read.force_encoding(Encoding::UTF_8).scrub
end

def child(element, expanded_name)
  element.elements.to_a.find { |candidate| candidate.expanded_name == expanded_name }
end

def slugify(text)
  text
    .gsub("&", " and ")
    .unicode_normalize(:nfkd)
    .encode("ASCII", invalid: :replace, undef: :replace, replace: "")
    .downcase
    .gsub(/[^a-z0-9]+/, "-")
    .gsub(/\A-+|-+\z/, "")
end

def plain_text(html)
  with_breaks = html
    .gsub(/<br\s*\/?>/i, "\n")
    .gsub(%r{</(?:p|li|h[1-6])>}i, "\n\n")
  CGI.unescapeHTML(with_breaks.gsub(/<[^>]+>/, " "))
    .gsub("\u00A0", " ")
    .gsub("\r", "")
    .gsub(/[ \t]+/, " ")
    .gsub(/ *\n */, "\n")
    .gsub(/\n{3,}/, "\n\n")
    .strip
end

def normalise_sentence_spacing(text)
  text
    .gsub(/([.!?])(?=[A-Z])/, "\\1 ")
    .gsub(/([a-z0-9)])(?=(?:Main Topics|Key topics|Papers|Links|Chapters|Timestamps|Keywords)\b)/, "\\1 ")
    .gsub(/\s+/, " ")
    .strip
end

def overview_text(text)
  clean = text.sub(/\ASummary\s*/i, "")
  marker_positions = SECTION_MARKERS.map { |marker| clean.index(marker) }.compact
  url_position = clean.index(%r{https?://})
  cut_position = (marker_positions + [url_position]).compact.min || clean.length
  overview = normalise_sentence_spacing(clean[0...cut_position])

  if url_position && cut_position == url_position
    sentence_endings = overview.enum_for(:scan, /[.!?](?=\s|[A-Z])/).map { Regexp.last_match.end(0) }
    last_ending = sentence_endings.last
    overview = overview[0...last_ending].strip if last_ending && overview.length - last_ending > 80
  end

  overview
end

def description_for_meta(text, max_length = 158)
  normalised = normalise_sentence_spacing(text)
  return normalised if normalised.length <= max_length

  shortened = normalised[0...max_length].sub(/\s+\S*\z/, "")
  "#{shortened}…"
end

def paragraph_html(text)
  sentences = normalise_sentence_spacing(text).split(/(?<=[.!?])\s+/)
  paragraphs = []
  current = []
  current_length = 0

  sentences.each do |sentence|
    if current.any? && (current.length >= 3 || current_length + sentence.length > 620)
      paragraphs << current.join(" ")
      current = []
      current_length = 0
    end
    current << sentence
    current_length += sentence.length
  end
  paragraphs << current.join(" ") if current.any?

  paragraphs.map { |paragraph| "    <p>#{CGI.escapeHTML(paragraph)}</p>" }.join("\n")
end

def clean_url(raw_segment)
  token = raw_segment.strip.split(/\s/, 2).first.to_s
  return nil if token.empty?

  exact_patterns = [
    %r{\Ahttps?://arxiv\.org/abs/\d{4}\.\d{4,5}(?:v\d+)?}i,
    %r{\Ahttps?://scholar\.google\.com/citations\?[^\s]*?user=[A-Za-z0-9_-]{12}}i,
    %r{\Ahttps?://drive\.google\.com/file/d/[A-Za-z0-9_-]+/view}i,
    %r{\Ahttps?://(?:www\.)?youtube\.com/watch\?v=[A-Za-z0-9_-]{11}}i,
    %r{\Ahttps?://youtu\.be/[A-Za-z0-9_-]{11}}i,
    %r{\Ahttps?://www\.youtube\.com/@VinuesaLab}i,
    %r{\Ahttps?://x\.com/[A-Za-z0-9_]+}i,
    %r{\Ahttps?://www\.amazon\.(?:com|co\.uk)/[^\s]+?/dp/[A-Z0-9]+}i,
    %r{\Ahttps?://proceedings\.mlr\.press/[A-Za-z0-9_./-]+\.html}i,
    %r{\Ahttps?://scai\.sorbonne-universite\.fr/news/paola-cinnella-new-director}i,
    %r{\Ahttps?://aero\.engin\.umich\.edu/people/ricardo-vinuesa/}i,
    %r{\Ahttps?://www\.flowthermolab\.com/courses/ai-ml-for-fluids/}i,
    %r{\Ahttps?://www\.vinuesalab\.com/}i,
  ]
  exact_patterns.each do |pattern|
    match = token.match(pattern)
    return match[0] if match
  end

  token = token.sub(/(?:Chapters|Timestamps|Keywords|Papers|Links).*\z/i, "")
  token = token.sub(/(?<=[0-9a-z\/.])(?=[A-Z][a-z]{2,}).*\z/, "")
  token = token.sub(/[),.;:]+\z/, "")
  token if token.match?(%r{\Ahttps?://[^/]+\S*\z})
end

def fallback_link_label(url)
  uri = URI.parse(url)
  host = uri.host.to_s.sub(/\Awww\./, "")
  case host
  when "arxiv.org"
    "arXiv #{uri.path.split("/").last}"
  when "doi.org"
    "DOI #{uri.path.sub(%r{\A/}, "")}"
  when "youtube.com", "youtu.be"
    "YouTube"
  else
    path = CGI.unescape(uri.path.to_s).sub(%r{/\z}, "").split("/").last
    path && !path.empty? ? "#{host}: #{path.tr("-_", " ")}" : host
  end
rescue URI::InvalidURIError
  url
end

def clean_link_label(segment, url)
  label = segment
    .split(/\n+/)
    .last
    .to_s
    .sub(/.*(?:Papers|Links)\s*/i, "")
    .sub(/\A[-–—:,\s]+/, "")
    .gsub(/\s+/, " ")
    .strip

  if label.split.length > 24
    sentence_parts = label.split(/(?<=[.!?])\s+/)
    label = sentence_parts.last.to_s.strip
  end

  label = fallback_link_label(url) if label.empty? || label.length > 190
  label
end

def extract_links(text)
  starts = text.enum_for(:scan, %r{https?://}).map { Regexp.last_match.begin(0) }
  previous_url_end = 0
  links = []

  starts.each_with_index do |start_position, index|
    next_start = starts[index + 1] || text.length
    raw_segment = text[start_position...next_start]
    url = clean_url(raw_segment)
    next unless url

    label_segment = text[previous_url_end...start_position]
    label = clean_link_label(label_segment, url)
    links << { "url" => url, "label" => label }
    previous_url_end = start_position + url.length
  end

  links.uniq { |link| link["url"] }
end

def extract_chapters(text)
  timestamp_matches = []
  text.to_enum(:scan, /(?<![\d:])(?:\d{1,2}:)?\d{2}:\d{2}(?![\d:])/).each do
    match = Regexp.last_match
    timestamp_matches << {
      "time" => match[0],
      "start" => match.begin(0),
      "finish" => match.end(0),
    }
  end

  timestamp_matches.map.with_index do |match, index|
    next_start = timestamp_matches[index + 1]&.fetch("start") || text.length
    label = text[match["finish"]...next_start]
      .sub(/\A[\s:–—-]+/, "")
      .sub(%r{https?://.*\z}m, "")
      .sub(/(?:Links|Keywords|Papers)\b.*\z/m, "")
      .gsub(/\s+/, " ")
      .strip
    next if label.empty? || label.length > 220

    { "time" => match["time"], "label" => label }
  end.compact
end

def duration_iso(duration)
  parts = duration.to_s.split(":").map(&:to_i)
  hours, minutes, seconds = case parts.length
  when 3 then parts
  when 2 then [0, parts[0], parts[1]]
  else [0, 0, parts[0] || 0]
  end

  value = "PT"
  value += "#{hours}H" if hours.positive?
  value += "#{minutes}M" if minutes.positive?
  value += "#{seconds}S"
  value
end

def seconds_from_timestamp(timestamp)
  hours, minutes, seconds = timestamp.tr(",", ".").split(":").map(&:to_f)
  (hours * 3600) + (minutes * 60) + seconds
end

def display_timestamp(seconds)
  total = seconds.to_i
  hours = total / 3600
  minutes = (total % 3600) / 60
  remainder = total % 60
  hours.positive? ? format("%d:%02d:%02d", hours, minutes, remainder) : format("%d:%02d", minutes, remainder)
end

def transcript_paragraphs(srt)
  cues = srt.gsub("\r\n", "\n").split(/\n{2,}/).map do |block|
    lines = block.lines.map(&:strip)
    timing_index = lines.index { |line| line.include?("-->") }
    next unless timing_index

    start_time = lines[timing_index].split("-->").first.strip
    cue_text = lines[(timing_index + 1)..]
      .join(" ")
      .gsub(/<[^>]+>/, "")
      .gsub(/\s+/, " ")
      .strip
    next if cue_text.empty?

    { "start" => seconds_from_timestamp(start_time), "text" => cue_text }
  end.compact

  groups = []
  current = nil
  cues.each do |cue|
    if current.nil? || current["text"].length >= 620 || cue["start"] - current["start"] >= 48
      groups << current if current
      current = { "start" => cue["start"], "text" => cue["text"] }
    else
      current["text"] = "#{current["text"]} #{cue["text"]}"
    end
  end
  groups << current if current
  groups
end

def normalise_transcript_srt(srt)
  srt
    .gsub("\r\n", "\n")
    .gsub(/[ \t]+$/, "")
    .sub(/\n*\z/, "\n")
end

def body_html(overview:, links:, chapters:, transcript:, transcript_path:)
  sections = []
  sections << <<~HTML.chomp
    <section class="episode-section" aria-labelledby="episode-overview">
      <h2 id="episode-overview">Episode overview</h2>
      <div class="episode-overview">
    #{paragraph_html(overview)}
      </div>
    </section>
  HTML

  if chapters.any?
    items = chapters.map do |chapter|
      <<~HTML.chomp
        <li>
          <span class="episode-chapter-time">#{CGI.escapeHTML(chapter["time"])}</span>
          <span>#{CGI.escapeHTML(chapter["label"])}</span>
        </li>
      HTML
    end.join("\n")
    sections << <<~HTML.chomp
      <section class="episode-section" aria-labelledby="episode-chapters">
        <h2 id="episode-chapters">Chapters</h2>
        <ol class="episode-chapters">
      #{items}
        </ol>
      </section>
    HTML
  end

  if links.any?
    items = links.map do |link|
      host = URI.parse(link["url"]).host.to_s.sub(/\Awww\./, "")
      <<~HTML.chomp
        <li>
          <a href="#{CGI.escapeHTML(link["url"])}" rel="external noopener">
            #{CGI.escapeHTML(link["label"])}
            <span class="episode-reference-domain">#{CGI.escapeHTML(host)}</span>
          </a>
        </li>
      HTML
    end.join("\n")
    sections << <<~HTML.chomp
      <section class="episode-section" aria-labelledby="episode-references">
        <h2 id="episode-references">References and links</h2>
        <ul class="episode-references">
      #{items}
        </ul>
      </section>
    HTML
  end

  if transcript
    transcript_rows = transcript_paragraphs(transcript).map do |paragraph|
      <<~HTML.chomp
        <p>
          <span class="transcript-timestamp">#{display_timestamp(paragraph["start"])}</span>
          <span>#{CGI.escapeHTML(paragraph["text"])}</span>
        </p>
      HTML
    end.join("\n")
    sections << <<~HTML.chomp
      <section class="episode-section" aria-labelledby="episode-transcript">
        <h2 id="episode-transcript">Transcript</h2>
        <p class="episode-transcript-intro">
          This transcript was generated by Spotify and may contain errors.
          <a href="#{transcript_path}" download>Download the original SRT file</a>.
        </p>
        <div class="episode-transcript">
      #{transcript_rows}
        </div>
      </section>
    HTML
  else
    sections << <<~HTML.chomp
      <section class="episode-section" aria-labelledby="episode-transcript">
        <h2 id="episode-transcript">Transcript</h2>
        <p class="episode-transcript-unavailable">A public transcript is not currently available for this episode.</p>
      </section>
    HTML
  end

  sections.join("\n\n")
end

seasons = YAML.load_file(File.join(ROOT, "_data", "podcast_seasons.yml"))
curated = seasons.each_with_object({}) do |season, result|
  season.fetch("episodes").each do |episode|
    result[[season.fetch("number").to_i, episode.fetch("number").to_i]] = episode
  end
end

rss = REXML::Document.new(fetch(RSS_URL))
rss_episodes = REXML::XPath.match(rss, "/rss/channel/item").map do |item|
  creator_url = item.elements["link"]&.text.to_s.strip
  rss_title = item.elements["title"]&.text.to_s.strip
  title_numbers = rss_title.match(/\AS(\d+)\s*,?\s*EP(\d+)/i)
  season_number = child(item, "itunes:season")&.text.to_i
  episode_number = child(item, "itunes:episode")&.text.to_i
  season_number = title_numbers[1].to_i if season_number.zero? && title_numbers
  episode_number = title_numbers[2].to_i if episode_number.zero? && title_numbers
  {
    "rss_title" => rss_title,
    "description_html" => item.elements["description"]&.text.to_s,
    "creator_url" => creator_url,
    "anchor_id" => creator_url[/-(e[a-z0-9]+)\z/i, 1],
    "guid" => item.elements["guid"]&.text.to_s.strip,
    "published_at" => Time.rfc2822(item.elements["pubDate"].text).utc.iso8601,
    "audio_url" => item.elements["enclosure"]&.attributes&.[]("url").to_s,
    "transcript_url" => child(item, "podcast:transcript")&.attributes&.[]("url"),
    "duration_display" => child(item, "itunes:duration")&.text.to_s,
    "season" => season_number,
    "episode" => episode_number,
  }
end

profile_html = fetch(PROFILE_URL)
state_json = profile_html[/window\.__STATE__ = (\{.*\});\s*window\.__SPLIT_POINTS__/m, 1]
abort "Could not find Spotify episode metadata" unless state_json

profile_state = JSON.parse(state_json)
profile_episodes = profile_state.dig("episodePreview", "episodes").to_a
spotify_by_anchor_id = profile_episodes.to_h { |episode| [episode.fetch("episodeId"), episode] }

episodes = rss_episodes.map do |episode|
  key = [episode.fetch("season"), episode.fetch("episode")]
  curated_episode = curated[key]
  abort "Missing curated episode entry for season #{key[0]}, episode #{key[1]}" unless curated_episode

  spotify_episode = spotify_by_anchor_id[episode.fetch("anchor_id")]
  abort "Missing Spotify URL for #{episode.fetch("rss_title")}" unless spotify_episode

  title = curated_episode.fetch("title")
  slug = slugify("s#{key[0]}-e#{key[1]}-#{title}")
  episode.merge(
    "title" => title,
    "slug" => slug,
    "permalink" => "/podcasts/#{slug}/",
    "spotify_url" => spotify_episode.fetch("spotifyUrl"),
    "spotify_embed_url" => spotify_episode.fetch("spotifyUrl").sub("/episode/", "/embed/episode/"),
    "episode_image" => "/assets/img/podcast/episodes/s#{key[0]}-e#{key[1]}.webp",
  )
end

missing_from_feed = curated.keys - episodes.map { |episode| [episode["season"], episode["episode"]] }
abort "Curated episodes missing from RSS: #{missing_from_feed.inspect}" if missing_from_feed.any?

FileUtils.mkdir_p(EPISODES_DIR)
FileUtils.mkdir_p(TRANSCRIPTS_DIR)

episodes.each_with_index do |episode, index|
  newer = index.positive? ? episodes[index - 1] : nil
  older = episodes[index + 1]
  text = plain_text(episode.fetch("description_html"))
  overview = overview_text(text)
  links = extract_links(text)
  chapters = extract_chapters(text)

  transcript = episode["transcript_url"] ? normalise_transcript_srt(fetch(episode["transcript_url"])) : nil
  transcript_path = nil
  if transcript
    transcript_path = "/assets/transcripts/#{episode.fetch("slug")}.srt"
    File.write(File.join(ROOT, transcript_path.sub(%r{\A/}, "")), transcript)
  end

  image_file = File.join(ROOT, episode.fetch("episode_image").sub(%r{\A/}, ""))
  abort "Missing episode image #{image_file}" unless File.exist?(image_file)

  front_matter = {
    "layout" => "podcast_episode",
    "title" => episode.fetch("title"),
    "meta_title" => "#{episode.fetch("title")} | The Neil Ashton Podcast",
    "description" => description_for_meta(overview),
    "permalink" => episode.fetch("permalink"),
    "date" => episode.fetch("published_at"),
    "season" => episode.fetch("season"),
    "episode" => episode.fetch("episode"),
    "duration_display" => episode.fetch("duration_display"),
    "duration_iso" => duration_iso(episode.fetch("duration_display")),
    "guid" => episode.fetch("guid"),
    "schema_type" => "PodcastEpisode",
    "og_type" => "article",
    "og_image" => episode.fetch("episode_image"),
    "og_image_alt" => "#{episode.fetch("title")} — The Neil Ashton Podcast",
    "og_image_width" => 320,
    "og_image_height" => 180,
    "episode_image" => episode.fetch("episode_image"),
    "episode_image_alt" => "#{episode.fetch("title")} — The Neil Ashton Podcast",
    "spotify_url" => episode.fetch("spotify_url"),
    "spotify_embed_url" => episode.fetch("spotify_embed_url"),
    "creator_url" => episode.fetch("creator_url"),
    "audio_url" => episode.fetch("audio_url"),
    "transcript_url" => episode["transcript_url"],
    "transcript_path" => transcript_path,
    "newer_title" => newer&.fetch("title", nil),
    "newer_url" => newer&.fetch("permalink", nil),
    "older_title" => older&.fetch("title", nil),
    "older_url" => older&.fetch("permalink", nil),
    "sitemap" => true,
  }.compact

  output_file = File.join(EPISODES_DIR, "#{episode.fetch("slug")}.md")
  existing_output = File.exist?(output_file) ? File.read(output_file) : nil
  existing_last_modified = existing_output&.match(/^last_modified_at:\s*['"]?([^'"\n]+)/)&.[](1)
  front_matter["last_modified_at"] = existing_last_modified || Date.today.iso8601

  body = body_html(
    overview: overview,
    links: links,
    chapters: chapters,
    transcript: transcript,
    transcript_path: transcript_path,
  )
  output = "#{front_matter.to_yaml}---\n\n<!-- Generated by scripts/sync_podcast_episodes.rb. -->\n\n#{body}\n"
  if existing_output && existing_output != output && existing_last_modified
    front_matter["last_modified_at"] = Date.today.iso8601
    output = "#{front_matter.to_yaml}---\n\n<!-- Generated by scripts/sync_podcast_episodes.rb. -->\n\n#{body}\n"
  end
  File.write(output_file, output)
end

puts "Generated #{episodes.length} episode pages"
puts "Downloaded #{episodes.count { |episode| episode["transcript_url"] }} transcripts"
