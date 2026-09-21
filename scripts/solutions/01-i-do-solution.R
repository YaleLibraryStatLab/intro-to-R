# =====================================================================
#  MODULE 1 - SOLUTION (the annotated version)
#
#  Question: Did states that expanded Medicaid in 2014 have lower
#            working-age mortality than states that did not?
#
#  This is the completed script with the full commentary. Work from
#  scripts/01-i-do.R during the session and type along; come back here
#  afterwards, or if you fall behind and need to catch up.
#
#  The four passes, each auditing the one before:
#
#    DESCRIBE  what do the two groups look like?        (section 4)
#    TEST      is the gap bigger than chance?           (section 5)
#    CHECK     does the test's assumption change it?    (section 6)
#    MODEL     the same finding, as a coefficient       (section 7)
#
#  Sections 1-3 get the data into the right shape.
# =====================================================================


# ---- 1. Get the data ------------------------------------------------

# PREDICT before you run the next line: what do you think R will print?

# read.csv() reads a spreadsheet off disk and hands back a data frame:
# rows are observations, columns are variables.
counties <- read.csv("data/medicaid.csv", row.names = 1)

# Nothing printed. That is success, not failure.
#   <-            means "store this as". Storing is silent.
#   row.names = 1 means "the first column is row labels, not data",
#                 which is why we get 13 columns from a 14-column file.
#
# To see that it worked, look at the Variables pane on the right --
# `counties` is now sitting in it.

# Three questions to ask of any new dataset. Always these three.
dim(counties)    # how big is it?  (rows, columns)
names(counties)  # what are the variables called?
head(counties)   # what does a row actually look like?

# head() prints wide data as stacked blocks. That is ONE table that ran
# out of room, not three tables.

# The variables we care about:
#   crude_rate_20_64  deaths per 100,000 people aged 20-64   <- our outcome
#   yaca              year the state expanded Medicaid, NA if it never did
#   year              2009 - 2019
#
# Note: this extract covers 39 states, not 50. Some states (NY, PA, MA,
# VA and others) are simply not in the file. Worth knowing before you
# wonder later where they went.


# ---- 2. Look at the outcome before you test anything ----------------

# Never run a test on a variable you have not looked at.
hist(counties$crude_rate_20_64)

# The $ pulls one column out of a data frame. counties$crude_rate_20_64
# is a vector -- just a row of numbers, one per county. That is all
# hist() ever wants.

# We took the default settings. They are fine. Making it pretty is a
# thing you do at the end, if ever.

# WATCH OUT -- the most common mistake you will make all day:
# misspell a column name and R does NOT give you an error. It hands
# back NULL, and then the NEXT function complains about something else
# entirely. Try it:
#
#   counties$crude_rate2064          # NULL. No error.
#   hist(counties$crude_rate2064)    # "'x' must be numeric"
#
# That second message will send you off checking whether your data
# imported as text. It didn't. You typed the name wrong.
# "'x' must be numeric" almost always means "check your spelling".


# ---- 3. Build the comparison we actually want -----------------------

# Medicaid expansion is a STATE policy. Every county in Alabama has the
# same policy as every other county in Alabama.
#
# So our real sample size is the number of states, not the number of
# counties. This is the most important line of the whole workshop.

# Keep one year so we are comparing like with like.
d2014 <- counties[counties$year == 2014, ]

# Square brackets take a slice: df[rows, columns].
# We asked for "rows where year is 2014" and "all columns" (blank).
#
# Note we write `counties` twice -- once to say which table, once inside
# to say which column to test. Unlike Stata, the dataset is never
# implied. R needs to be told every time.
dim(d2014)

# Now build the grouping variable. ifelse(test, value_if_true, value_if_false)
# runs down the whole column and returns a new column.
#   !  means "not"
#   &  means "and"
# And note $ is doing a NEW job here: on the left of <- it CREATES a
# column rather than pulling one out.
d2014$expanded <- ifelse(!is.na(d2014$yaca) & d2014$yaca == 2014, 1, 0)

# The !is.na() guard matters: states that never expanded have yaca = NA,
# and NA == 2014 is not FALSE, it is NA.
#
# Drop the guard and R does NOT error. Run this and look:
#
#   table(ifelse(d2014$yaca == 2014, 1, 0), useNA = "ifany")
#
# You get 890 NAs and no complaint at all, and every mean you compute
# from it comes back NA. Silent wrong answers are worse than errors.
table(d2014$expanded)

