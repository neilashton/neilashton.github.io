document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector("[data-publications]");
  const search = document.getElementById("publication-search");
  const resultCount = document.getElementById("publication-results");
  const emptyMessage = document.getElementById("publication-empty");
  const chips = [...document.querySelectorAll("[data-publication-filter]")];
  if (!container || !search) return;

  const entries = [...container.querySelectorAll("[data-publication-entry]")].map((article) => ({
    article,
    item: article.closest("li") || article,
    text: article.textContent.toLowerCase().replace(/\s+/g, " "),
  }));

  let activeFilter = "all";

  const updateGroups = () => {
    container.querySelectorAll("ol.bibliography").forEach((list) => {
      const hasVisibleItems = [...list.children].some((item) => !item.hidden);
      list.hidden = !hasVisibleItems;
      const heading = list.previousElementSibling;
      if (heading?.matches("h2.bibliography")) heading.hidden = !hasVisibleItems;
    });
  };

  const applyFilters = () => {
    const query = search.value.trim().toLowerCase();
    const topicTerms = activeFilter === "all" ? [] : activeFilter.split("|");
    let visibleCount = 0;

    entries.forEach(({ item, text }) => {
      const matchesSearch = !query || text.includes(query);
      const matchesTopic = topicTerms.length === 0 || topicTerms.some((term) => text.includes(term));
      const isVisible = matchesSearch && matchesTopic;
      item.hidden = !isVisible;
      if (isVisible) visibleCount += 1;
    });

    updateGroups();
    resultCount.textContent = `${visibleCount} publication${visibleCount === 1 ? "" : "s"} shown`;
    if (emptyMessage) emptyMessage.hidden = visibleCount !== 0;
  };

  search.addEventListener("input", applyFilters);
  chips.forEach((chip) => {
    chip.addEventListener("click", () => {
      activeFilter = chip.dataset.publicationFilter;
      chips.forEach((otherChip) => {
        const isActive = otherChip === chip;
        otherChip.classList.toggle("is-active", isActive);
        otherChip.setAttribute("aria-pressed", String(isActive));
      });
      applyFilters();
    });
  });

  applyFilters();
});
