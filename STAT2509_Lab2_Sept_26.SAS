/****************************************************************************************/
/********************************** Course:   Stat 2509        **************************/
/********************************** Project:  Lecture-1        **************************/ 
/********************************** Author:   Dr. Fares Said   **************************/ 
/********************************** Date:     Sept 2019        **************************/ 
/****************************************************************************************/

FOOTNOTE1 "Course: STAT 2509; Lecture 1 SLR"; 
FOOTNOTE2 "Student Name: Your Name; Student ID: 124563998"; 
 
/***************************************************************************************/
/********************************** Example 5.1: in Lecture-1 **************************/ 
/************************* Forest decline because Growth Retardation *******************/
/***************************************************************************************/

/* Forest scientists are concerned with the decline in forest growth throughout the world. One
aspect of this decline is the possible effect of emissions from coal-powered power plants. The
scientists in particular are interested in the pH level of the soil and the resulting impact on tree
growth delay. The forest scientists then want to determine impact on tree growth as the soil
becomes more acidic. An index of growth delay is constructed from the various measurements
taken on the trees with a high value indicating greater delay in tree growth. A higher value of
soil pH indicates a more acidic soil. 20 stands which are exposed to the power plant emissions
are selected for study. */ 

/* Examine the scatterplot, determine whether a straight line is a reasonable model. 
/* Identify the LSE for B0 and B1. 
/* 

/* First, create the dataset in SAS */ 
/* Note: The @@ allows us to enter more than one observation on the same line. */ 
DATA GrowDelay;
	ATTRIB ID LABEL = "Stand";
	ATTRIB X LABEL = "Average Soil pH";
	ATTRIB Y LABEL = "Growth Delay Index";
	INPUT ID X Y @@;
	DATALINES;
	1 3.3 17.78 2 3.4 21.59 3 3.4 23.84 4 3.5 15.13 
	5 3.6 23.45 6 3.6 20.87 7 3.7 17.78 8 3.7 20.09 
	9 3.8 17.78 10 3.8 12.46 11 3.9 14.95 12 4.0 15.87
	13 4.1 17.45 14 4.2 14.35 15 4.3 14.64 16 4.4 17.25
	17 4.5 12.57 18 5.0 7.15 19 5.1 7.50 20 5.2 4.34
	;
RUN;

/* 	By enabling ODS graphics, we do not need to use the PLOT statement in the REG procedure. */ 
ODS GRAPHICS ON; 

/* 	Note: How did we know earlier what the names of all the outputs were? 
	(E.g., How did we know it was called "Residual"? Why not "Resid" or "Res"? See example below)
	ANSWER: We can turn ODS TRACE on, and the names of all the outputs will be displayed 
	in the log.
*/ 
ODS TRACE ON; 

/* Use the REG procedure to find the LSE */ 
/* Note: The OUTEST option allows us to create a data set (called ParemData, here) that contains 
parameter estimates and other model fit summary statistics. */ 
PROC REG DATA = work.GrowDelay OUTEST = ParemData;
	MODEL Y = X / CLB;
	OUTPUT OUT = GrowPred RESIDUAL = Residual PREDICTED = Fitted;
RUN;
/* LSE for B0 is: 47.47543 */
/* LSE for B1 is: -7.85924 */

/* Place the regression equation in a macro variable. */
DATA _NULL_;
   SET PAREMDATA;
   CALL SYMPUT("eqn", "Growth Delay = " ||Intercept|| " + " ||X|| " * Soil pH");
RUN;
/* We can now use a %PUT statement to print out the macro variable. */ 
%PUT The regression equation is &eqn; 

/* Create a plot and save it in a file called ScatterPlot.pdf */ 
/* Note: to change where you save this on your computer, just change the part before ScatterPlot */
/* For example: C:/Users/YourName/Documents/MyFolder/ScatterPlot.pdf */ 
ODS PDF FILE = "P:/ScatterPlot.pdf";
ODS GRAPHICS / RESET WIDTH = 600px HEIGHT = 400px IMAGENAME = "Regression" IMAGEFMT = gif;
PROC SGPLOT DATA = work.GrowDelay;
   REG X = X Y = Y / CLM DATALABEL;
   /* The following INSET statement can be used as */ 
   /* an alternative to the FOOTNOTE statement */
   /* INSET "&eqn" / POSITION = bottomleft;  */
   FOOTNOTE1 j = l "Regression Equation";
   FOOTNOTE2 j = l "&eqn";
RUN;
FOOTNOTE;
ODS PDF CLOSE;

/* Find the correlation coefficient*/
PROC CORR DATA = work.GrowDelay;
	VAR X Y;