# One honesty note: yaca is also 2020, 2021 and 2023 for some states.
# Those are coded 0 here, so `expanded` means "expanded in the 2014
# wave", not "ever expanded". Fine for a 2014 snapshot -- but say so.

# PREDICT: after we collapse to states, how many rows will there be?

# aggregate() applies a function to a variable, split by group.
# Read it out loud: "average crude_rate, by state and expansion status."
#
# FUN = mean passes the function itself, with no parentheses. Writing
# FUN = mean() would try to run mean right now, on nothing, and fail.
states_unwt <- aggregate(crude_rate_20_64 ~ state + expanded,
                         data = d2014,
                         FUN  = mean)

dim(states_unwt)   # 39 rows -- one per state -- down from 2,372 county rows

# STOP. That line looks obvious and it hides a decision.
#
# It averaged the county RATES, giving every county one vote:
range(d2014$population_20_64)
#
# 224 people, and 6.3 million. Loving County, Texas just counted for as
# much as Los Angeles. A county of 224 people should not count the same
# as a county of 6.3 million when you are computing a state's rate.

# A rate is deaths divided by people. To get a STATE's rate, add up the
# deaths and add up the people, then divide once.
d2014$deaths <- d2014$crude_rate_20_64 * d2014$population_20_64 / 1e5

# Same aggregate() template as before, twice, with FUN = sum this time.
state_deaths <- aggregate(deaths ~ state + expanded,
                          data = d2014, FUN = sum)
state_people <- aggregate(population_20_64 ~ state + expanded,
                          data = d2014, FUN = sum)

# Both grouped the same way, so their rows line up. Now divide, once.
states <- state_deaths
states$crude_rate_20_64 <- state_deaths$deaths /
                           state_people$population_20_64 * 1e5

# aggregate() hands rows back grouped, not alphabetically. Sort them, so
# that the shuffling in step 6 lines up with the file Modules 2 and 3
# use. Same seed on a different row order gives a different answer.
states      <- states[order(states$state), ]
states_unwt <- states_unwt[order(states_unwt$state), ]

# Same 39 states, two different answers for each one. How far apart?
gap <- states_unwt$crude_rate_20_64 - states$crude_rate_20_64
summary(gap)

# Which states move the most? Bracket subsetting again -- same job as
# step 3, picking rows where a test comes out TRUE.
states$state[abs(gap) > 75]

# Texas is off by more than 130 deaths per 100,000. That is bigger than
# any effect we are about to go looking for.
#
# We will use the weighted one, because it is the state's actual rate.
# Hold on to the other one -- we come back to it in step 8.


# ---- 4. DESCRIBE: look at the comparison ----------------------------

# y ~ x reads "y broken down by x". Remember that squiggle. It is the
# same shape for plots, group means, tests, and models -- all day.
boxplot(crude_rate_20_64 ~ expanded, data = states)

# LOOK at that before you go on. The two boxes overlap enormously, and
# your eye says "these are the same." That reaction is correct.
#
# A test does not contradict your eye. It answers a narrower question:
# not "can I tell these states apart" (you can't -- look at the spread)
# but "are the two AVERAGES further apart than shuffling would produce".
# Those are different questions, and only the second one has an answer
# here.

# Same template, different goal: group means instead of a picture.
aggregate(crude_rate_20_64 ~ expanded, data = states, FUN = mean)

# The estimate we care about, as a single number.
# Save it -- we will need it in step 6.
group_means <- aggregate(crude_rate_20_64 ~ expanded, data = states, FUN = mean)

# group_means has 2 rows. Row 1 is expanded = 0, row 2 is expanded = 1,
# because aggregate() sorts the groups. Look at it and confirm:
group_means

# A bracket with ONE number picks one element out of a vector:
# x[2] is the second one. This is not the df[rows, columns] rule from
# step 3 -- same brackets, different job, because this is a single
# column rather than a whole table.
diff_obs <- group_means$crude_rate_20_64[2] - group_means$crude_rate_20_64[1]
diff_obs

# We wrote [2] - [1], so this is (expanded) minus (not expanded).
# Negative means expansion states were LOWER. Get this order backwards
# on your own data and your headline result flips sign silently.

