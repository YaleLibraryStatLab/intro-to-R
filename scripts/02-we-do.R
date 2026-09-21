# =====================================================================
#  MODULE 2  -  WE DO
#  Same pipeline, new question. Work in pairs.
#
#  Question: Do high-poverty states have higher working-age mortality
#            than low-poverty states?
#
#  Every line you need is a line you already ran in Module 1. Where you
#  see ______ , fill it in. Where you see a full line, just run it.
#
#  Rule for pairs: one person types, one person reads the code out loud
#  and says what it should do BEFORE you run it. Swap at step 4.
#
#  Stuck for more than two minutes? Flag us down. That is what we are
#  here for -- do not burn the module on one blank.
# =====================================================================


# ---- 1. Get the data ------------------------------------------------

# This is the state-level file. We built it in Module 1; here it is
# ready-made, with a few extra columns.
states <- read.csv("data/medicaid_states.csv")

# Your three questions for any new dataset. Fill them in:
______(states)     # how big is it?
______(states)     # what are the variables called?
______(states)     # what does a row look like?

# Variables available to you:
#   crude_rate_20_64   deaths per 100,000 aged 20-64      <- the outcome
#   poverty_rate       percent of the state in poverty
#   unemp_rate         unemployment rate
#   median_income      median household income, $thousands
#   expanded           1 = expanded Medicaid in 2014, 0 = did not


# ---- 2. Look at it first --------------------------------------------

# Same rule as Module 1: never test a variable you have not looked at.
# Make a histogram of poverty_rate.
hist(states$______)

# PREDICT before you run it: roughly where will the middle be?


# ---- 3. Build the grouping variable ---------------------------------

# In Module 1 the groups came ready-made (a state expanded, or it did
# not). Poverty is a number, not a group -- so we have to make groups.
#
# We will split at the median: above it is "high poverty", below is not.

median(states$poverty_rate)

# YOUR TURN -- this is the one genuinely new thing in Module 2.
# ifelse(test, value_if_true, value_if_false). Same function as Module 1,
# but the test is new: "is this state's poverty_rate above the median?"
states$high_poverty <- ifelse(______________________________, 1, 0)

# Check it worked. How many states landed in each group?
table(states$high_poverty)

# NOTE: we did not need the !is.na() guard this time. Why not?
# (Look back at Module 1, step 3. Hint: check sum(is.na(states$poverty_rate)).)


# ---- 4. Look at the comparison --------------------------------------
#  >>> SWAP TYPIST HERE <<<

# The y ~ x template. Outcome on the left, groups on the right.
boxplot(crude_rate_20_64 ~ ______, data = states)

# Group means, same template:
aggregate(crude_rate_20_64 ~ ______, data = states, FUN = ______)

# Now pull out the single number: the difference between the two means.
# Row 2 is the high-poverty group, row 1 is the low. Subtract them.
group_means <- aggregate(crude_rate_20_64 ~ high_poverty, data = states, FUN = mean)
diff_obs <- ______________________________________________
diff_obs

# Say out loud what this number means, in units, before moving on.
# "High-poverty states averaged ___ more deaths per 100,000."


# ---- 5. The test ----------------------------------------------------

# Same template again. This will throw an error, see if you can figure it out.
t.test(crude_rate_20_64 ~ high_poverty data = states)

# Read the whole output, not just p. What is the confidence interval,
# and what does it tell you that the p-value does not?


# ---- 6. Build the p-value yourself ----------------------------------

# Shuffle the labels, recompute the difference, one fake world:
shuffled <- sample(states$high_poverty)
mean(states$crude_rate_20_64[shuffled == 1]) -
  mean(states$crude_rate_20_64[shuffled == 0])

# Run that a few times. Watch it bounce around zero.

# Now 1000 fake worlds. Fill in the two blanks -- they are the same
# two lines you just ran.
# You wrote the observed difference by hand in step 4. This is the same
# subtraction, on the shuffled labels instead of the real ones.
set.seed(2026)
diffs <- replicate(1000, {
  shuffled <- sample(states$high_poverty)
  ______________________________________________
})

# Look at the null distribution with your real result marked on it.
#
# NEW BIT: last time our result fit inside the histogram. This time it
# may not. xlim tells hist() how wide to draw the x-axis, and
# range(c(diffs, diff_obs)) says "wide enough for everything."
hist(diffs, xlim = range(c(diffs, diff_obs)))
abline(v = diff_obs, col = "red", lwd = 2)

# What fraction of fake worlds were as extreme as the real one?
# Three pieces: abs() to count both tails, >= to get TRUE/FALSE for each
# shuffle, mean() to turn TRUE/FALSE into a proportion.
mean(______________________________)

# If you got 0, that does NOT mean the probability is zero. It means
# none of our 1000 shuffles got that far -- so p is smaller than about
# 1/1000. Report it as p < 0.001, never as p = 0.


# ---- 7. The same answer as a regression -----------------------------

m <- ______(crude_rate_20_64 ~ high_poverty, data = states)
summary(m)

# Check: does the Estimate on the high_poverty row match your diff_obs
# from step 4? It should, to the decimal.


# ---- 8. Compare your two analyses -----------------------------------

# Module 1 could not distinguish expansion from chance: -39, p = 0.13.
# You just found high poverty associated with about +110, p < 0.001.
#
# Discuss with your partner, then we will take answers:
#
#   a) Which effect is larger? Which is more certain? Are those the
#      same question?
#
#   b) Poverty was not assigned to states by anyone. Neither, really,
#      was expansion. What does that stop you from saying about either
#      result?
#
#   c) Poor states were also less likely to expand Medicaid. What does
#      that do to the Module 1 estimate?
