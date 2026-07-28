---
layout: page
title: Podcast
permalink: /podcasts/
description: The Neil Ashton Podcast is a series of long-form interviews on artificial intelligence, simulation, high-performance computing, aerodynamics, and engineering research.
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
  <nav class="platform-links academic-links" aria-label="Listen to the podcast">
    <a href="{{ site.spotify_show_url }}">Spotify</a>
    <a href="{{ site.apple_podcasts_url }}">Apple Podcasts</a>
    <a href="{{ site.youtube_podcast_url }}">YouTube</a>
  </nav>
</div>

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
                <a href="{{ episode.url }}">
                  {{ episode.title | escape }}
                  <span aria-hidden="true">↗</span>
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
      <h3>Professor Karthik Duraisamy</h3>
      <p>Data-driven modelling and the future of computational engineering.</p>
      <div class="episode-links">
        <a href="https://open.spotify.com/episode/0vYtzHv0I2IiIIpMtUSJvn">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/VnISBGD6T14">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
    <article class="conversation-card">
      <p class="card-kicker">Scientific computing</p>
      <h3>Professor Jack Dongarra</h3>
      <p>High-performance computing and the evolution of computational science.</p>
      <div class="episode-links">
        <a href="https://open.spotify.com/episode/6VsXMMAVf3iaCHkOPdY4uG">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/DgQt6rktdzw">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
    <article class="conversation-card">
      <p class="card-kicker">Formula 1</p>
      <h3>Pat Symonds</h3>
      <p>Engineering judgement, aerodynamics, and a career at the leading edge of motorsport.</p>
      <div class="episode-links">
        <a href="https://open.spotify.com/episode/3USHfCZZAuAV3YvokYWVvg">Spotify <span aria-hidden="true">↗</span></a>
        <a href="https://youtu.be/vMoIgfHtJHc">YouTube <span aria-hidden="true">↗</span></a>
      </div>
    </article>
  </div>
</section>

<script defer src="{{ '/assets/js/podcast-embed.js' | relative_url | bust_file_cache }}"></script>
