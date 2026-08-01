---
layout: page
title: The Neil Ashton Podcast
nav_title: Podcast
meta_title: The Neil Ashton Podcast | AI, CFD & Computational Engineering
permalink: /podcasts/
description: The Neil Ashton Podcast explores AI, computational fluid dynamics, simulation, aerodynamics, high-performance computing and engineering careers in depth.
nav: true
nav_order: 5
schema_type: PodcastSeries
podcast_same_as:
  - https://open.spotify.com/show/4muRLrJ9Pxglw0RsPgx2gb
  - https://podcasts.apple.com/us/podcast/the-neil-ashton-podcast/id1745076065
  - https://www.youtube.com/channel/UCFFbscxlXPiTNRulk8sOwRQ
---

<div class="podcast-hero">
  <div class="page-intro measure-wide">
    <p>Long-form interviews with researchers and engineers working in artificial intelligence, scientific computing, simulation, aerodynamics, and related fields.</p>
  </div>
  <nav class="platform-links academic-links" aria-label="Watch or listen to the podcast">
    <a href="{{ site.youtube_podcast_url }}">YouTube</a>
    <a href="{{ site.spotify_show_url }}">Spotify</a>
    <a href="{{ site.apple_podcasts_url }}">Apple Podcasts</a>
    <a href="{{ site.podcast_rss_url }}" rel="alternate" type="application/rss+xml">RSS</a>
  </nav>
</div>

<section class="podcast-video-showcase" aria-labelledby="podcast-video-title">
  <div class="podcast-video-heading">
    <div>
      <p class="eyebrow">Watch the podcast</p>
      <h2 id="podcast-video-title">Full conversations on YouTube</h2>
    </div>
    <a href="{{ site.youtube_podcast_url }}">Browse the YouTube playlist <span aria-hidden="true">↗</span></a>
  </div>
  <div
    class="podcast-video-frame"
    data-youtube-playlist
    data-embed-src="https://www.youtube-nocookie.com/embed/videoseries?list={{ site.youtube_podcast_playlist_id }}"
  >
    <div class="podcast-video-slot" data-youtube-playlist-slot>
      <div class="podcast-video-poster">
        <img
          src="{{ '/assets/img/podcast/episodes/s4-e5.webp' | relative_url }}"
          alt=""
          width="1280"
          height="720"
          loading="eager"
          fetchpriority="high"
          decoding="async"
        >
        <div class="podcast-video-poster-copy">
          <p class="eyebrow">YouTube playlist</p>
          <p class="podcast-video-poster-title">Watch every full conversation</p>
          <p>The playlist is loaded only when you choose to watch, keeping this page fast and private by default.</p>
          <button
            class="button button-primary podcast-video-load"
            type="button"
            data-load-youtube-playlist
            hidden
          >
            Load YouTube playlist
          </button>
          <noscript>
            <p class="podcast-video-noscript"><a href="{{ site.youtube_podcast_url }}">Open the playlist on YouTube</a>.</p>
          </noscript>
        </div>
      </div>
    </div>
    <p class="sr-only" data-youtube-playlist-status aria-live="polite"></p>
  </div>
</section>

<p class="eyebrow podcast-audio-label">Listen on Spotify</p>
<div
  class="podcast-embed"
  data-podcast-embed
  data-embed-src="https://open.spotify.com/embed/show/4muRLrJ9Pxglw0RsPgx2gb/video"
  aria-label="The Neil Ashton Podcast Spotify player"
>
  <div class="podcast-embed-slot" data-podcast-embed-slot>
    <div class="podcast-embed-poster">
      <span class="podcast-embed-mark" aria-hidden="true">
        <svg viewBox="0 0 48 48" focusable="false">
          <circle cx="24" cy="24" r="23"></circle>
          <path d="m20 15 14 9-14 9Z"></path>
        </svg>
      </span>
      <div class="podcast-embed-copy">
        <p class="eyebrow">Spotify player</p>
        <p class="podcast-embed-title">The Neil Ashton Podcast</p>
        <p>Browse and play the latest conversations without leaving this page.</p>
        <button
          class="button button-primary podcast-embed-load"
          type="button"
          data-load-podcast-player
          hidden
        >
          Load Spotify player
        </button>
        <noscript>
          <p class="podcast-embed-noscript">The embedded player requires JavaScript. You can still listen directly on Spotify.</p>
        </noscript>
      </div>
    </div>
  </div>
  <div class="podcast-embed-meta">
    <p>Spotify is contacted only after you load the player and may then set cookies.</p>
    <a href="{{ site.spotify_show_url }}">Open in Spotify <span aria-hidden="true">↗</span></a>
  </div>
  <p class="sr-only" data-podcast-embed-status aria-live="polite"></p>
</div>

