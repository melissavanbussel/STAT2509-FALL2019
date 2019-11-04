/***************************************************************************************/
/********************************** Course:   Stat 2509       **************************/
/********************************** Project:  Lecture-2(MLR)  **************************/ 
/********************************** Author:   Dr. Fares Said  **************************/ 
/********************************** Date:     Nov 2019        **************************/ 
/***************************************************************************************/

FOOTNOTE1 "Course: Stat 2509; Lecture-2 (MLR)";
FOOTNOTE2 "Student Name: Your Name; Student ID: 1245639987";

/***************************************************************************************/
/************************ Example 9.1 (Selection): in Lecture-2 ************************/ 
/***************************************************************************************/

/* The example that we will consider is interested in how the heat evolved in the curing of cement
is affected by the amounts of various chemical included in the cement mixture. The independent
and dependent variables are listed below: */

/* X1 = amount of tricalcium aluminate */ 
/* X2 = amount of tricalcium silicate */ 
/* X3 = amount of tetracalcium alumino ferrite */ 
/* X4 = amount of dicalcium silicate */ 
/* Y = heat evolved in calories per gram of cement */ 

/* We are interested in performing variable / predictor selection. We have 2^4 = 16 different possible models */
/* Note: one of the 16 possibilities is 0 predictors. We won't consider this case in the following; thus we have 15. */ 

/* First, we import the data into SAS */  
DATA Heat;
	ATTRIB Y LABEL = "Calories";
	ATTRIB X1 LABEL = "Aluminate";
	ATTRIB X2 LABEL = "Silicate"; 
	ATTRIB X3 LABEL = "Alumino ferrite";
	ATTRIB X4 LABEL = "Dicalcium silicate";
	INPUT X1 X2 X3 X4 Y@@;
	DATALINES;
	7 26 6 60 79 1 29 15 52 74 11 56 8 20 104 11 31 8 47 88 7 52 6 33 96
	11 55 9 22 109 3 71 17 6 103 1 31 22 44 73 2 54 18 22 93 21 47 4 26 116
	1 40 23 34 84 11 66 9 12 113 10 68 8 12 109
;
RUN;

/* Next, we look at the correlations between each of the predictors. */ 
/* When we "drop" Y, we are saying: do not include the correlation between the response variable and any of the predictors */ 
ODS EXCLUDE SimpleStats VarInformation;
PROC CORR DATA = WORK.Heat (DROP = Y);
RUN;
/* We see that there is a strong negative correlation between X2 and X4 (r = -0.97) */
/* This tells us that we might not need to include both X2 and X4 as predictors; they tell us effectively the same information about the response */ 

/* Next, we use the REG procedure */
/* The SELECTION option allows us to specify which model selection method we want to use. */ 
/* The SubsetSelSummary table provides us with the summary values for the selection methods we chose */ 
ODS EXCLUDE NObs;
PROC REG DATA = WORK.Heat PLOTS = CP;
	MODEL Y = X1 X2 X3 X4 / SELECTION = RSquare SSE AdjRSq MSE CP;
	ODS OUTPUT SubsetSelSummary = Rsq(KEEP = NumInModel RSquare AdjRsq SSE MSE CP);
	ODS OUTPUT SubsetSelSummary = R.R_SS_MS_Cp (Drop = Control);
	ODS SELECT CPPLOT;
RUN;
/* From the Mallow's C_p plot, we see that C_p is approximately equal to p when we use 2 or more predictors (3 parameters) in our model */
/* It "stabilizes" once we use 2 predictors (3 parameters) */ 
/* Note: In the above table and following tables, you see "NumInModel", but it doesn'te tell you WHICH predictors that corresponds to. */
/* To see that information, simply remove the 3 ODS statements in the above chunk of code, and you will be able to see. */ 

/* Combine our results into a new table, called "Combine" */
/* Select all the rows + columns from the table we just created AND add 4 new columns */ 
/* In the 4 new columns, record the max R^2, max R^2_Adj, min SSE, and min MSE for each of the groups */  
PROC SQL;
CREATE TABLE Combine AS 
	SELECT *, 
	MAX(RSquare) AS maxRs, 
	MAX(AdjRsq) AS maxAdj, 
	MIN(SSE) AS minSSE, 
	MIN(MSE) AS minMSE
FROM WORK.Rsq
GROUP BY NumInModel
;

/* Get rid of the extra information; simpplify the table we just made */ 
DATA Combine;
SET Combine;
BY NumInModel;
IF NOT LAST.NumInModel THEN DO;
maxRs = .; maxAdj = .; minSSE = .; minMSE = .;
END;
RUN;

/* Let's visualize the results from the table we just made. */ 
/* We use the SGPLOT procedure to create a plot */ 
/* SCATTER statement will create a "scatterplot" */ 
/* The MARKERATTRS option allows us to change the symbols and the colours of the scatter points */ 
/* The SERIES statement will create a line plot */ 
/* The LINEATTRS option allows us to specify the colour of the lines */  
/* The DATALABEL option will add the actual values of maxRS and maxAdj respectively on the line plots */ 
PROC SGPLOT DATA = Combine; 
   SCATTER X = NumInModel Y = RSquare / MARKERATTRS = (SYMBOL = trianglefilled COLOR = red); 
   SCATTER X = NumInModel Y = AdjRsq / MARKERATTRS = (SYMBOL = circlefilled COLOR = blue); 
   SERIES X = NumInModel Y = maxRs / LINEATTRS = (COLOR = red) DATALABEL;
   SERIES X = NumInModel Y = maxAdj / LINEATTRS = (COLOR = blue) DATALABEL;
   XAXIS LABEL = "Number of Predictors In Model"; 
   YAXIS LABEL = "R-Square"; 
RUN; 
/* From the plot, we see that max R^2 and max R^2_Adj "stabilize" once we use 2 or more predictors */ 
/* There is a little bit of an increase from 2 to 3 predictors, but barely any change from 3 to 4. */ 

/* Similarly, we can see how min SSE and min MSE are "stabilized" */ 
PROC SGPLOT DATA = Combine; 
    SCATTER X = NumInModel Y = SSE / MARKERATTRS = (SYMBOL = trianglefilled COLOR = red); 
    SCATTER X = NumInModel Y = MSE / MARKERATTRS = (SYMBOL = circlefilled COLOR = blue);
    SERIES X = NumInModel  Y = minSSE / LINEATTRS = (COLOR = red) DATALABEL;
    SERIES X = NumInModel Y = minMSE / LINEATTRS = (COLOR = blue) DATALABEL;
    XAXIS LABEL = "Number of Predictors In Model"; 
    YAXIS LABEL = "SS/MS"; 
RUN; 
/* Once again, we see that they "stabilize" when we use 2 or more predictors in our model */ 
/* We see a slight improvement (decrease) between 2 and 3, but barely any change from 3 to 4 */
/* In fact, we see that min MSE actually *increases* (bad) when we go from 3 to 4 predictors. */ 

