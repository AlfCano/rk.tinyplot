# rk.tinyplot: Lightweight Base R Graphics for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![RKWard](https://img.shields.io/badge/Platform-RKWard-green)
[![R Linter](https://github.com/AlfCano/rk.tinyplot/actions/workflows/lintr.yml/badge.svg)](https://github.com/AlfCano/rk.tinyplot/actions/workflows/lintr.yml)
![AI Gemini](https://img.shields.io/badge/AI-Gemini-4285F4?logo=googlegemini&logoColor=white)

**A GUI Wrapper for the `tinyplot` Package Bringing Powerful Base R Graphics to RKWard**

`rk.tinyplot` provides a seamless, point-and-click interface for creating elegant and efficient visualizations directly within RKWard. This plugin leverages the lightweight and versatile `tinyplot` package, allowing users to generate common plots like density charts, histograms, and boxplots for both one-dimensional and two-dimensional data without writing any R code.

---

## 🌟 Key Features

*   **Zero-Code Base R Graphics:** Generate common statistical plots directly from RKWard's GUI.
*   **Intuitive Interface:** Cleanly organized tabs for data selection, plot aesthetics, labels, themes, and output settings.
*   **Comprehensive Customization:** Control plot types (density, histogram, boxplot, scatter, line, etc.), colors, themes, axis labels, text sizes, legend positions, and more.
*   **Tidy Data Integration:** Works directly with your data frames, leveraging `dplyr` pipes for automatic data subsetting and cleaning.
*   **Memory Efficient:** Optimized for large datasets by processing data efficiently.
*   **High-Quality Export:** Save plots in various formats (PNG, SVG, JPG) with customizable dimensions and resolutions.
*   **Multilingual Ready:** Fully prepared for translation into English, Spanish, French, German, and Portuguese (Brazil).

---

## What's New in Version 0.0.1

*   **Initial Release:** Introduces the first version of `rk.tinyplot`, providing a foundational GUI for common distributions and relationships plots using the `tinyplot` package.
*   **Core Plotting Functions:** Includes tools for density plots, histograms, boxplots, scatter plots, line plots, and more, all accessible through RKWard.
*   **Integrated Theming & Labels:** Offers extensive options for plot titles, axis labels, legend customization, and applying various visual themes (`theme_minimal`, `theme_bw`, etc.).
*   **Flexible Output Control:** Define plot dimensions, resolution, and file formats for exporting your visualizations.

---

## ⚙️ Prerequisites

You must have [RKWard](https://rkward.kde.org/) installed along with the following R packages. The plugin will automatically attempt to load them when required:

```R
install.packages("tinyplot")
```

---

## 🚀 Installation

You can install this plugin directly from GitHub using `remotes` or `devtools` inside your RKWard console:

```R
# Install the plugin
library("remotes")
install_github("AlfCano/rk.tinyplot")
```

Once installed, restart RKWard to ensure the new menu entries and translations appear correctly.

---

## 🛠️ Usage Workflow

This plugin adds two new components under the **Plots > tinyplot** menu in RKWard:

### 1. 1D Distributions
*Visualize the distribution of single variables.*
*   **Data:** Select your data frame and the variable(s) for the X-axis. Optionally use a grouping variable for color/fill and a facet variable for subplots.
*   **Aesthetics:** Choose plot type (Density, Histogram, Boxplot), point character, line width, and opacity.
*   **Labels & Themes:** Customize titles, axis labels (with automatic text wrapping), legend titles, and apply various visual themes (`theme_minimal`, `theme_dark`, etc.).
*   **Output:** Define plot dimensions, resolution, and choose the output device (PNG, SVG, JPG).

### 2. 2D Relationships
*Explore relationships between two variables.*
*   **Data:** Select your data frame and map variables to X, Y, Grouping (Color/Fill), and Faceting.
*   **Aesthetics:** Choose plot types (Scatter, Line, Boxplot, Violin, etc.), point character, line width, and opacity.
*   **Labels & Themes:** Customize titles, axis labels, legend position, and apply visual themes.
*   **Output:** Define plot dimensions, resolution, and choose the output device (PNG, SVG, JPG).

---

## 🌍 Internationalization (i18n)

The graphical interface automatically adapts to your RKWard language settings. Currently supported languages:
*   🇺🇸 English (Default)
*   🇪🇸 Spanish (Español)
*   🇫🇷 French (Français)
*   🇩🇪 German (Deutsch)
*   🇧🇷 Portuguese (Português do Brasil)

---

## 📝 License and Author

**Author:** Alfonso Cano ([@AlfCano](https://github.com/AlfCano))  
**Email:** alfonso.cano@correo.buap.mx  
*   **Assisted by:** Gemini, a large language model from Google.
*   **License:** GPL (>= 3)

This project is licensed under the **GPL (>= 3)** License.
