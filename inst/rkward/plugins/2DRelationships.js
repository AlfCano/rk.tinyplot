// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(tinyplot)){stop(" + i18n("Preview not available, because package tinyplot is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tinyplot)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getCol(id) {
        var raw = getValue(id);
        if (!raw) return "NULL";
        if (raw.indexOf("[[") > -1) {
            var match = raw.match(/\[\[\"(.*?)\"\]\]/);
            return match ? match[1] : raw;
        }
        return raw.split("$").pop();
    }
  
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

    echo("library(tinyplot)\n");
    echo("p_cmd <- call(\"tinyplot\", formula = as.formula(\"" + form + "\"), data = quote(" + df + "))\n");

    echo("p_cmd$type <- \"" + getValue("c2_type") + "\"\n");

    // Facet is passed as a separate formula argument
    if (facet !== "NULL") { echo("p_cmd$facet <- as.formula(\"~" + facet + "\")\n"); }

    var pch = getValue("c2_pch"); if (pch !== "16") { echo("p_cmd$pch <- " + pch + "\n"); }
    var lwd = getValue("c2_lwd"); if (lwd !== "1") { echo("p_cmd$lwd <- " + lwd + "\n"); }
    var alpha = getValue("c2_alpha"); if (alpha !== "1") { echo("p_cmd$alpha <- " + alpha + "\n"); }

    // Themes & Labels
    var theme = getValue("c2_theme");
    if (theme !== "default") { echo("p_cmd$theme <- \"" + theme + "\"\n"); }

    var pal = getValue("c2_palette");
    if (pal !== "default") { echo("p_cmd$palette <- \"" + pal + "\"\n"); }

    var leg = getValue("c2_legend");
    if (leg === "none") {
        echo("p_cmd$legend <- FALSE\n");
    } else if (leg !== "default") {
        echo("p_cmd$legend <- \"" + leg + "\"\n");
    }

    if (getValue("c2_grid") === "1") { echo("p_cmd$grid <- TRUE\n"); }

    var main = getValue("c2_main"); if(main) echo("p_cmd$main <- \"" + main + "\"\n");
    var sub = getValue("c2_sub"); if(sub) echo("p_cmd$sub <- \"" + sub + "\"\n");
    var xlab = getValue("c2_xlab"); if(xlab) echo("p_cmd$xlab <- \"" + xlab + "\"\n");
    var ylab = getValue("c2_ylab"); if(ylab) echo("p_cmd$ylab <- \"" + ylab + "\"\n");

    echo("eval(p_cmd)\n");

    // NEW: Inject secondary lm layer if requested
    if (getValue("c2_add_lm") === "1") {
        echo("tinyplot_add(type = \"lm\")\n");
    }

    echo("p <- recordPlot()\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("2D Relationships results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("c2_dev_type") + "\"");
            opts.push("width=" + getValue("c2_dev_w"));
            opts.push("height=" + getValue("c2_dev_h"));
            opts.push("res=" + getValue("c2_dev_res"));
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("if (exists(\"p\")) {\n");
            echo("  tp_rel <- p\n");
            echo("}\n");
            echo("rk.header(\"Saved tinyplot to: tp_rel\")\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var c2Save = getValue("c2_save");
		var c2SaveActive = getValue("c2_save.active");
		var c2SaveParent = getValue("c2_save.parent");
		// assign object to chosen environment
		if(c2SaveActive) {
			echo(".GlobalEnv$" + c2Save + " <- tp_rel\n");
		}	
	}

}

