# Data

## `medicaid.csv` — county-year panel

26,066 rows. US counties, 2009–2019. Used in Module 1.

| Column | Meaning |
|---|---|
| `state`, `county`, `county_code` | identifiers |
| `year` | 2009–2019 |
| `population_20_64` | working-age population |
| `yaca` | year the state expanded Medicaid; `NA` if it never did |
| `crude_rate_20_64` | **outcome** — deaths per 100,000 aged 20–64 |
| `unemp_rate`, `poverty_rate`, `median_income` | county covariates (income in $thousands) |
| `perc_white`, `perc_hispanic`, `perc_female` | county demographics |

Missing values: `yaca` 9,789 (by design — non-expanding states),
`unemp_rate` 21, `poverty_rate` 15, `median_income` 15.
**`crude_rate_20_64` has none**, in any row.

`yaca` takes values 2014, 2020, 2021, 2023, or `NA`. Module 1 codes
`expanded = 1` only for the 2014 wave, so later expanders sit in the
comparison group — correct for a 2014 cross-section, worth flagging if a
participant asks.

## `medicaid_states.csv` — state-level, 2014

39 rows (22 expanded, 17 not). Used in Modules 2 and 3.

Built by filtering `medicaid.csv` to `year == 2014` and averaging to the
state, which is the level at which the policy was actually assigned.
Module 1 derives this live; this file exists so Modules 2 and 3 do not
depend on Module 1 having succeeded.

| Column | Meaning |
|---|---|
| `state` | two-letter code |
| `expanded` | 1 = expanded Medicaid in 2014, 0 = did not |
| `crude_rate_20_64` | deaths per 100,000 aged 20–64 |
| `poverty_rate`, `unemp_rate`, `median_income` | state averages |

No missing values anywhere.

Regenerate with:

```r
counties <- read.csv("data/medicaid.csv", row.names = 1)
d <- counties[counties$year == 2014, ]
d$expanded <- ifelse(!is.na(d$yaca) & d$yaca == 2014, 1, 0)
st <- aggregate(cbind(crude_rate_20_64, poverty_rate, unemp_rate, median_income) ~
                  state + expanded, data = d, FUN = mean)
st <- st[order(st$state), c("state", "expanded", "crude_rate_20_64",
                            "poverty_rate", "unemp_rate", "median_income")]
st[, 3:6] <- round(st[, 3:6], 2)
write.csv(st, "data/medicaid_states.csv", row.names = FALSE)
```

## A caution on interpretation

Nothing here was randomly assigned. States chose whether to expand, and
poorer states were less likely to (`cor(expanded, poverty_rate) = −0.28`).
Every result in this workshop is an association, and the materials say so
in each module. The Module 2 discussion works through the confound
explicitly.
