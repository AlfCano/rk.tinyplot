local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.08-1")

  plugin_name <- "rk.tinyplot"
  plugin_ver <- "0.0.1"

  package_about <- rk.XML.about(
    name = plugin_name,
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "A GUI wrapper for the tinyplot package, bringing lightweight, powerful base R graphics to RKWard.",
      version = plugin_ver,
      date = format(Sys.Date(), "%Y-%m-%d"),
      license = "GPL (>= 3)"
    )
  )

  # =========================================================================================
  # 2. Shared Helpers & UI Generators
  # =========================================================================================

  js_common_helper <- '
    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\\[\\[\\"(.*?)\\"\\]\\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  '

  # Shared Labels & Theme Tab
  make_theme_tab <- function(prefix) {
    rk.XML.col(
      rk.XML.frame(label = "Text Labels",
        rk.XML.input(label = "Main Title", id.name = paste0(prefix, "_main")),
        rk.XML.input(label = "Subtitle", id.name = paste0(prefix, "_sub")),
        rk.XML.row(
          rk.XML.input(label = "X-Axis Label", id.name = paste0(prefix, "_xlab")),
          rk.XML.input(label = "Y-Axis Label", id.name = paste0(prefix, "_ylab"))
        )
      ),
      rk.XML.frame(label = "tinyplot Themes & Styling",
        rk.XML.row(
          rk.XML.dropdown(label = "Plot Theme", id.name = paste0(prefix, "_theme"), options = list(
            "Default" = list(val = "default", chk = TRUE),
            "Minimal" = list(val = "minimal"),
            "Ipsum"   = list(val = "ipsum"),
            "Clean"   = list(val = "clean"),
            "Classic" = list(val = "classic"),
            "BW"      = list(val = "bw"),
            "Tufte"   = list(val = "tufte"),
            "Dark"    = list(val = "dark"),
            "Void"    = list(val = "void")
          )),
          rk.XML.dropdown(label = "Color Palette", id.name = paste0(prefix, "_palette"), options = list(
            "Default" = list(val = "default", chk = TRUE),
            "Okabe-Ito" = list(val = "okabeito"),
            "Tableau" = list(val = "tableau"),
            "Dark2 (Brewer)" = list(val = "Dark2"),
            "Set1 (Brewer)" = list(val = "Set1"),
            "Viridis" = list(val = "viridis")
          ))
        ),
        rk.XML.row(
          rk.XML.dropdown(label = "Legend Position", id.name = paste0(prefix, "_legend"), options = list(
            "Default (Auto)" = list(val = "default", chk = TRUE),
            "Right" = list(val = "right"),
            "Bottom" = list(val = "bottom"),
            "Bottom Right" = list(val = "bottomright"),
            "Top Right" = list(val = "topright"),
            "Left" = list(val = "left"),
            "Top" = list(val = "top"),
            "None (Hide)" = list(val = "none")
          )),
          rk.XML.cbox(label = "Force Background Grid Lines", value = "1", chk = FALSE, id.name = paste0(prefix, "_grid"))
        )
      )
    )
  }

  # Standard Output & Export Tab for Base Graphics
  make_device_tab <- function(prefix, initial_save) {
    rk.XML.col(
      rk.XML.frame(label = "Graphics Device",
          rk.XML.dropdown(label = "Device type", id.name = paste0(prefix, "_dev_type"), options = list("PNG" = list(val = "PNG", chk = TRUE), "SVG" = list(val = "SVG"), "JPG" = list(val = "JPG"))),
          rk.XML.row(
              rk.XML.spinbox(label = "Width", id.name = paste0(prefix, "_dev_w"), min = 100, max = 4000, initial = 800),
              rk.XML.spinbox(label = "Height", id.name = paste0(prefix, "_dev_h"), min = 100, max = 4000, initial = 600),
              rk.XML.spinbox(label = "Resolution (ppi)", id.name = paste0(prefix, "_dev_res"), min = 36, max = 1200, initial = 72)
          )
      ),
      rk.XML.saveobj(label = "Save Plot Object (recordPlot)", initial = initial_save, id.name = paste0(prefix, "_save"), chk = FALSE),
      rk.XML.preview(id.name = paste0(prefix, "_preview"))
    )
  }

  make_js_print <- function(prefix, initial_save) {
      paste0('
        if (is_preview) {
            echo("print(p)\\n");
        } else {
            var opts = [];
            opts.push("device.type=\\"" + getValue("', prefix, '_dev_type") + "\\"");
            opts.push("width=" + getValue("', prefix, '_dev_w"));
            opts.push("height=" + getValue("', prefix, '_dev_h"));
            opts.push("res=" + getValue("', prefix, '_dev_res"));
            echo("rk.graph.on(" + opts.join(", ") + ")\\n");
            echo("print(p)\\n");
            echo("rk.graph.off()\\n");
            echo("if (exists(\\"p\\")) {\\n");
            echo("  ', initial_save, ' <- p\\n");
            echo("}\\n");
            echo("rk.header(\\"Saved tinyplot to: ', initial_save, '\\")\\n");
        }
      ')
  }

  # =========================================================================================
  # 3. Component 1: One-Variable Plots (Distributions)
  # =========================================================================================

  c1_vs <- rk.XML.varselector(id.name = "c1_vs")
  c1_data <- rk.XML.varslot(label = "Data Frame", source = "c1_vs", classes = "data.frame", required = TRUE, id.name = "c1_data")
  c1_x <- rk.XML.varslot(label = "Variable (X)", source = "c1_vs", required = TRUE, id.name = "c1_x")
  c1_by <- rk.XML.varslot(label = "Group By (Color/Fill)", source = "c1_vs", id.name = "c1_by")
  c1_facet <- rk.XML.varslot(label = "Facet Variable (Subplots)", source = "c1_vs", id.name = "c1_facet")

  c1_auto_focus <- rk.XML.logic(rk.XML.connect(governor = c1_data, get = "available", client = c1_vs, set = "root"))

  c1_type <- rk.XML.dropdown(label = "Plot Type", id.name = "c1_type", options = list(
    "Density" = list(val = "density", chk = TRUE),
    "Histogram" = list(val = "histogram"),
    "Boxplot" = list(val = "boxplot")
  ))
  c1_alpha <- rk.XML.spinbox(label = "Fill Opacity (Alpha)", id.name = "c1_alpha", min = 0, max = 1, initial = 0.5, real = TRUE)

  c1_logic <- rk.XML.logic(rk.XML.connect(governor = c1_data, get = "available", client = c1_vs, set = "root"))

  c1_dialog <- rk.XML.dialog(label = "tinyplot: 1D Distributions", child = rk.XML.row(c1_vs, rk.XML.col(rk.XML.tabbook(tabs = list(
    "Data" = rk.XML.col(c1_data, c1_x, c1_by, c1_facet), # Removed the logic node from here
    "Aesthetics" = rk.XML.col(c1_type, c1_alpha),
    "Labels & Themes" = make_theme_tab("c1"),
    "Output" = make_device_tab("c1", "tp_dist")
  )))))

  c1_calc <- paste0(js_common_helper, '
    var df = getValue("c1_data");
    var x = getCol("c1_x");
    var by = getCol("c1_by");
    var facet = getCol("c1_facet");

    // Construct 1D Formula using | for grouping: ~ x | by
    var form = "~ " + x;
    if (by !== "NULL") {
        form += " | " + by;
    }

    echo("library(tinyplot)\\n");
    echo("p_cmd <- call(\\"tinyplot\\", formula = as.formula(\\"" + form + "\\"), data = quote(" + df + "))\\n");

    echo("p_cmd$type <- \\"" + getValue("c1_type") + "\\"\\n");

    // Facet is passed as a separate formula argument
    if (facet !== "NULL") { echo("p_cmd$facet <- as.formula(\\"~" + facet + "\\")\\n"); }

    var alpha = getValue("c1_alpha");
    if (alpha !== "1") { echo("p_cmd$alpha <- " + alpha + "\\n"); }

    // Themes & Labels
    var theme = getValue("c1_theme");
    if (theme !== "default") { echo("p_cmd$theme <- \\"" + theme + "\\"\\n"); }

    var pal = getValue("c1_palette");
    if (pal !== "default") { echo("p_cmd$palette <- \\"" + pal + "\\"\\n"); }

    var leg = getValue("c1_legend");
    if (leg === "none") {
        echo("p_cmd$legend <- FALSE\\n");
    } else if (leg !== "default") {
        echo("p_cmd$legend <- \\"" + leg + "\\"\\n");
    }

    if (getValue("c1_grid") === "1") { echo("p_cmd$grid <- TRUE\\n"); }

    var main = getValue("c1_main"); if(main) echo("p_cmd$main <- \\"" + main + "\\"\\n");
    var sub = getValue("c1_sub"); if(sub) echo("p_cmd$sub <- \\"" + sub + "\\"\\n");
    var xlab = getValue("c1_xlab"); if(xlab) echo("p_cmd$xlab <- \\"" + xlab + "\\"\\n");
    var ylab = getValue("c1_ylab"); if(ylab) echo("p_cmd$ylab <- \\"" + ylab + "\\"\\n");

    echo("eval(p_cmd)\\n");
    echo("p <- recordPlot()\\n");
  ')

  comp_1d <- rk.plugin.component("1D Distributions", xml = list(dialog = c1_dialog), js = list(require = "tinyplot", calculate = c1_calc, printout = make_js_print("c1", "tp_dist")), hierarchy = list("plots", "tinyplot"))

  # =========================================================================================
  # 4. Component 2: Two-Variable Plots (Relationships)
  # =========================================================================================

  c2_vs <- rk.XML.varselector(id.name = "c2_vs")
  c2_data <- rk.XML.varslot(label = "Data Frame", source = "c2_vs", classes = "data.frame", required = TRUE, id.name = "c2_data")
  c2_x <- rk.XML.varslot(label = "X Axis Variable", source = "c2_vs", required = TRUE, id.name = "c2_x")
  c2_y <- rk.XML.varslot(label = "Y Axis Variable", source = "c2_vs", required = TRUE, id.name = "c2_y")
  c2_by <- rk.XML.varslot(label = "Group By (Color/Fill)", source = "c2_vs", id.name = "c2_by")
  c2_facet <- rk.XML.varslot(label = "Facet Variable (Subplots)", source = "c2_vs", id.name = "c2_facet")

  c2_auto_focus <- rk.XML.logic(rk.XML.connect(governor = c2_data, get = "available", client = c2_vs, set = "root"))

  c2_type <- rk.XML.dropdown(label = "Plot Type", id.name = "c2_type", options = list(
    "Scatter (Points)" = list(val = "p", chk = TRUE),
    "Line" = list(val = "l"),
    "Both (Points & Line)" = list(val = "b"),
    "Step" = list(val = "s"),
    "Jitter" = list(val = "jitter"),
    "Boxplot" = list(val = "boxplot"),
    "Violin" = list(val = "violin"),
    "Ridge" = list(val = "ridge"),
    "Loess Smoother" = list(val = "loess"),
    "Linear Model (lm)" = list(val = "lm"),
    "Pointrange" = list(val = "pointrange")
  ))

  c2_pch <- rk.XML.spinbox(label = "Point Character (pch)", id.name = "c2_pch", min = 0, max = 25, initial = 16)
  c2_lwd <- rk.XML.spinbox(label = "Line Width (lwd)", id.name = "c2_lwd", min = 0.5, max = 5, initial = 1, real = TRUE)
  c2_alpha <- rk.XML.spinbox(label = "Opacity (Alpha)", id.name = "c2_alpha", min = 0, max = 1, initial = 1, real = TRUE)

  # NEW: Checkbox to superimpose a regression line
  c2_add_lm <- rk.XML.cbox(label = "Add Regression Line (lm) layer over plot", value = "1", chk = FALSE, id.name = "c2_add_lm")

  c2_logic <- rk.XML.logic(rk.XML.connect(governor = c2_data, get = "available", client = c2_vs, set = "root"))

  c2_dialog <- rk.XML.dialog(label = "tinyplot: 2D Relationships", child = rk.XML.row(c2_vs, rk.XML.col(rk.XML.tabbook(tabs = list(
    "Data" = rk.XML.col(c2_data, c2_x, c2_y, c2_by, c2_facet),
    "Aesthetics" = rk.XML.col(c2_type, c2_pch, c2_lwd, c2_alpha, rk.XML.frame(c2_add_lm)),
    "Labels & Themes" = make_theme_tab("c2"),
    "Output" = make_device_tab("c2", "tp_rel")
  )))))

  c2_calc <- paste0(js_common_helper, '
    var df = getValue("c2_data");
    var x = getCol("c2_x");
    var y = getCol("c2_y");
    var by = getCol("c2_by");
    var facet = getCol("c2_facet");

    // Construct 2D Formula using | for grouping: y ~ x | by
    var form = y + " ~ " + x;
    if (by !== "NULL") {
        form += " | " + by;
    }

    echo("library(tinyplot)\\n");
    echo("p_cmd <- call(\\"tinyplot\\", formula = as.formula(\\"" + form + "\\"), data = quote(" + df + "))\\n");

    echo("p_cmd$type <- \\"" + getValue("c2_type") + "\\"\\n");

    // Facet is passed as a separate formula argument
    if (facet !== "NULL") { echo("p_cmd$facet <- as.formula(\\"~" + facet + "\\")\\n"); }

    var pch = getValue("c2_pch"); if (pch !== "16") { echo("p_cmd$pch <- " + pch + "\\n"); }
    var lwd = getValue("c2_lwd"); if (lwd !== "1") { echo("p_cmd$lwd <- " + lwd + "\\n"); }
    var alpha = getValue("c2_alpha"); if (alpha !== "1") { echo("p_cmd$alpha <- " + alpha + "\\n"); }

    // Themes & Labels
    var theme = getValue("c2_theme");
    if (theme !== "default") { echo("p_cmd$theme <- \\"" + theme + "\\"\\n"); }

    var pal = getValue("c2_palette");
    if (pal !== "default") { echo("p_cmd$palette <- \\"" + pal + "\\"\\n"); }

    var leg = getValue("c2_legend");
    if (leg === "none") {
        echo("p_cmd$legend <- FALSE\\n");
    } else if (leg !== "default") {
        echo("p_cmd$legend <- \\"" + leg + "\\"\\n");
    }

    if (getValue("c2_grid") === "1") { echo("p_cmd$grid <- TRUE\\n"); }

    var main = getValue("c2_main"); if(main) echo("p_cmd$main <- \\"" + main + "\\"\\n");
    var sub = getValue("c2_sub"); if(sub) echo("p_cmd$sub <- \\"" + sub + "\\"\\n");
    var xlab = getValue("c2_xlab"); if(xlab) echo("p_cmd$xlab <- \\"" + xlab + "\\"\\n");
    var ylab = getValue("c2_ylab"); if(ylab) echo("p_cmd$ylab <- \\"" + ylab + "\\"\\n");

    echo("eval(p_cmd)\\n");

    // NEW: Inject secondary lm layer if requested
    if (getValue("c2_add_lm") === "1") {
        echo("tinyplot_add(type = \\"lm\\")\\n");
    }

    echo("p <- recordPlot()\\n");
  ')

  # =========================================================================================
  # 5. Assembly
  # =========================================================================================

  # 1. Define the SECONDARY component (1D Distributions) - Add logic here
  comp_1d <- rk.plugin.component(
    "1D Distributions",
    xml = list(dialog = c1_dialog, logic = c1_logic),
    js = list(require = "tinyplot", calculate = c1_calc, printout = make_js_print("c1", "tp_dist")),
    hierarchy = list("plots", "tinyplot")
  )

  # 2. Define the MAIN component (2D Relationships) - Add logic here
  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = c2_dialog, logic = c2_logic),
    js = list(
        require = "tinyplot",
        calculate = c2_calc,
        printout = make_js_print("c2", "tp_rel")
    ),
    components = list(comp_1d),
    pluginmap = list(
        name = "2D Relationships",
        hierarchy = list("plots", "tinyplot")
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.tinyplot' (v0.0.1) generation complete. Components ready.\n")
})