RUN;
/* The correlation coefficient is -0.86192*/ 

/* Check the normality assumption */
PROC CHART DATA = GrowPred;
	VBAR Residual;
RUN;
/* We can see (very roughly) that the errors are approximately normally distributed */ 

/* Or */
PROC SGPLOT DATA = GrowPred;
   HISTOGRAM Residual / TRANSPARENCY = 0.7 BINSTART = -10; /*binwidth=10*/
   DENSITY Residual / LINEATTRS = graphdata1; /* LINEATTRS is the width of the line */
   HISTOGRAM Y / FILLATTRS = graphdata2 TRANSPARENCY = 0.5 BINSTART = -10; /*binwidth=10*/
   DENSITY Y / LINEATTRS = graphdata2;
   KEYLEGEND / LOCATION = inside POSITION = topright NOBORDER ACROSS = 2;
   YAXIS GRID;
RUN;
/* We see that the residuals are approximately distributed normally */
/* The Y's are approximately distributed normally as well */ 

/**************************** Predict values Find CI and PI ****************************/
/***************************************************************************************/

/* Predict the growth delay index for soil pH of 4.0 and for a soil pH of 6.5*/

/* First, we create a new table called To_Predict_Delay */ 
/* We fill it with the values in the table GrowDelay */ 
/* Then we create two new rows: one for soil pH = 4.0, one for soil pH = 6.5 */  
PROC SQL;
	CREATE TABLE To_Predict_Delay AS 
		SELECT *
		FROM GrowDelay;
	INSERT INTO To_Predict_Delay
		VALUES (21,4.0,.)
		VALUES (22,6.5,.);
QUIT;

/* Now we compute the predicted values and */ 
/* Save the results in a new table called GrowPred1 */ 
/* CLB will compute (1-alpha)*100% CI for the parameter estimates (B0, and B1) */ 
/* CLI will compute (1-alpha)*100% PI for an individual predicted value, Y-hat */
/* CLM will compute (1-alpha)*100* CI for E[Y] */ 
/* Note: if we don't specify alpha, what value does it take by default? */ 
PROC REG DATA = work.To_Predict_Delay;
	MODEL Y = X / CLB CLI CLM;
	OUTPUT OUT = GrowPred1 RESIDUAL = Residual PREDICTED = Fitted LCL = IndLCL UCL = IndUCL LCLM = AveLCL UCLM = AveUCL;
RUN;

ODS GRAPHICS OFF;

/************************************ Lack of fit test *********************************/
/***************************************************************************************/

/* Create dataset */ 
DATA Heat;
	ATTRIB X LABEL = "Outdoor Temperature";
	ATTRIB Y LABEL = "Heat Loss";
	INPUT X Y @@;
	DATALINES;
	20 86 20 80 20 77
	40 78 40 84 40 75
	60 33 60 38 60 43 
	;
RUN;

/* Use REG procedure, save results in a variable called PAREMDATA */ 
/* NOPRINT option will hide the results from being printed */ 
PROC REG DATA = work.Heat OUTEST = PAREMDATA NOPRINT; 
	MODEL Y = X;
RUN;

/* Create a macro variable to store the regression equation, the variable is called "eqn" */
DATA _NULL_;
   SET PAREMDATA;
   CALL SYMPUT("eqn", "HeatLoss = " ||Intercept|| " + " ||X|| " * Temperature");
RUN;
/* We can use a PUT statement to see the regression equation, printed out to the log */
%PUT The regression equation is &eqn;

/* Plot the points, with the regression line */ 
PROC SGPLOT DATA = work.Heat;
   REG X = X Y = Y / DATALABEL;
   FOOTNOTE1 j = l "Regression Equation";
   FOOTNOTE2 j = l"&eqn";
RUN;
FOOTNOTE;

/* Lack of fit test: use the REG procedure, specify the LACKFIT option */
/* The CLB option computes a (1-alpha)*100% CI for our parameter estimates (B0, B1) */ 
/* Save results in a new table called HeatResidual */ 
PROC REG DATA = work.Heat;
	MODEL Y = X / CLB LACKFIT;
	OUTPUT OUT = HeatResidual RESIDUAL = Residual PREDICTED = Fitted;
RUN;
/* The null hypothesis is that the SLR is appropriate */ 
/* The alternative hypothesis is that the SLR is not appropriate */ 
/* The p-value of 0.0011 is extremely small => SLR not appropriate here */ 

/* Challenge question: what about the forest example? What conclusion would you make about */
/* whether or not the SLR model is appropriate? */ 
