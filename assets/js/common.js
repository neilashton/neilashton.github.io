document.addEventListener("DOMContentLoaded", () => {
  const navToggle = document.querySelector("[data-nav-toggle]");
  const navMenu = document.querySelector("[data-nav-menu]");

  const setNavigationOpen = (isOpen) => {
    if (!navToggle || !navMenu) return;
    navMenu.classList.toggle("show", isOpen);
    navToggle.classList.toggle("collapsed", !isOpen);
    navToggle.setAttribute("aria-expanded", String(isOpen));
    navToggle.setAttribute("aria-label", isOpen ? "Close navigation" : "Open navigation");
  };

  navToggle?.addEventListener("click", () => {
    setNavigationOpen(navToggle.getAttribute("aria-expanded") !== "true");
  });

  navMenu?.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => setNavigationOpen(false));
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      setNavigationOpen(false);
      navToggle?.focus();
    }
  });

  document.addEventListener("click", (event) => {
    if (navMenu?.classList.contains("show") && !event.target.closest("#navbar")) {
      setNavigationOpen(false);
    }
  });

  const desktopNavigation = window.matchMedia("(min-width: 768px)");
  desktopNavigation.addEventListener?.("change", (event) => {
    if (event.matches) setNavigationOpen(false);
  });

  document.querySelectorAll("[data-disclosure-target]").forEach((button) => {
    button.addEventListener("click", () => {
      const target = document.getElementById(button.dataset.disclosureTarget);
      if (!target) return;
      const willOpen = target.hidden;

      button
        .closest(".publication-entry")
        ?.querySelectorAll("[data-disclosure-target]")
        .forEach((siblingButton) => {
          if (siblingButton === button) return;
          const siblingTarget = document.getElementById(siblingButton.dataset.disclosureTarget);
          if (siblingTarget) siblingTarget.hidden = true;
          siblingButton.setAttribute("aria-expanded", "false");
          siblingButton.classList.remove("is-active");
        });

      target.hidden = !willOpen;
      button.setAttribute("aria-expanded", String(willOpen));
      button.classList.toggle("is-active", willOpen);
    });
  });
});
