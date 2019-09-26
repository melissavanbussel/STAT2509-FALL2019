/****************************************************************************************/
/********************************** Course:   Stat 2509        **************************/
/********************************** Project:  Lecture-1        **************************/ 
/********************************** Author:   Dr. Fares Said   **************************/ 
/********************************** Date:     Sept 2019        **************************/ 
/****************************************************************************************/

/****************************************************************************************/
/********************************** Example 3.1: in Lecture-1 ***************************/ 
/****************************************************************************************/

FOOTNOTE1 "Course: STAT 2509; Lecture 1 SLR"; 
FOOTNOTE2 "Student Name: Your Name; Student ID: 124563998"; 

/* Data from a sample of 10 pharmacies are used to examine the relation between 
prescription sales volume and the percentage of prescription ingredients purchased 
directly from the supplier. */ 

/* 	Find the LSE for the regression line Y = B0 + B1X. 
	
	Plot the (X, Y) data and the prediction equation.
	
	Find the correlation coefficient. 
	
	Predict sales volume for a pharmacy that purchases 15% of its prescription ingredients
	directly from the supplier. What about 18%? 
*/ 

/* First, we create the dataset in SAS. Note that this gets created to the WORK library
(temporary). */ 
DATA sale; 
	ATTRIB ID LABEL = "Pharmacy"; 
	ATTRIB Y LABEL = "Sale Volume in $1000"; 
	ATTRIB X LABEL = "% of Ingredients Purchased Directly"; 
	INPUT ID Y X; 
	DATALINES; 
	1 25 10
	2 55 18
	3 50 25
	4 75 40
	5 110 50
	6 138 63
	7 90 42
	8 60 30
	9 10 5
	10 100 55
	; 
RUN; 

/* To find the LSE and create the necessary plots, we can use the REG procedure. */ 
/* Note: The following will NOT work in the University Edition of SAS! */ 
PROC REG DATA = work.sale;
	MODEL Y = X;						/*  / LACKFIT; */
	PLOT Y * X = "*"; 					/* Scatterplot for Y vs X */ 
	PLOT RESIDUAL. * PREDICTED. = "*";	/* Scatterplot for error vs. fitted */ 
	PLOT RESIDUAL. * OBS. = "*"; 		/* Scatterplot for error vs observed */
	/* Save the Residuals and Fitted into a new data table called OutReg: */ 
	OUTPUT OUT = OutReg RESIDUAL = Residual PREDICTED = Fitted;
RUN; 

/* 	Interpreting (some of) the output from the above REG procedure: 
 	Significant F statistic => A significant portion of the variation is explained by the model. 
	Model df = One less than the number of parameters =>  2 - 1 = 1
	Corrected total df = One less than the number of observations => 10 - 1 = 9
	LSE of B0: 4.69785; SE of this estimate: 5.95202; high p-val => not significantly different from 0	 
	LSE of B1: 1.97408; SE of this estimate: 0.15455; low p-val => significantly different from 0 

	Interpreting (some of) the generated plots from the above REG procedure: 
	The plot of Y vs. X plots the (X, Y) points along with the regression line Y = B0 + B1X
	Assumption of SLR: All errors have same variance => Residual plots 
*/

/* 	If you're using the University Edition, the following will produce the same 
	plots of interest: 

ODS GRAPHICS ON;
PROC REG DATA = work.sale;
	MODEL Y = X; 
	/* Save the Residuals and Fitted into a new data table called OutReg: 
	OUTPUT OUT = OutReg RESIDUAL = Residual PREDICTED = Fitted;
RUN; 
ODS GRAPHICS OFF;

*/

/* To find the correlation coefficient, we use the CORR procedure: */ 
PROC CORR DATA = work.sale;
	VAR X Y; 
RUN; 
/* Therefore, the correlation coefficient is: 0.97627 */

/* Another way to check the Normality assumption is by using the CHART procedure: */ 
PROC CHART DATA = OutReg; 
	VBAR Residual;
RUN; 
/* We see (very roughly) that the errors are distributed approx. Normally */ 

/* 	Predict values: Find CI and PI 
 	Let's predict the value of Y when X = 15 and when X = 18
 	To do this: create a new data table called To_Predict; fill it with the work.sales table 
	Then, add two new rows: one for X = 15, and one for X = 18. This will give us rows 11 and 12.
*/ 
PROC SQL;
	CREATE TABLE To_Predict AS 
		SELECT *
		FROM Sale;
	INSERT INTO To_Predict
		VALUES (11, ., 15)
		VALUES (12, ., 18);
QUIT;

/* 	Now we find the CI and PI.
  	CLI will compute (1-alpha)*100% PI for an individual predicted value
  	CLM will compute (1-alpha)*100* CI for E[X]
  	Then save the results into the OutReg data table 
*/ 
PROC REG DATA = work.To_Predict ALPHA = 0.01;
	MODEL Y = X / CLI CLM; */LACKFIT;
	OUTPUT OUT = OutReg RESIDUAL = Residual PREDICTED = Fitted LCL = IndLCL UCL = IndUCL LCLM = AveLCL UCLM = AveUCL;
RUN;

/* Note: To view the OutReg table, use the PRINT procedure: */
PROC PRINT DATA = work.OutReg;
RUN; 
