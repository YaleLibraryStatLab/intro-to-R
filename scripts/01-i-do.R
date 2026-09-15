# =====================================================================
#  MODULE 1  -  I DO
#
#  Question: Did states that expanded Medicaid in 2014 have lower
#            working-age mortality than states that did not?
#
#  Type along with me. I will say every line before I type it, and the
#  slide will show it. Run each line as you write it: Cmd+Enter (Mac)
#  or Ctrl+Enter (Windows). Watch the Console and the Plots pane.
#
#  Fallen behind? Don't scramble. Put up a red sticky, keep listening,
#  and copy the line you missed from scripts/solutions/01-i-do-solution.R
#  when we pause. That file also has the full commentary to take home.
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

# Read data/medicaid.csv and store it as `counties`.
# Column 1 is row labels, not data.



# Three questions for every new dataset: how big, what columns,
# what does a row look like.






# ---- 2. Look at the outcome before you test anything ----------------

# A histogram of crude_rate_20_64. Defaults are fine.






# ---- 3. Build the comparison we actually want -----------------------

# Medicaid expansion is a STATE policy. Every county in a state shares
# one decision, so we need one row per state before we compare anything.

# 3a. Keep one year: the rows of `counties` where year is 2014.
#     Call it `d2014`. Then check its size.






# 3b. Label each state. Make a column `expanded`: 1 if the state
#     expanded in 2014, 0 otherwise. Guard against the NAs in `yaca`.
#     Then count how many landed in each group.






# 3c. Average to the state. This is the first version, and it hides a
#     decision: it gives every county one vote regardless of size.
#     Call it `states_unwt`.






#     Look at how far apart the county populations are.



# 3d. A rate is deaths over people. Add up the deaths, add up the
#     people, divide once. Call the result `states`.
#     Then sort both tables by state so the shuffling later lines up.










#     How far apart are the two versions, and which states move most?






# ---- 4. DESCRIBE: look at the comparison ----------------------------

# A boxplot of crude_rate_20_64 broken down by expanded.
# Then the two group means.






# Save the difference between the two means as `diff_obs`.
# Row 2 is the expanded group, row 1 is not.






# ---- 5. TEST: the test you already know -----------------------------

# A t-test of crude_rate_20_64 broken down by expanded.
# Read the whole output, not just the p-value.






# ---- 6. CHECK: what that p-value actually means ---------------------

# Shuffle the expansion labels once. Run it a few times.



# Check what stays fixed when you shuffle.



# One fake world: shuffle, then recompute the difference.






# Now a thousand fake worlds. Seed it first so we all get the same
# numbers, then collect the differences in `diffs`.










# The null distribution, with our real result marked on it.






# What fraction of fake worlds were as extreme as ours?
# Then try it without abs() and see what changes.






# ---- 7. MODEL: the same answer, as a regression ---------------------

# Fit crude_rate_20_64 on expanded. Store it as `m`, then read it.
# You need two numbers: the Estimate and Pr(>|t|) on the expanded row.






# ---- 8. Why we used 39 rows and not 2,372 --------------------------

# The same test, run on the counties instead of the states.
# Watch what happens to the p-value, and ask why it is wrong.






# =====================================================================
#  Functions you used today:
#
#    read.csv  dim  names  head  summary     <- get data, look at it
#    hist  boxplot  abline                   <- pictures
#    ifelse  is.na  table                    <- build a grouping variable
#    aggregate  mean  median  abs  range     <- summarise
#    c  order                                <- combine and sort
#    t.test  lm                              <- test and model
#    sample  set.seed  replicate             <- the permutation test
#
#  Twenty-three. That is a whole paper's worth of analysis.
# =====================================================================
