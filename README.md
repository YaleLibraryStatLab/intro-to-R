# Intro to R

Learn R by using it to answer a real statistical question.

A two-hour StatLab workshop. By the end you will have read real data,
compared two groups, tested the difference, built a p-value by hand, and
fit a regression — using twenty-three functions.

## Before the workshop

1. Install **R** from [cran.r-project.org](https://cran.r-project.org)
2. Install **Positron** from [positron.posit.co](https://positron.posit.co)
3. Download this repository: green **Code** button above → **Download ZIP**,
   then unzip it. (Or `git clone` it if you use git.)

Nothing else to install. The workshop uses base R only.

## Getting started

Open **Positron**, then **File → Open Folder** and choose the `intro-to-R`
folder you just unzipped.

Open the **folder**, not a file. Positron treats whatever folder you open as
your working directory, which is why none of the scripts contain a file
path you have to change. `read.csv("data/medicaid.csv")` just works.

Check the top-right corner says **R**. Then open `scripts/01-i-do.R` and
run a line with **Cmd+Enter** (Mac) or **Ctrl+Enter** (Windows).

## What's in here

### `scripts/`

| File | |
|---|---|
| `01-i-do.R` | **Start here.** Mostly empty: section headings and a note about what to write next. You type along with the instructor. |
| `02-we-do.R` | Work in pairs. Most of the code is written. Twelve blanks are yours, and four of them are whole expressions. |
| `03-they-do.R` | On your own. Eight steps, no code. |

### `scripts/solutions/`

| File | |
|---|---|
| `01-i-do-solution.R` | Module 1 finished, with full commentary explaining every line. Use it to catch up if you fall behind, and take it home as a reference. |
| `02-we-do-solution.R` | Module 2 answers, including the discussion questions. |
| `03-they-do-solution.R` | Module 3 answers, plus the extension exercises. |

The solutions are here on purpose. Try each module first — you will learn
more from a wrong answer you wrote than a right one you read.

### `data/`

| File | |
|---|---|
| `medicaid.csv` | 26,066 rows: US counties, 2009–2019, with mortality, poverty, unemployment and income. Used in Module 1. |
| `medicaid_states.csv` | The same data collapsed to 39 states. Used in Modules 2 and 3. |
| `README.md` | What every column means, where the missing values are, and how the state file was built. |

### `presentation/`

`01-rstats-presentation.html` is the slide deck. Open it in a browser to
review anything from the session. Everything else in that folder is what
builds the deck, and you can ignore it.

## Getting unstuck during the workshop

- **Red sticky note** means you are stuck. Put it up early; that is what
  the instructors are for.
- `?mean` opens R's own help for any function.
- Your script from today is the best reference you will own. It works, you
  typed it, and you know what every line does.

StatLab office hours are free and are the fastest way to get unstuck:
[library.yale.edu/statlab](https://library.yale.edu/statlab)
