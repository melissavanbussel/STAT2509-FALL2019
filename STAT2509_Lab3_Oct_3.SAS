/***************************************************************************************/
/********************************** Course:   Stat 2509       **************************/
/********************************** Project:  Lecture-2(MLR)  **************************/ 
/********************************** Author:   Dr. Fares Said  **************************/ 
/********************************** Date: 	  Oct 2019        **************************/ 
/***************************************************************************************/

/***************************************************************************************/
/********************************** Example 3.1: in Lecture-2 **************************/ 
/***************************************************************************************/

FOOTNOTE1 "Course: Stat 2509; Lecture-2 (MLR)";
FOOTNOTE2 "Student Name: Your Name; Student ID: 1245639987";

ODS TRACE OUTPUT;

/* The following data gives the yields (in bushels) for 14 equal-sized plots
planted in tomatoes for different levels of fertilization 

Recall from lecture: this example was used to demonstrate that models can be considered
"linear models" even if they are not linear in the response variable; a "linear model" 
means linear in the parameters. */

/* Recall: need to use @@ in order to enter more than one observation per line */ 
DATA Yield;
	ATTRIB ID LABEL = "Plot";
	ATTRIB Y LABEL = "Yield in bushels";
	ATTRIB X LABEL = "Amount of Fertilizer in pounds per plot";
	ATTRIB Xsq LABEL = "Square of X";
	INPUT ID  Y  X @@;
	Xsq = X**2;
	DATALINES;
	1 24 12 2 18 5 3 31 15 4 33 17 5 26 20 6 30 14 7 20 6 
	8 25 23 9 25 11 10 27 13 11 21 8 12 29 18 13 29 22 14 26 25
	;
RUN;

/* Let's visualize the data: */
PROC SGPLOT DATA = work.Yield;
   SCATTER X = X Y = Y / MARKERATTRS = (symbol = circlefilled COLOR = red);
   XAXIS LABEL = "Amount of Fertilizer in pounds per plot";
   YAXIS LABEL = "Yield in bushels";
RUN;

/* Use the REG procedure to find the LSE */
/* We're saying: "Model the Y variable as a function of the X variable and the Xsq variable" */ 
PROC REG DATA = work.Yield;
	MODEL  Y = X Xsq;
RUN;
/* We see that estimate of B0 = 5.70311 */  
/* Estimate of B1 = 2.69234 */ 
/* Estimate of B2 = -0.07671 */ 
/* Therefore, our estimate of Y is  5.70311 + 2.69234*X − 0.07671*X^2 */ 

/***************************************************************************************/
/************************ Example 5.1 (Weight Loss): in Lecture-2 **********************/ 
/***************************************************************************************/

/* An experiment was conducted to investigate the weight loss of a compound for different amounts
of time the compound was exposed to the air. Additional information was also available on the
humidity of the environment during exposure. */ 

/* a) Visualize the data */ 
/* b) Find the correlations between the variables  */ 
/* c) Find the least squares estimates of B0, B1, and B2 */ 
/* d) Using your estimates, predict the weight loss for an exposure time of 6.5, & humidity 0.35 */ 

/* First, we create the data in SAS, and save it in a table called "Weight" */ 
DATA Weight;
	ATTRIB Y LABEL = "Weight Loss";
	ATTRIB X1 LABEL = "Exposure Time(hours)";
	ATTRIB X2 LABEL = "Relative Humidity";
	INPUT Y  X1 X2 @@;
	DATALINES;
	4.3 4 .20 5.5 5 .20 6.8 6 .20 8.0 7 .20 4.0 4 .30 5.2 5 .30
	6.6 6 .30 7.5 7 .30 2.0 4 .40 4.0 5 .40 5.7 6 .40 6.5 7 .40
	;
RUN;

/* To visualize the data, we need to create a scatterplot matrix */
/* We have 3 variables, so we cannot visualize in 2D without doing this! */ 
PROC SGSCATTER DATA = work.Weight;
  TITLE "Scatterplot Matrix for Weight Data";
  MATRIX Y X1 X2 / MARKERATTRS = (SYMBOL = circlefilled COLOR = red) DIAGONAL = (HISTOGRAM KERNEL);
RUN;
TITLE;
/* Along the diagonals, we have histograms of each of the variables */ 
/* Off the diagonals, we have scatterplots of the different combinations of the variables */ 

/* Use the CORR procedure to print the correlation matrix */ 
PROC CORR DATA = work.Weight;
RUN;

/* Use the REG procedure to find the LSE */ 
/* "Model Y as a function of X1 and X2" */ 
/* The CLB option computes (1-alpha)*100% confidence intervals for the parameter estimates */ 
PROC REG DATA = work.Weight;
	MODEL Y = X1 X2 / CLB;
RUN;

/* Create a new table called "To_Predict"; */
/* Put the values from the Weight table in it, then create a new row */ 
/* Fill the new row with the values Y = ".", X1 = "6.5", X2 = "0.35" */
/* We use the period as a placeholder, since we don't actually know what the predicted value is yet */ 
PROC SQL;
	CREATE TABLE To_Predict AS 
	SELECT *
	FROM WORK.Weight
	;
	INSERT INTO To_Predict
	VALUES (.,6.5,0.35)
	;
QUIT;

/* Use the EXCLUDE to hide a few of the outputs so our screen doesn't get spammed with stuff we don't want to see! */ 
ODS EXCLUDE ResidualStatistics ParameterEstimates FitStatistics ANOVA NObs;
/* Use the REG procedure to get the prediction */ 
/* CLI will compute (1-alpha)*100% PI for an individual predicted value, Y-hat */
PROC REG DATA = work.To_Predict ALPHA = 0.01;
	MODEL Y = X1 X2 / CLI;
RUN;
/* We see that the predicted weight loss for an exposure time of 6.5 hours and a relative humidity of 0.35 */ 
/* is 6.4250. A 99% prediction interval for this predicted value is: (5.0596, 7.7904) */ 
