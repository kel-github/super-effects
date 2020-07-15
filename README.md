# Super-Effects

Lead: Kelly Garner; Co-authors: Abbey Nydam, Zoie Nott; PI: Paul Dux <p>
Working Title: The contribution of sample size to the reproducability of individual differences methods in cognitive psychology 

Project Overview:

Aim is to assess the generalizability of effect sizes across different sample sizes. Inspired by Howard Bowman's paper: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6018568/ Also see this paper by Tal Yarkoni: https://psyarxiv.com/jqw35effect 

Backround: 

Data taken from the Executive Function and Implicit Learning (EFIL) project run by Abbey Nydam and Paul Dux for the Team Honours Thesis in 2019.
It included data from ~350 1st-year psychology participants on a battery of seven cognitive tasks: 

Tasks were:
1. Operation Span
2. Attentional Blink
3. Go No-Go Task
4. Single Dual Task
5. Contextual Cuing
6. Serial Reaction Time Task
7. Visual Statistical Learning

These were organised into 4 tasks that tap executive functions (OS, AB, GNG, SD) and 3 that tap implicit learning (CC, SRT, VSL). The aim of the EFIL study was to look for relationships between and across EF and IL task, using an individual differnces approach (i.e., correlating individual scores across tasks). We found correlations between OS and AB, AB and VSL (I think - Abbey to check).

<b>Planned Analysis:</b>

1) Sample effect-sizes across varying Ns (for each of the 7 tasks) using the effect-size estimates generated by anova/t-tests (i.e., fixed effects modelling)
2) Sample effect-sizes across varying Ns (for each of the 7 tasks) using the linear mixed-effects modelling (i.e., MLM) 
3) Sample effect-sizes across varying Ns for the correlations between the 7 tasks using the standard binomial correlations from fixed-effects
4) Sample effect-sizes across varying Ns for the correlations between the 7 tasks using linear mixed-effects modelling

<b>Data Structures:</b>

Original data is in .mat files (hosted by Abbey - 1 file per 7 tasks)
Trial level data is in .xls or .csv format (analysed by MATLAB scripts from Abbey)
Condition level data is in .xls or .csv format  (analysed by MATLAB scripts from Abbey)

<b>Analysis:</b>

<b>*Existing scripts* </b>

MATLAB scripts to analyse task effects using fixed-effects models (i.e., using ANOVA & t-tests) from Abbey
MATLAB scripts to compute correlations using fixed-effects models (i.e., 4 EF and 3 Il tasks) from Abbey
Example R script to run the effect-size resampling written in R by Kelly for SRT task (see "SRT.r" file)

<b> *Scripts to Generate* </b>

R scripts for the mixed-effects analysis of each task effect
R scripts to run effect-size resampling on remaining 6 tasks - see example "SRT.r" file

<b> *Help files* </b>
  
  Tutorials in R - "... "
