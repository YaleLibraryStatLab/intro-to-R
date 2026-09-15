# =====================================================================
#  MODULE 2 - SOLUTION
#  Do high-poverty states have higher working-age mortality?
# =====================================================================

# ---- 1. Get the data ------------------------------------------------
states <- read.csv("data/medicaid_states.csv")

dim(states)      # 39 rows, 6 columns
names(states)
head(states)


# ---- 2. Look at it first --------------------------------------------
hist(states$poverty_rate)
# Median 15.4, range about 9 to 22, mild right skew.


# ---- 3. Build the grouping variable ---------------------------------
median(states$poverty_rate)

states$high_poverty <- ifelse(states$poverty_rate > median(states$poverty_rate), 1, 0)

table(states$high_poverty)
# 20 low, 19 high. Not exactly even: the median is itself a state's
# value, and > is strict, so that state falls in the "low" group.

# Why no !is.na() guard? Because poverty_rate has no missing values:
sum(is.na(states$poverty_rate))   # 0
# In Module 1, yaca was NA for every non-expanding state, and
# NA == 2014 returns NA rather than FALSE, which would have poisoned
# the whole column.


# ---- 4. Look at the comparison --------------------------------------
boxplot(crude_rate_20_64 ~ high_poverty, data = states)

aggregate(crude_rate_20_64 ~ high_poverty, data = states, FUN = mean)

group_means <- aggregate(crude_rate_20_64 ~ high_poverty, data = states, FUN = mean)
diff_obs <- group_means$crude_rate_20_64[2] - group_means$crude_rate_20_64[1]
diff_obs
# ~ +110. High-poverty states averaged about 110 MORE deaths per
# 100,000 working-age people.


# ---- 5. The test ----------------------------------------------------
t.test(crude_rate_20_64 ~ high_poverty, data = states)
# p = 2.3e-07. The confidence interval runs from about -149 to -70.
#
# It is negative because t.test() reports group 0 minus group 1, the
# opposite order from our diff_obs. The magnitude is what matters: the
# data is compatible with a gap of roughly 70 to 150 deaths per
# 100,000. That SIZE is what the p-value alone never tells you.


# ---- 6. Build the p-value yourself ----------------------------------
shuffled <- sample(states$high_poverty)
mean(states$crude_rate_20_64[shuffled == 1]) -
  mean(states$crude_rate_20_64[shuffled == 0])

set.seed(2026)
diffs <- replicate(1000, {
  shuffled <- sample(states$high_poverty)
  mean(states$crude_rate_20_64[shuffled == 1]) -
    mean(states$crude_rate_20_64[shuffled == 0])
})

hist(diffs, xlim = range(c(diffs, diff_obs)))
abline(v = diff_obs, col = "red", lwd = 2)

mean(abs(diffs) >= abs(diff_obs))
# 0 out of 1000. Report as p < 0.001, not p = 0.
# The red line sits well outside the whole null distribution -- which is
# exactly what an overwhelming result looks like.


# ---- 7. The same answer as a regression -----------------------------
m <- lm(crude_rate_20_64 ~ high_poverty, data = states)
summary(m)
# The high_poverty coefficient equals diff_obs from step 4 exactly.


# ---- 8. Discussion answers ------------------------------------------
#
# a) Poverty has the larger effect (~110 vs ~-39) AND the smaller
#    p-value here -- but those are different questions. Effect size is
#    "how big"; the p-value is "how sure we are it isn't zero." A tiny
#    effect measured precisely can have a smaller p than a large effect
#    measured noisily. Always report both.
#
# b) Neither variable was randomly assigned, so neither result is
#    causal. States chose to expand; poverty is a feature of a state,
#    not a treatment. These are associations. Everything today is an
#    association.
#
# c) Poorer states were less likely to expand Medicaid. Poverty also
#    raises mortality. So some of the -64 we attributed to expansion is
#    really poverty doing the work in the other direction -- a
#    confounder. That is the motivation for putting both variables in
#    one model, which is where a regression workshop picks up:
#
#      summary(lm(crude_rate_20_64 ~ expanded + poverty_rate, data = states))
#
#    Run it. The expanded coefficient falls from -39.2 to -12.1 and its
#    p-value goes from 0.13 to 0.49. Most of the little that was left of
#    an expansion gap was poverty. This is not a flaw in the method --
#    it is the method working, and it is the reason nobody stops at a
#    difference in means.
