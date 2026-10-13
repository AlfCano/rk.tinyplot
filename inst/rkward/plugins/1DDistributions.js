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
  
    var df = getValue("c1_data");
    var x = getCol("c1_x");
    var by = getCol("c1_by");
    var facet = getCol("c1_facet");

    // Construct 1D Formula using | for grouping: ~ x | by
    var form = "~ " + x;
    if (by !== "NULL") {
        form += " | " + by;
    }

    echo("library(tinyplot)\n");
    echo("p_cmd <- call(\"tinyplot\", formula = as.formula(\"" + form + "\"), data = quote(" + df + "))\n");

    echo("p_cmd$type <- \"" + getValue("c1_type") + "\"\n");

    // Facet is passed as a separate formula argument
    if (facet !== "NULL") { echo("p_cmd$facet <- as.formula(\"~" + facet + "\")\n"); }

    var alpha = getValue("c1_alpha");
    if (alpha !== "1") { echo("p_cmd$alpha <- " + alpha + "\n"); }

    // Themes & Labels
    var theme = getValue("c1_theme");
    if (theme !== "default") { echo("p_cmd$theme <- \"" + theme + "\"\n"); }

    var pal = getValue("c1_palette");
    if (pal !== "default") { echo("p_cmd$palette <- \"" + pal + "\"\n"); }

    var leg = getValue("c1_legend");
    if (leg === "none") {
        echo("p_cmd$legend <- FALSE\n");
    } else if (leg !== "default") {
        echo("p_cmd$legend <- \"" + leg + "\"\n");
    }

    if (getValue("c1_grid") === "1") { echo("p_cmd$grid <- TRUE\n"); }

    var main = getValue("c1_main"); if(main) echo("p_cmd$main <- \"" + main + "\"\n");
    var sub = getValue("c1_sub"); if(sub) echo("p_cmd$sub <- \"" + sub + "\"\n");
    var xlab = getValue("c1_xlab"); if(xlab) echo("p_cmd$xlab <- \"" + xlab + "\"\n");
    var ylab = getValue("c1_ylab"); if(ylab) echo("p_cmd$ylab <- \"" + ylab + "\"\n");

    echo("eval(p_cmd)\n");
    echo("p <- recordPlot()\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("1D Distributions results")).print();	
	}
        if (is_preview) {
            echo("print(p)\n");
        } else {
            var opts = [];
            opts.push("device.type=\"" + getValue("c1_dev_type") + "\"");
            opts.push("width=" + getValue("c1_dev_w"));
            opts.push("height=" + getValue("c1_dev_h"));
            opts.push("res=" + getValue("c1_dev_res"));
            echo("rk.graph.on(" + opts.join(", ") + ")\n");
            echo("print(p)\n");
            echo("rk.graph.off()\n");
            echo("if (exists(\"p\")) {\n");
            echo("  tp_dist <- p\n");
            echo("}\n");
            echo("rk.header(\"Saved tinyplot to: tp_dist\")\n");
        }
      
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var c1Save = getValue("c1_save");
		var c1SaveActive = getValue("c1_save.active");
		var c1SaveParent = getValue("c1_save.parent");
		// assign object to chosen environment
		if(c1SaveActive) {
			echo(".GlobalEnv$" + c1Save + " <- tp_dist\n");
		}	
	}

}

