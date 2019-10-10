/***************************************************************************************/
/********************************** Course:   Stat 2509       **************************/
/********************************** Project:  Lecture-2(MLR)  **************************/ 
/********************************** Author:   Dr. Fares Said  **************************/ 
/********************************** Date: 	  Oct 2019        **************************/ 
/***************************************************************************************/

FOOTNOTE1 "Course: Stat 2509; Lecture-2 (MLR)";
FOOTNOTE2 "Student Name: Your Name; Student ID: 1245639987";

/***************************************************************************************/
/************************ Example 6.1 (Kinesiologist): in Lecture-2 ********************/ 
/***************************************************************************************/

/* A kinesiologist is investigating measures of the physical fitness of persons entering 10-kilometer
races. A major component of overall fitness is cardiorespiratory capacity as measured by
maximal oxygen uptake. Direct measurement of maximal oxygen is expensive, and thus is
difficult to apply to large groups of individuals in a timely fashion. The researcher wanted
to determine if a prediction of maximal oxygen uptake can be obtained from a prediction
equation using easily measured explanatory variables from the runners. In a preliminary study,
the kinesiologist randomly selects 54 males and obtains the following data for the variables: */ 
 
/* Y = maximal oxygen uptake (in liters per minute) */
/* X1 = weight (in kilograms) */
/* X2 = age (in years) */
/* X3 = time necessary to walk 1 mile (in minutes) */
/* X4 = heart rate at end of the walk (in beats per minute) */ 

/* Create the dataset in SAS, save in a table called Oxygen */ 
/* Recall: the @@ is required if you want to enter more than one observation per line */  
DATA Oxygen;
	ATTRIB Y LABEL = "Maximal Oxygen uptake";
	ATTRIB X1 LABEL = "Weight";
	ATTRIB X2 LABEL = "Age";
	ATTRIB X3 LABEL = "Time";
	ATTRIB X4 LABEL = "Heart rate";
	INPUT Y  X1 X2 X3 X4 @@;
	DATALINES;
	1.5 139.8 19.1 18.1 133.6 2.1 143.3 21.1 15.3 144.6 1.8 154.2 21.2 15.3 164.6 2.2 176.6 23.2 17.7 139.4 2.2 154.3 22.4 17.1 127.3
	2.0 185.4 22.1 16.4 137.3 2.1 177.9 21.6 17.3 144.0 1.9 158.8 19.0 16.8 141.4 2.8 159.8 20.9 15.5 127.7 1.9 123.9 22.0 13.8 124.2
	2.0 164.2 19.5 17.0 135.7 2.7 146.3 19.8 13.8 116.1 2.4 172.6 20.7 16.8 109.0 2.3 147.5 21.0 15.3 131.0 2.0 163.0 21.2 14.2 143.3
	1.7 159.8 20.4 16.8 156.6 2.3 162.7 20.0 16.6 120.1 0.9 133.3 21.1 17.5 131.8 1.2 142.8 22.6 18.0 149.4 1.9 146.6 23.0 15.7 106.9
	0.8 141.6 22.1 19.1 135.6 2.2 158.9 22.8 13.4 164.6 2.3 151.9 21.8 13.6 162.6 1.7 153.3 20.0 16.1 134.8 1.6 144.6 22.9 15.8 154.0
	1.6 133.3 22.9 18.2 120.7 2.8 153.6 19.4 13.3 151.9 2.7 158.6 21.0 14.9 133.6 1.3 108.4 21.1 16.7 142.8 2.1 157.4 20.1 15.7 168.2
	2.5 141.7 19.8 13.5 120.5 1.5 151.1 21.8 18.8 135.6 2.4 149.5 20.5 14.9 119.5 2.3 144.3 21.0 17.2 119.0 1.9 166.6 21.4 17.4 150.8
	1.5 153.6 20.8 16.4 144.0 2.4 144.1 20.3 13.3 124.7 2.3 148.7 19.1 15.4 154.4 1.7 159.9 19.6 17.4 136.7 2.0 162.8 21.3 16.2 152.4
	1.9 145.7 20.0 18.6 133.6 2.3 156.7 19.2 16.4 113.2 2.1 162.3 22.1 19.0 81.6 2.2 164.7 19.1 17.1 134.8 1.8 134.4 20.9 15.6 130.4
	2.1 160.1 21.1 14.2 162.1 2.2 143.0 20.5 17.1 144.7 1.3 141.6 21.7 14.5 163.1 2.5 152.0 20.8 17.3 137.1 2.2 187.1 21.5 14.6 156.0
	1.4 122.9 22.6 18.6 127.2 2.2 157.1 23.4 14.2 121.4 2.5 155.1 20.8 16.0 155.3 1.8 133.6 22.5 15.4 140.4
	;
