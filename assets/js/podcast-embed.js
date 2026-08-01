(() => {
  "use strict";

  const initialisePodcastEmbeds = () => {
    document.querySelectorAll("[data-podcast-embed]").forEach((embed) => {
      const loadButton = embed.querySelector("[data-load-podcast-player]");
      const slot = embed.querySelector("[data-podcast-embed-slot]");
      const status = embed.querySelector("[data-podcast-embed-status]");

      if (!loadButton || !slot) return;

      loadButton.hidden = false;
      loadButton.addEventListener(
        "click",
        () => {
          let embedUrl;

          try {
            embedUrl = new URL(embed.dataset.embedSrc);
          } catch {
            if (status) status.textContent = "The Spotify player could not be loaded. Please use the direct Spotify link.";
            return;
          }

          if (embedUrl.protocol !== "https:" || embedUrl.hostname !== "open.spotify.com" || !embedUrl.pathname.startsWith("/embed/")) {
            if (status) status.textContent = "The Spotify player could not be loaded. Please use the direct Spotify link.";
            return;
          }

          const iframe = document.createElement("iframe");
          iframe.className = "podcast-embed-frame";
          iframe.title = embed.dataset.embedTitle || "The Neil Ashton Podcast on Spotify";
          iframe.width = "624";
          iframe.height = "351";
          iframe.allow = "autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture";
          iframe.referrerPolicy = "strict-origin-when-cross-origin";
          iframe.allowFullscreen = true;

          embed.setAttribute("aria-busy", "true");
          loadButton.disabled = true;
          if (status) status.textContent = "Loading the Spotify player.";

          iframe.addEventListener(
            "load",
            () => {
              embed.removeAttribute("aria-busy");
              if (status) status.textContent = "Spotify player loaded.";
              iframe.focus();
            },
            { once: true }
          );

          iframe.src = embedUrl.href;
          slot.replaceChildren(iframe);
          embed.classList.add("is-loaded");
        },
        { once: true }
      );
    });
  };

  const initialiseYoutubePlaylistEmbeds = () => {
    document.querySelectorAll("[data-youtube-playlist]").forEach((embed) => {
      const loadButton = embed.querySelector("[data-load-youtube-playlist]");
      const slot = embed.querySelector("[data-youtube-playlist-slot]");
      const status = embed.querySelector("[data-youtube-playlist-status]");

      if (!loadButton || !slot) return;

      loadButton.hidden = false;
      loadButton.addEventListener(
        "click",
        () => {
          let embedUrl;

          try {
            embedUrl = new URL(embed.dataset.embedSrc);
          } catch {
            if (status) status.textContent = "The YouTube playlist could not be loaded. Please use the direct YouTube link.";
            return;
          }

          const isYoutubePlaylist =
            embedUrl.protocol === "https:" &&
            embedUrl.hostname === "www.youtube-nocookie.com" &&
            embedUrl.pathname === "/embed/videoseries" &&
            embedUrl.searchParams.has("list");

          if (!isYoutubePlaylist) {
            if (status) status.textContent = "The YouTube playlist could not be loaded. Please use the direct YouTube link.";
            return;
          }

          const iframe = document.createElement("iframe");
          iframe.title = "The Neil Ashton Podcast on YouTube";
          iframe.referrerPolicy = "strict-origin-when-cross-origin";
          iframe.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share";
          iframe.allowFullscreen = true;

          embed.setAttribute("aria-busy", "true");
          loadButton.disabled = true;
          if (status) status.textContent = "Loading the YouTube playlist.";

          iframe.addEventListener(
            "load",
            () => {
              embed.removeAttribute("aria-busy");
              if (status) status.textContent = "YouTube playlist loaded.";
              iframe.focus();
            },
            { once: true }
          );

          iframe.src = embedUrl.href;
          slot.replaceChildren(iframe);
          embed.classList.add("is-loaded");
        },
        { once: true }
      );
    });
  };

  const initialiseEmbeds = () => {
    initialisePodcastEmbeds();
    initialiseYoutubePlaylistEmbeds();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initialiseEmbeds, { once: true });
  } else {
    initialiseEmbeds();
  }
})();