{% assign podcast_episode_count = 0 %}
{% for season in site.data.podcast_seasons %}
{% assign podcast_episode_count = podcast_episode_count | plus: season.episodes.size %}
{% endfor %}

<section class="podcast-section podcast-seasons" aria-labelledby="seasons-title">
  <div class="section-heading compact">
    <div>
      <p class="eyebrow">Episode archive</p>
      <h2 id="seasons-title">Browse by season</h2>
    </div>
    <p class="season-summary">{{ site.data.podcast_seasons.size }} seasons · {{ podcast_episode_count }} episodes</p>
  </div>

  <div class="season-grid">
    {% for season in site.data.podcast_seasons %}
      {% assign season_episode_pages = site.podcast_episodes | where: "season", season.number %}
      <details class="season-card">
        <summary>
          <span class="season-card-topline">
            <span class="season-number">Season {{ season.number }}</span>
            <span>{{ season.years | escape }}</span>
          </span>
          <span class="season-title" role="heading" aria-level="3">{{ season.title | escape }}</span>
          <span class="season-description">{{ season.description | escape }}</span>
          <span class="season-guests"><span>Featuring</span> {{ season.guests | escape }}</span>
          <span class="season-action">
            Browse {{ season.episodes.size }} episodes
            <span class="season-toggle" aria-hidden="true"></span>
          </span>
        </summary>

        <ol class="season-episode-list" aria-label="Season {{ season.number }} episodes">
          {% for episode in season.episodes %}
            {% assign episode_page = season_episode_pages | where: "episode", episode.number | first %}
            <li>
              {% capture episode_thumbnail_path %}/assets/img/podcast/episodes/s{{ season.number }}-e{{ episode.number }}.webp{% endcapture %}
              <img
                class="season-episode-thumbnail"
                src="{{ episode_thumbnail_path | relative_url }}"
                alt=""
                width="320"
                height="180"
                loading="lazy"
                decoding="async"
              >
              <div class="season-episode-copy">
                <span class="season-episode-meta">
                  S{{ season.number }} · E{{ episode.number }} ·
                  <time datetime="{{ episode.date }}">{{ episode.date | date: "%d %b %Y" }}</time>
                </span>
                <a href="{% if episode_page %}{{ episode_page.url | relative_url }}{% else %}{{ episode.url }}{% endif %}">
                  {{ episode.title | escape }}
                  <span aria-hidden="true">→</span>
                </a>
              </div>
            </li>
          {% endfor %}
        </ol>
      </details>
    {% endfor %}

  </div>
</section>

<section class="podcast-section" aria-labelledby="conversations-title">
  <h2 id="conversations-title">Selected episodes</h2>
  <div class="card-grid conversation-grid">
    <article class="conversation-card">
      <p class="card-kicker">AI &amp; engineering</p>
      <h3><a href="{{ '/podcasts/s1-e12-prof-karthik-duraisamy-scientific-foundation-models/' | relative_url }}">Professor Karthik Duraisamy</a></h3>
      <p>Data-driven modelling and the future of computational engineering.</p>
      <div class="episode-links">
        <a href="{{ '/podcasts/s1-e12-prof-karthik-duraisamy-scientific-foundation-models/' | relative_url }}">Episode page <span aria-hidden="true">→</span></a>
        <a href="https://open.spotify.com/episode/0vYtzHv0I2IiIIpMtUSJvn">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/VnISBGD6T14">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
    <article class="conversation-card">
      <p class="card-kicker">Scientific computing</p>
      <h3><a href="{{ '/podcasts/s1-e8-prof-jack-dongarra-high-performance-computing-pioneer/' | relative_url }}">Professor Jack Dongarra</a></h3>
      <p>High-performance computing and the evolution of computational science.</p>
      <div class="episode-links">
        <a href="{{ '/podcasts/s1-e8-prof-jack-dongarra-high-performance-computing-pioneer/' | relative_url }}">Episode page <span aria-hidden="true">→</span></a>
        <a href="https://open.spotify.com/episode/6VsXMMAVf3iaCHkOPdY4uG">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/DgQt6rktdzw">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
    <article class="conversation-card">
      <p class="card-kicker">Formula 1</p>
      <h3><a href="{{ '/podcasts/s1-e7-pat-symonds-formula-1/' | relative_url }}">Pat Symonds</a></h3>
      <p>Engineering judgement, aerodynamics, and a career at the leading edge of motorsport.</p>
      <div class="episode-links">
        <a href="{{ '/podcasts/s1-e7-pat-symonds-formula-1/' | relative_url }}">Episode page <span aria-hidden="true">→</span></a>
        <a href="https://open.spotify.com/episode/3USHfCZZAuAV3YvokYWVvg">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/vMoIgfHtJHc">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
  </div>
</section>

<script defer src="{{ '/assets/js/podcast-embed.js' | relative_url | bust_file_cache }}"></script>