RUN;

/* Use the REG procedure to obtain the LSE for a couple of different models */ 
/* Model 1: Use X1, X2, X3, X4 */ 
/* Thus, model 1 is: Y = B0 + B1*X1 + B2*X2 + B3*X3 + B4*X4 */ 
/* Model 2: Use just X1 and X2 */ 
/* Thus, model 2 is: Y = B0 + B1*X1 + B2*X2 */ 
PROC REG DATA = work.Oxygen ALPHA = 0.10;
	MODEL Y = X1 X2 X3 X4 / CLB;
	MODEL Y = X1 X2;  
RUN;
/* (a) Identify the multiple regression prediction equation. */

/* The least squares estimates are, approximately: */
/* B0 = 5.59; B1 = 0.01;, B2 = -0.08;, B3 = -0.16;, B4 = -0.01*/

/* (b) Locate SSR. */

/* To find SSR, we look at the "Sum of Squares" column in the ANOVA table; the first row */
/* Thus, SSR is 6.10624 */ 

/* (c) Locate the F-statistic. */

/* The F-statistic is located on the ANOVA table. Here, it's 17.02 */

/* (d) Is there substantial evidence that the four independent variables X1, X2, X3, X4 as a group
	   have at least some predictive power? That is, does the evidence support the contention
	   that at least one of the parameter estimates is not zero? */ 

/* Intuitively, just from looking at the results we have, B0 looks pretty big */
/* Our p-value is 0.001 -> reject nulll hypothesis */
/* Therefore, yes, the evidence suggests that at least one of the parameters are non-zero. */ 

/* (e) Locate the estimated partial slope for X1 and its standard error in the output. Calculate
	   a 90% CI for B1. */

/* The estimated partial slope is the estimate of B1, which we found earlier (approx. 0.01)
/* Its standard error in the output is: 0.00283 */ 
/* (0.00817, 0.01765) */ 

/* (f) Test H0 : B1 = 0 versus HA : B1 =/= 0 at the alpha = 0.1 level. */

/* Our test statistic is our estimate of B1, divded by the standard error of the estimate */
/* So we have t = 0.01291 / 0.00283 = 4.57, which we can see on our table */ 
/* The p-value is extremely small (less than 0.001), so we reject the null hypothesis */ 

/* (g) Is the conclusion of the test compatible with the confidence interval? */ 

/* Yes, our confidence interval did NOT include the value 0, so we do NOT expect B1 to equal 0 */

/* (h) Calculate the coefficient of multiple determination R2 and adjusted R2 */ 

/* Recall for SLR, R2 was just the square of the correlation coefficient. For MLR, no longer true */
/* Interpretation: the proportion of variation in the response that is explained through the */
/* regression on all the predictors in the model */
/* Note: adding predictors ALWAYS increases R2, even though adding predictors isn't ALWAYS better. */
/* So, we want to use adjusted R2 instead. */ 

/* R2 = SSR/SST = 6.10624 / 10.5 = 0.5815 */
/* Adjusted R2 = 1 - (1-R2)*(n-1)/(n-p) = 1 - (1-0.5815) * (54-1) / (54-5) = 0.5474

/* (i) Write the null hypothesis for testing that the omitted variables have no (incremental)
	   predictive value. */

/* H0: B3 = B4 = 0

/* (j) Write the complete and reduced models. */ 

/* Complete: Y = B0 + B1*X1 + B2*X2 + B3*X3 + B4*X4 */ 
/* Reduced: Y = B0 + B1*X1 + B2*X2 */ 

/* (k) Perform an F-test for this null hypothesis. */ 

/* Test statistic = ((SSR_f - SSR_r) / (k - g)) / (MSE_f) = (6.10624 - 2.50013) / (4-2) / 0.08967 = 20.1076
/* Compare to F statistic with df = 4-2 and 54-5 = 2 and 4, for whichever value of alpha you want to use */
/* If we look at the table on cuLearn we see that our test statistic is bigger than all of them */
/* Thus, we reject the null hypothesis; we conclude that B3 and B4 are not both equal to 0. */  
/* Intuitively, this makes sense (look at the confidence intervals we had earlier - they don't include 0)
