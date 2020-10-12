---
layout: post
title: "Judging judges (round 2)"
author: "Jacob Toner Gosselin"
date: 2020-10-11 
categories: sentencing ideas
---

## Checking significance

A ranking is one thing, but for context we want to see if the judges at the top of our ranking do seem to hand down “severe” sentences at a significant rate. Otherwise, the differences we see in the variables that make up our severity metric (percent of prison sentences “above the median” and percent of class 4 felony sentences resulting in prison time) could just be statistical noise.

Two years ago, when I was only looking at Judge Maura Slattery Boyle, I did this by “bootstrap”, i.e. resampling data with replacement. My logic was that doing it this way I wouldn’t have to assume the distribution of the statistic (in this case, the two aforementioned variables). I could draw a 95% confidence interval around the variables for Judge Slattery Boyle, and then compare that confidence interval to the actual values of the variables in the entire population. If the bottom end of the confidence interval was above the actual value of the variable in the entire dataset (which was the case), I could say at a p-val of .05 that Judge Slattery-Boyle’s sentences weren’t randomly picked from the population at large. In other words, she was sentencing at a higher rate than the “average” judge.

In retrospect, this approach wasn’t particularly elegant or effective. I didn’t want to do a simple linear regression because I was dealing with two dummy variables, and the distribution of the regression residuals wouldn’t be even close to normal. My understanding then (and now, although I’d love if someone could walk me through this like I was 5) was that while non-normal residuals don’t violate the Gauss-Markov theorem, they did make it impossible to interpret the t statistics/p-values produced, and the p-value was all I really wanted.

However, looking back now I’ve had a change of heart for two reasons. Number one, as long as the Gauss-Markov assumptions are satisfied (we can adjust for heteroskedasticity using robust standard errors), the coefficient produced by my linear regression is still BLUE and consistent, meaning that given the massive sample size offered by this data (well over 100k cases), I feel more comfortable interpreting the coefficient than I did then. Number two, the biggest concern I always had was omitted variable bias, and by using a linear regression to assess significance I’m able to control for two additional variables that I didn’t account for in my bootstrap method: sentence date (as a continuos variable, assuming sentences have gotten more lenient over time) and sentence years (as fixed effects, assuming sentencing norms/rules might change year to year).

So, below I have five regression tables for five judges: Maura Slattery Boyle (still leading by my severity metric, and I want to see if controlling for the additional covariates changes the results for her), Ursula Walowski, Mauricio Araujo, Thomas Byrne, and William Raines (all up for retention and in the top third of judges by sentencing severity). Each table has three columns for three dependent variables

1. Dummy variable for sentence being above the median (0 if not, 1 if so, only using sentences that resulted in prison or jail time)
2. Dummy variable for sentence being a class 4 felony and resulting in prison time (0 if class 4 felony sentenced to probation, 1 if class 4 felony sentenced to prison or jail, only using sentences on class 4 felonies where the outcome was prison or jail)
3. Dummy variable for a sentence being “severe” (1 if sentence is for prison or jail and “above the median” for that particular felony class OR if a sentence is for prison or jail and the charge is a class 4 felony, 0 otherwise, using all sentences resulting in prison, jail, or probation time)

<table>
<table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Above median sentence</td><td>Class 4 prison sentence</td><td>Severe sentence</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">boyle_dummy</td><td>0.078<sup>***</sup></td><td>0.132<sup>***</sup></td><td>0.104<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.011)</td><td>(0.013)</td><td>(0.013)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">sentence_date</td><td>0.00002</td><td>-0.00001</td><td>0.00000</td></tr>
<tr><td style="text-align:left"></td><td>(0.00001)</td><td>(0.00002)</td><td>(0.00002)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>1.246<sup>***</sup></td><td>0.013</td><td>1.048<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.193)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>129,586</td><td>96,051</td><td>214,571</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.002</td><td>0.004</td><td>0.001</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
<tr><td style="text-align:left"></td><td colspan="3" style="text-align:right">Also controlling for sentence year fixed effects</td></tr>
</table>

<table>
  <table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Above median sentence</td><td>Class 4 prison sentence</td><td>Severe sentence</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">walowski_dummy</td><td>0.042<sup>**</sup></td><td>0.125<sup>***</sup></td><td>0.073<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.017)</td><td>(0.021)</td><td>(0.021)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">sentence_date</td><td>0.00002</td><td>-0.00001</td><td>0.00000</td></tr>
<tr><td style="text-align:left"></td><td>(0.00001)</td><td>(0.00002)</td><td>(0.00002)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>1.231<sup>***</sup></td><td>0.015</td><td>1.029<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.193)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>129,586</td><td>96,051</td><td>214,571</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.002</td><td>0.004</td><td>0.001</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
<tr><td style="text-align:left"></td><td colspan="3" style="text-align:right">Also controlling for sentence year fixed effects</td></tr>
</table>

<table>
  <table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Above median sentence</td><td>Class 4 prison sentence</td><td>Severe sentence</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">araujo_dummy</td><td>0.052<sup>***</sup></td><td>0.003</td><td>-0.027</td></tr>
<tr><td style="text-align:left"></td><td>(0.016)</td><td>(0.016)</td><td>(0.016)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">sentence_date</td><td>0.00002</td><td>-0.00001</td><td>0.00000</td></tr>
<tr><td style="text-align:left"></td><td>(0.00001)</td><td>(0.00002)</td><td>(0.00002)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>1.231<sup>***</sup></td><td>0.015</td><td>1.034<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.193)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>129,586</td><td>96,051</td><td>214,571</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.002</td><td>0.003</td><td>0.001</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
<tr><td style="text-align:left"></td><td colspan="3" style="text-align:right">Also controlling for sentence year fixed effects</td></tr>
</table>

<table>
  <table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Above median sentence</td><td>Class 4 prison sentence</td><td>Severe sentence</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">byrne_dummy</td><td>0.074<sup>***</sup></td><td>-0.015</td><td>0.023</td></tr>
<tr><td style="text-align:left"></td><td>(0.015)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">sentence_date</td><td>0.00002</td><td>-0.00001</td><td>0.00000</td></tr>
<tr><td style="text-align:left"></td><td>(0.00001)</td><td>(0.00002)</td><td>(0.00002)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>1.234<sup>***</sup></td><td>0.015</td><td>1.032<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.193)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>129,586</td><td>96,051</td><td>214,571</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.002</td><td>0.003</td><td>0.001</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
<tr><td style="text-align:left"></td><td colspan="3" style="text-align:right">Also controlling for sentence year fixed effects</td></tr>
</table>

<table>
  <table style="text-align:center"><tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="3"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="3" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Above median sentence</td><td>Class 4 prison sentence</td><td>Severe sentence</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">raines_dummy</td><td>-0.124<sup>***</sup></td><td>0.161<sup>***</sup></td><td>0.115<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.015)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">sentence_date</td><td>0.00002</td><td>-0.00002</td><td>0.00000</td></tr>
<tr><td style="text-align:left"></td><td>(0.00001)</td><td>(0.00002)</td><td>(0.00002)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>1.267<sup>***</sup></td><td>0.018</td><td>1.011<sup>***</sup></td></tr>
<tr><td style="text-align:left"></td><td>(0.193)</td><td>(0.018)</td><td>(0.018)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>129,586</td><td>96,051</td><td>214,571</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.002</td><td>0.004</td><td>0.001</td></tr>
<tr><td colspan="4" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="3" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
<tr><td style="text-align:left"></td><td colspan="3" style="text-align:right">Also controlling for sentence year fixed effects</td></tr>
</table>

  
