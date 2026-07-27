const THEME_ORDER = ["system", "light", "dark"];

const determineThemeSetting = () => {
  try {
    const setting = localStorage.getItem("theme");
    return THEME_ORDER.includes(setting) ? setting : "system";
  } catch {
    return "system";
  }
};

const determineComputedTheme = () => {
  const setting = determineThemeSetting();
  if (setting !== "system") return setting;
  return window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light";
};

const updateThemeControl = () => {
  const button = document.getElementById("light-toggle");
  if (!button) return;

  const setting = determineThemeSetting();
  const nextSetting = THEME_ORDER[(THEME_ORDER.indexOf(setting) + 1) % THEME_ORDER.length];
  button.setAttribute("aria-label", `Theme: ${setting}. Activate to switch to ${nextSetting} mode.`);
};

const applyTheme = () => {
  const theme = determineComputedTheme();
  document.documentElement.dataset.theme = theme;
  document.documentElement.dataset.themeSetting = determineThemeSetting();

  const lightStyles = document.getElementById("highlight-theme-light");
  const darkStyles = document.getElementById("highlight-theme-dark");
  if (lightStyles && darkStyles) {
    lightStyles.media = theme === "dark" ? "none" : "all";
    darkStyles.media = theme === "dark" ? "all" : "none";
  }
  updateThemeControl();
};

const setThemeSetting = (setting) => {
  try {
    localStorage.setItem("theme", setting);
  } catch {
    // The computed theme still works when storage is unavailable.
  }
  applyTheme();
};

const toggleThemeSetting = () => {
  const current = determineThemeSetting();
  setThemeSetting(THEME_ORDER[(THEME_ORDER.indexOf(current) + 1) % THEME_ORDER.length]);
};

const initTheme = () => {
  applyTheme();
  document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("light-toggle")?.addEventListener("click", toggleThemeSetting);
    updateThemeControl();
  });
  window.matchMedia?.("(prefers-color-scheme: dark)").addEventListener?.("change", applyTheme);
};
