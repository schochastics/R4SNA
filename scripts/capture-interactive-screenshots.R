# Capture per-figure screenshots for the interactive-viz chapter.
#
# Workflow (manual):
#   1. quarto render visualization/interactive-viz.qmd --to html
#   2. Rscript scripts/capture-interactive-screenshots.R
#   3. git add visualization/img/screenshots/
#
# The PDF build references these PNGs from the `content-visible when-format="pdf"`
# blocks in visualization/interactive-viz.qmd, so the PDF stays in sync with the
# HTML widgets without needing a browser at PDF render time.
#
# Requirements: chromote, with Chrome/Chromium discoverable on the system.

library(chromote)
library(jsonlite)

html_path <- normalizePath(
  "_book/visualization/interactive-viz.html",
  mustWork = TRUE
)
out_dir <- "visualization/img/screenshots"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

fig_ids <- c(
  "fig-visnetwork", "fig-networkd3", "fig-threejs",
  "fig-g6r-first", "fig-g6r-d3atlas", "fig-g6r-per-element",
  "fig-g6r-options-style", "fig-g6r-nav", "fig-g6r-interact",
  "fig-g6r-lasso", "fig-g6r-brush", "fig-g6r-hull",
  "fig-g6r-bubble", "fig-g6r-tooltip", "fig-g6r-legend",
  "fig-g6r-fisheye", "fig-g6r-minimap"
)

b <- ChromoteSession$new()
on.exit(b$close(), add = TRUE)

# Stable, retina-quality viewport so screenshots are crisp in print.
b$Emulation$setDeviceMetricsOverride(
  width = 1280, height = 800, deviceScaleFactor = 2, mobile = FALSE
)

b$Page$navigate(paste0("file://", html_path))
b$Page$loadEventFired()

# Force-directed layouts (d3-force, forceAtlas2) need time to settle.
Sys.sleep(6)

# chromote's screenshot(selector = ...) ends up clipping to the html-element
# box (i.e. the viewport), not the matched element, so we resolve the bounding
# rect via JS and pass it as `cliprect` directly.
element_rect <- function(session, selector) {
  js <- sprintf(
    "(() => {
       const el = document.querySelector(%s);
       if (!el) return null;
       el.scrollIntoView({block: 'start'});
       const r = el.getBoundingClientRect();
       return JSON.stringify({
         x: r.left + window.scrollX,
         y: r.top + window.scrollY,
         w: r.width,
         h: r.height
       });
     })()",
    toJSON(selector, auto_unbox = TRUE)
  )
  res <- session$Runtime$evaluate(js)
  if (is.null(res$result$value)) {
    stop("Selector did not match: ", selector)
  }
  fromJSON(res$result$value)
}

for (id in fig_ids) {
  message("capturing #", id)
  rect <- element_rect(b, paste0("#", id, " .html-widget"))
  Sys.sleep(0.2)  # let scrollIntoView settle
  b$screenshot(
    filename = file.path(out_dir, paste0(id, ".png")),
    cliprect = c(rect$x, rect$y, rect$w, rect$h),
    show = FALSE
  )
}

message("done — wrote ", length(fig_ids), " screenshots to ", out_dir)