# Expansion states averaged about 39 fewer deaths per 100,000.
#
# States chose whether to expand, so the honest sentence is "expansion
# states had lower mortality", not "expansion lowered mortality". And
# the alternative to a real effect is not only luck -- it is anything
# else that differs between these two sets of states. Module 2 cashes
# that in.
#
# For now: is 39 more than we would expect from luck alone?


# ---- 5. TEST: the test you already know -----------------------------

# Same y ~ x template. Third time.
t.test(crude_rate_20_64 ~ expanded, data = states)

# STOP. The confidence interval says -12 to +91, and the number we just
# computed was -39. That is not an error, and it is not you.
#
# t.test() subtracts in the opposite order from us: it does
# group 0 minus group 1, we did group 1 minus group 0. Same gap,
# opposite sign. Check the two group means at the bottom of the output
# against our -39 and you will see they agree.
#
# This catches everyone once. When a sign looks wrong, find out which
# way round the subtraction went before you assume you broke something.

# Now read the rest, and do not just harvest the p-value:
#   - the two group means, at the bottom
#   - the confidence interval: the SIZE of the gap the data supports,
#     anywhere from 12 FEWER to 91 MORE deaths per 100,000. That interval
#     crosses zero. The p-value never tells you that.
#   - p = 0.13
#
# Std. Error is how much this difference would vary if you drew the
# sample again. You can ignore t and df today. (Yes, df can have decimals; that
# is Welch's correction, see step 7.)


# ---- 6. CHECK: what that p-value actually means ---------------------

# First, the definition almost everyone walks in with:
#
#     "p is the probability the result is due to chance."
#
# That is the common answer and it is wrong. It has the logic backwards.
# A p-value does not tell you the probability that chance caused your
# result. It ASSUMES chance is all there is, and then asks:
#
#     if expansion made no difference at all, how often would luck
#     alone hand us a gap as big as ours?
#
# We do not have to trust a formula for that. We can just do it.

# The null hypothesis says the labels are meaningless. So let's make
# them meaningless -- shuffle which states "expanded".
sample(states$expanded)

# Run that line a few times. Different shuffle every time.
#
# Note what stays fixed:
table(sample(states$expanded))
# Always 22 ones and 17 zeros. We are dealing out the SAME labels in a
# new order, not flipping a coin for each state.

# One fake world: shuffle the labels, recompute the difference.
shuffled <- sample(states$expanded)
mean(states$crude_rate_20_64[shuffled == 1]) -
  mean(states$crude_rate_20_64[shuffled == 0])

# The square brackets again, doing a fourth job: states$crude_rate_20_64
# [shuffled == 1] means "the mortality rates where the shuffled label
# came out 1". You are picking rows with TRUE/FALSE instead of numbers.

# Run those two lines a few times. Sometimes positive, sometimes
# negative, no particular pattern -- that IS sampling variation, and you
# are looking straight at it.
#
# Now the thing to actually notice: keep running it and see how OFTEN
# you land somewhere near -39. Chance produces gaps that size routinely.

# PREDICT: out of 1000 fake worlds, how many will beat our real -39?

# replicate() does the same thing n times and collects the answers.
set.seed(2026)   # so everyone in the room gets the same numbers
#
# set.seed() is not optional here. Without it every person in this room
# gets a different p-value, and so do you the next time you run the file.
# Seed it, and write the seed down. Note also that the seed fixes the
# SHUFFLES, not the data -- reorder your rows and the same seed gives a
# different answer, which is why we sorted `states` back in step 3.
diffs <- replicate(1000, {
  shuffled <- sample(states$expanded)
  mean(states$crude_rate_20_64[shuffled == 1]) -
    mean(states$crude_rate_20_64[shuffled == 0])
})

# 1000 differences from 1000 worlds where the policy did nothing.

# And now the same hist() from step 2, pointed at something new.
hist(diffs)
abline(v = diff_obs, col = "red", lwd = 2)   # our real result, in red

# How many fake worlds were as extreme as the real one?
# This one line does three things, and all three are worth knowing:
#
#   abs()            throws away the minus sign, so we count BOTH tails
#                    -- shuffles beyond -39 AND beyond +39. That is what
#                    "two-sided" means, and it is what t.test() did too.
#
#   >=               gives a TRUE/FALSE for each of the 1000 shuffles.
#
#   mean()           of TRUE/FALSE gives the PROPORTION that are TRUE,
#                    because TRUE counts as 1 and FALSE as 0. That is
#                    the counting step. This trick is everywhere in R.
mean(abs(diffs) >= abs(diff_obs))

