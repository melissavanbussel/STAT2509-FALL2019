/******************************************************************************************/
/********************************** Course:  Stat 2509           **************************/
/********************************** Project: Lecture-3(CRD-RBD)  **************************/ 
/********************************** Author:  Dr. Fares Said      **************************/ 
/********************************** Date:    Nov 2019            **************************/ 
/******************************************************************************************/

FOOTNOTE1 "Course: Stat 2509    Lecture-3 (CRD-RBD)";
FOOTNOTE2 "Student Name: Your Name  Student ID: 1245639987";

ODS TRACE OUTPUT;

/* Suppose that the effect of a gasoline additive in octane is of interest. An investigator obtains 20
one-liter samples of gasoline and randomly divides these samples into 5 groups of 4 samples each.
The groups are assigned to receive 0, 1, 2, 3, or 4 cc/liter of additive and octane measurements
are made. */ 

/* 1) Perform a Tukey HSD test, use alpha = 0.10 */ 
/* 2) Perform a Brown-Forsythe test, use alpha = 0.10 */ 
/* 3) Perform a Kruskal-Wallis H test */ 

/* First, we import the data into SAS */ 
Data Octane;
	ATTRIB Group LABEL = "Treatment";
	ATTRIB Y LABEL = "Gasoline";
	INPUT Group$ Y @@;
	DATALINES;
A 91.7 A 91.2 A 90.9 A 90.6 B 91.7 B 91.9 B 90.9 B 90.9 
C 92.4 C 91.2 C 91.6 C 91.0 D 91.8 D 92.2 D 92.0 D 91.4 
E 93.1 E 92.9 E 92.4 E 92.4
;
RUN;

/* For the Tukey HSD test, we are testing whether the difference in means between two groups is equal to 0 */ 
/* Null hypothesis is that the difference IS zero; alternative is that the difference is NOT zero */
/* We will have 5 choose 2 = 10 possible pairs */ 
/* Does the confidence interval include the value 0 or not? */ 

/* Use the ANOVA procedure */ 
/* TUKEY option actually performs the test */
/* The CLDIFF option presents the results of the test as confidence intervals for the differences between means */ 
/* The HOVTEST = BF option allows you to complete a Brown-Forsythe test, to test for equality of group variances */
ODS EXCLUDE NObs ClassLevels FitStatistics;
PROC ANOVA DATA = WORK.Octane;
	CLASS Group;
	MODEL Y = Group;
	MEANS Group / TUKEY CLDIFF HOVTEST = BF ALPHA = 0.10;
RUN;
/* We see that there are 6 pairs for which the corresponding groups have (significantly) different means. */ 
/* For the Brown-Forsythe test, p-value > alpha, we do not have evidence to reject null hypothesis and do not have */ 
/* reason to believe that the group variances are unequal */ 

/* We can compare our F_cal = 0.62 from the Brown-Forsythe test to the critical value. */
/* We have df1 = k - 1 = 4, df2 = n - p = 20 - 5 = 15 */  
%PUT Ftab = %SYSFUNC(QUANTILE(F, .90, 4, 15));    /* Critical value */
/* Much larger than 0.62 */ 

/* Next, we perform the Kruskal-Wallis H test */ 
/* Recall: The Kruskal-Wallis H Test is a non-parametric procedure to test the differences in means between groups */
/* The null hypothesis is that the distributions of each group are the same (same shape, same variance etc) */ 
/* Alternative hypothesis is that the distributions of the groups are NOT the same */

/* We use the RANK procedure to rank the data from smallest to largest */
/* Recall: if we have any "tie" values, we take their average rank. */ 
PROC RANK DATA = WORK.OCTANE OUT = RANK;
	VAR Y;
	RANKS rank_Y;
RUN;

/* We use the SORT procedure to sort by the rankings */ 
/* Note: This is equivalent to sorting by Y */ 
PROC SORT DATA = RANK;
	BY Y;
RUN;

/* Calculate the square of the summed ranks for each of the 5 groups, store as "Tsq" */ 
PROC SQL;
	CREATE TABLE RK AS
	SELECT Group, 
	       SUM(rank_Y) AS TR, 
               CALCULATED TR*CALCULATED TR AS Tsq, 
               MEAN(rank_Y) AS Rbar
	FROM Rank
	GROUP BY Group
;

/* Run Kruskal-Wallis H Test*/
PROC NPAR1WAY DATA = WORK.OCTANE WILCOXON;
	CLASS Group;
RUN;
/* Our test statistic is ~11.7 */
/* Note that SAS gives us a different answer than what we calculate by hand; there is a "correction term" */ 
/* Our p-value < alpha, reject H0 and conclude that the distributions of the groups are NOT identical */  
