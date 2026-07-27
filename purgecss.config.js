module.exports = {
  content: ["_site/**/*.html", "_site/**/*.js"],
  css: ["_site/assets/css/*.css"],
  output: "_site/assets/css/",
  skippedContentGlobs: ["_site/assets/**/*.html"],
  safelist: {
    standard: [/^html$/, /^show$/, /^collapsed$/, /^is-active$/],
    deep: [/data-theme/, /data-theme-setting/],
  },
};