# Drop the abs() and watch what happens:
mean(diffs >= diff_obs)
#
# You get 0.93, not something near 0.14. Our difference is NEGATIVE, so
# "shuffles at least as big as ours" counts almost everything. R will not
# warn you. If you want the one-sided p in the direction of the effect it
# is mean(diffs <= diff_obs). Getting this wrong does not error -- it
# just hands you the wrong number, confidently.

# That is a p-value. We built it out of sample(), mean(), and counting.
# The t-test said 0.13; the shuffle says 0.14. Same conclusion.
#
# They will not match exactly, and should not. t.test() assumes a normal
# distribution; the shuffle does not. And 1000 shuffles is itself a
# sample -- change the seed and the second digit moves. If that spread
# bothers you, run 10,000 instead of 1,000.

# CAREFUL: the shuffle is not assumption-free. It assumes the labels
# could have been dealt out any other way. That holds here, because each
# state made one decision. It does NOT hold if your rows are grouped --
# students inside classrooms, years inside countries -- because a shuffle
# that splits a group apart is not a world that could have happened.

# One more thing about your own data: `shuffled == 1`
# works only because our labels are the numbers 0 and 1. If your grouping
# is "treated"/"control", you need `shuffled == "treated"`. Get it wrong
# and R returns NaN with no error -- the same silent failure as step 3.


# ---- 7. MODEL: the same answer, as a regression ---------------------

# A difference in means is a regression coefficient. Same y ~ x.
m <- lm(crude_rate_20_64 ~ expanded, data = states)
summary(m)

# This printout is dense. You need exactly two numbers from it today,
# both on the `expanded` row:
#
#   Estimate    -39.18  <- our difference in means. The same number.
#   Pr(>|t|)      0.13   <- our p-value. The same number.
#
# And one bonus, on the row above:
#
#   (Intercept)          <- the mean of the group coded 0. Check it
#                           against the group means from step 4. Identical.
#                           The "intercept" is just the baseline group.
#
# Std. Error is how much the Estimate would vary if you drew the sample
# again. Here it is 25.4 against an Estimate of -39.2, so the data is
# consistent with a wide range of values, including zero. That is
# little. That is what this result amounts to.
#
# Residuals, R-squared and the F-statistic answer questions we have not
# asked yet. They are the next workshop.
#
# So: a difference in means IS a regression coefficient. Once you can
# read this output you can read most quantitative papers.
#
# (t.test() uses Welch's correction by default, so the third decimal
#  differs, and that is also why its df was 34.63 rather than 37.
#  t.test(..., var.equal = TRUE) matches lm() exactly. Try it.)


# ---- 8. Why we used 39 rows and not 2,372 --------------------------

# Here is the same test, run on the counties instead of the states.
t.test(crude_rate_20_64 ~ expanded, data = d2014)

# p is about 6e-17. Overwhelming, and wrong.
#
# It believes it has 2,372 independent observations. It has 39. Every
# county in a state shares one policy decision, so those rows repeat 39
# pieces of information rather than adding 2,372 new ones. Feed a test
# more rows than you have information and the Std. Error shrinks until
# any difference looks certain.
#
# You already saw the other version of this in step 3: averaging county
# rates instead of weighting by population gave -64 and p = 0.028, where
# weighting correctly gives -39 and p = 0.13. Neither was an arithmetic
# error. Which rows count as an observation, and how much each one
# counts, are decisions you make before any test runs.
#
# When a p-value looks too good, ask how many independent things you
# actually measured. It is usually fewer than the number of rows.

# =====================================================================
#  Every function used in this entire analysis:
#
#    read.csv  dim  names  head  summary       <- get data, look at it
#    hist  boxplot  abline                     <- pictures
#    ifelse  is.na  table                      <- build a grouping variable
#    aggregate  mean  median  abs  range       <- summarise
#    c  order                                  <- combine and sort
#    t.test  lm                                <- test and model
#    sample  set.seed  replicate               <- the permutation test
#
#  Twenty-three, and 18 of them you used more than once.
#  That is a whole paper's worth of analysis. You do not need more
#  to start -- and the next two modules add almost nothing new.
# =====================================================================
