---
marp: true
theme: default
class: invert
---

# Data management with R and RStudio
### Javier Sánchez Bachiller
#### Higher School of Economics

*jsbachiller.work@gmail.com*

---

# Why R?

- Easy-to-learn language
- Specially popular in economics and health sciences
- Scalable to big-data ecosystems like Spark

- Large community behind it, constant and steady development
- Used in leading research institutions and universities around the world
- Available in all platforms
- Free

---

# Why R...

## instead of Stata?
- Freely available
- No OS limitations

## instead of Python?
- More common among finance and economics topics
- Easier to install and set-up (out-of-the-box)

---

# RStudio

- Best IDE (integrated development environment) for R
- All-in-one: Editor, console, viewer, data and document manager 
- Perfect integration with Git

---

# The 'tidyverse'

The [tidyverse](https://www.tidyverse.org/packages/#installation-and-use) environment is a set of packages that has become one of the most complete and powerful solutions available in R to do anything related to data cleaning and visualization. It is based on:

- A concrete `grammar` of data manipulation with which code can be written in a sentence-like manner, making it easily readible and very intuitive. 
- The concept of `tidy` data: All columns are variables, are rows are observations.

**The basic idea is to concatenate a series of verbs (functions) to manipulate the data by creating a `pipe`, using the *pipe operator* `%>%`**


---

# Load the data

When loading the tidyverse, the `readr` package will be automatically loaded too. It allows us to read csv files by using the command `read_csv("file.csv")`.

Should we have other formats of data, additional packages are included, such as `readxl` for excel spreadsheets and `haven` for Stata or SPSS files. They just need to be loaded and then can be used the same way, that is, by using the command `read_*("file.*")` and replacing `*` by the desired extension.

**Good news:** We can export the resulting data using the same command but replacing `read` by `write`.

---



You can find cheatsheets for the tidyverse (and some other useful packages) with all relevant functions and a quick summary of how to use them in [here](https://www.rstudio.com/resources/cheatsheets/)