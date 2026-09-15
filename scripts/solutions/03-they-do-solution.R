# =====================================================================
#  MODULE 3 - SOLUTION
#  Do above-median-unemployment states have higher mortality?
# =====================================================================

# ---- 1. Get the data ------------------------------------------------
states <- read.csv("data/medicaid_states.csv")

dim(states)      # 39 x 6
names(states)
head(states)


# ---- 2. Look at the variable before you test it ---------------------
hist(states$unemp_rate)
# Median 6.19, spanning about 2.8 to 8.2.


# ---- 3. Build the grouping variable ---------------------------------
sum(is.na(states$unemp_rate))   # 0, no guard needed
# (The county file has 21 NAs in unemp_rate. aggregate() DROPPED those
#  rows rather than averaging them -- na.omit is its default. Worth
#  knowing: silent row loss, no warning.)

median(states$unemp_rate)

states$high_unemp <- ifelse(states$unemp_rate > median(states$unemp_rate), 1, 0)

table(states$high_unemp)
# 20 low, 19 high, same off-by-one as Module 2, same reason.


# ---- 4. Look at the comparison --------------------------------------
boxplot(crude_rate_20_64 ~ high_unemp, data = states)

group_means <- aggregate(crude_rate_20_64 ~ high_unemp, data = states, FUN = mean)
group_means

diff_obs <- group_means$crude_rate_20_64[2] - group_means$crude_rate_20_64[1]
diff_obs
# ~ +56. High-unemployment states averaged about 56 more deaths per
# 100,000 working-age people.


# ---- 5. Run the test you already know -------------------------------
t.test(crude_rate_20_64 ~ high_unemp, data = states)
# p = 0.029. CI runs about -106 to -6 (t.test reports group 0 minus
# group 1, so the sign is flipped from diff_obs).
#
# In words: high-unemployment states had higher working-age mortality,
# by somewhere between roughly 6 and 106 deaths per 100,000. The lower
# end of that interval is close to zero, so this is suggestive rather
# than settled.


# ---- 6. Build the p-value yourself ----------------------------------
set.seed(2026)
diffs <- replicate(1000, {
  shuffled <- sample(states$high_unemp)
  mean(states$crude_rate_20_64[shuffled == 1]) -
    mean(states$crude_rate_20_64[shuffled == 0])
})

hist(diffs, xlim = range(c(diffs, diff_obs)))
abline(v = diff_obs, col = "red", lwd = 2)

mean(abs(diffs) >= abs(diff_obs))
# 0.030, against t.test's 0.029. Same conclusion, no formula required.


# ---- 7. The same answer as a regression -----------------------------
m <- lm(crude_rate_20_64 ~ high_unemp, data = states)
summary(m)
# high_unemp coefficient = 55.87, matching diff_obs exactly.
# p = 0.027. Note that is the POOLED p; t.test's Welch default gave
# 0.029. t.test(..., var.equal = TRUE) is the one that matches lm().


# ---- 8. Write down what you found -----------------------------------
#
# ANSWER:
# Across 39 states in 2014, those with above-median unemployment had
# working-age mortality about 56 deaths per 100,000 higher than states
# below the median (95% CI roughly 6 to 106; t-test p = 0.029). A
# permutation test that makes no distributional assumption returns
# essentially the same p-value (0.030), so the result does not hinge on
# normality. The interval is wide and its lower bound is near zero, so
# this is suggestive, not decisive.
#
# It is not causal. Unemployment was not assigned to states; it travels
# with poverty, industry mix, age structure, and health-system capacity,
# any of which could produce this gap on its own. With n = 39 states we
# also have very little power to separate them.


# =====================================================================
#  EXTENSION ANSWERS
# =====================================================================

# --- 1. median_income instead ---
states$high_income <- ifelse(states$median_income > median(states$median_income), 1, 0)
t.test(crude_rate_20_64 ~ high_income, data = states)
# High-income states average about 117 FEWER deaths per 100,000
# (t.test p = 6.8e-07), much stronger than unemployment, and in the
# expected direction. Note these three groupings (poverty,
# unemployment, income) are largely re-sorting the same states, so they
# are not three independent findings.


# --- 2. what dichotomising cost ---
plot(states$unemp_rate, states$crude_rate_20_64)
abline(lm(crude_rate_20_64 ~ unemp_rate, data = states))
summary(lm(crude_rate_20_64 ~ unemp_rate, data = states))
# As a continuous predictor: about 20 more deaths per 100,000 for each
# extra percentage point of unemployment, p = 0.028 -- essentially what
# the median split gave (0.029), off the same 39 states.
#
# Splitting at the median threw away the difference between 4% and 6%
# unemployment, and between 8% and 12%. That is real information, and
# discarding it costs power. Dichotomise for a picture; model the
# continuous variable for an answer.


# --- 3. two variables at once ---
summary(lm(crude_rate_20_64 ~ unemp_rate + poverty_rate, data = states))
#
# Read this one carefully. On its own, unemployment looked
# HARMFUL: +20 deaths per point (p = 0.028). Put poverty in the model
# and unemployment's coefficient flips sign to -9.1 and loses
# significance (p = 0.22), while poverty comes in at +21.8 (p = 6e-08).
#
# The two travel together (cor = 0.59). Alone, unemp_rate was partly
# standing in for poverty. Once poverty is measured directly and held
# fixed, what is left of unemployment points the other way.
#
# Do not over-read the flip, n = 39, and these are states, not people.
# The lesson is the fragility, not the new sign: a coefficient means
# nothing except relative to what else is in the model. Same lesson as
# Module 2's expansion result. A difference in means is where an
# analysis starts, not where it ends.
