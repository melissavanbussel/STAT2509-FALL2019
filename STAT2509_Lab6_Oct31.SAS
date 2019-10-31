/***************************************************************************************/
/********************************** Course:   Stat 2509       **************************/
/********************************** Project:  Lecture-2(MLR)  **************************/ 
/********************************** Author:   Dr. Fares Said  **************************/ 
/********************************** Date:     Oct 2019        **************************/ 
/***************************************************************************************/

/* NOTE: PLEASE USE THIS LINK TO SUBMIT ANONYMOUS MID-SEMESTER FEEDBACK: */
/* https://forms.gle/eUGHYwcNk8iwDP7fA */
/* This feedback will be very helpful for me to improve the labs. Thank you in advance :) */

FOOTNOTE1 "Course: Stat 2509; Lecture-2 (MLR)";
FOOTNOTE2 "Student Name: Your Name; Student ID: 1245639987";

/***************************************************************************************/
/************************ Example 7.1 (Dummy Variables): in Lecture-2 ******************/ 
/***************************************************************************************/

/* The LENGTH option in the ATTRIB statement allows us to specify how "long" the variable is. */ 
/* The dollar sign means it's a "character" variable (as opposed to numeric, or a date, for example) */ 
/* So, LENGTH = $1. " means a 1-letter character variable. For us, it will be F or M */ 
Data Dummy;
	ATTRIB Y LABEL = "Weight"; 
	ATTRIB S LABEL = "Sex" LENGTH = $1.; 
	ATTRIB X1 LABEL = "Male";  
	ATTRIB A LABEL = "Age Group";
	ATTRIB X2 LABEL = "Age = 1"; 
	ATTRIB X3 LABEL = "Age = 2";
	ATTRIB X4 LABEL = "Height"; 
	ATTRIB X1X4 LABEL = "Male*Height";
	ATTRIB X2X4 LABEL = "Age = 1*Height"; 
	ATTRIB X3X4 LABEL = "Age = 2*Height";
	INPUT S $ A X4 Y@@;
	IF S = "M" THEN X1 = 1; ELSE X1 = 0;
	IF A = 1  THEN X2 = 1; ELSE X2 = 0;
	IF A = 2  THEN X3 = 1; ELSE X3 = 0;
	X1X4 = X1*X4; X2X4 = X2*X4; X3X4 = X3*X4;
	DATALINES;
F 1 56 140 F 1 60 155 F 1 64 143 F 1 68 161 F 1 72 139 
M 1 54 159 M 1 62 138 M 1 65 121 M 1 65 161 M 1 70 145 
F 2 56 117 F 2 60 125 F 2 64 133 F 2 68 141 F 2 72 149 
M 2 54 109 M 2 62 128 M 2 65 131 M 2 65 131 M 2 70 145 
F 3 64 211 F 3 68 223 F 3 72 235 F 3 76 247 F 3 80 259 
M 3 62 201 M 3 69 228 M 3 74 245 M 3 75 241 M 3 82 269
;
RUN;

ODS GRAPHICS OFF;

/* The TEMPLATE procedure allows us to customize the appearance of SAS output. */ 
/* Here, we will change the formatting of the ANOVA table to suit our needs. */ 
/* We use the EDIT statement to edit the format of an existing template in SAS */ 
/* The templates that we want to edit are separated by periods in the EDIT statement. */ 
/* Therefore, here we are trying to edit the templates of "Stat", "Reg", and "Ss" */ 
PROC TEMPLATE; 
   EDIT Stat.Reg.Ss;                                                 
      NOTES "common SS column for proc reg";                                  
      HEADER = ";Sum of;Squares";                                             
      FORMAT = 12.3;                                                         
      PARENT = Common.ANOVA.SS;                                               
   END;                                                                       
RUN; 

/* The (reworded) questions in the lecture notes are: */ 
/* a) Test whether or not the interaction terms are worth including in the model. */
/* b) Test whether or not age group 3 (seniors) is worth including in the model (should we have 3 age categories, or just 2) */ 
/* c) Test whether or not the two planes have equal y-intercept based on sex */ 
/* d) Test whether or not the two planes have the same partial slope based on sex (are the partial slopes parallel?) */ 
/* e) Test whether or not the two planes are the exact same ("coincident") based on sex. */
 
/* ANSWERS */
/* Our full model is going to be: */
/* Y = B0 + B1*X1 + B2*X2 + B3*X3 + B4*X4 + B5*X1*X4 + B6*X2*X4 + B7*X3*X4 */
/* Recall: X1 = Male, X2 = Age group 1, X3 = Age group 2, X4 = height */
/* a) Test H0: B5 = B6 = B7 = 0 */
/* b) Age group 3 occurs when X2 = 0 and X3 = 0. Thus, test H0: B2 = B3 = B6 = B7 = 0 */ 
/* For the last 3 questions, we are interested in comparing models based on sex. */ 
/* For sex = Male, we have 		(1) Y = B0 + B1 + B5*X4 + C */
/* For sex = Female, we have 	(2) Y = B0 + C */ 
/* c) The y-intercept for (1) is B0+B1, the y-intercept for (2) is B0 */
/* Thus, test H0: B0+B1 = B0 => H0: B1 = 0 */ 
/* d) The parallel partial slope for (1) is B5, for (2) it's 0. */
/* Thus, test H0: B5 = 0 */
/* e) The lines are the same if B0 + B1 + B5*X4 = B0 => if B1 = B5 = 0 */
/* Thus, test H0: B1 = B5 = 0 */ 


/* We can answer this question by using TEST statements in the REG procedure */ 
/* This will give us the test statistics + p-values for the hypothesis tests of interest. */ 
ODS EXCLUDE NObs ParameterEstimates FitStatistics ANOVA;
PROC REG DATA = Dummy;
Test: MODEL Y = X1 X2 X3 X4 X1X4 X2X4 X3X4;           	/* Define the full model */ 
_1NoInteract: TEST X1X4 = 0, X2X4 = 0, X3X4 = 0;   		/* Test if there's interactions */
_2Age3Model:  TEST X2 = 0, X3 = 0, X2X4 = 0, X3X4 = 0; 	/* Test if Age = 3 is a useful predictor */
_4MaleModel:  TEST X1 = 0;                       		/* Test if we get the same y-intercept based on sex */ 
_4Partial:    TEST X1X4 = 0;                     		/* Test if we have a parallel partial slope based on sex */
_5Coincident: TEST X1 = 0, X1X4 = 0;                	/* Test if we have the exact same line based on sex */
ODS OUTPUT TestANOVA = ANOVA_Test(DROP=Model Control);
RUN;
OPTIONS NOLABEL;
/* a) p-val < 0.0001 => reject H0, conclude interaction terms are helpful in the model */
/* b) p-val < 0.0001 => reject H0, conclude age group 3 is helpful to the model */ 
/* c) p-val = 0.8964 => do not reject H0, conclude the y-intercepts are different based on sex */ 
/* d) p-val = 0.9446 => do not reject H0, conclude the partial slopes are not parallel based on sex */ 
/* e) p-val = 0.8509 => do not reject H0, conclude the planes are not identical */ 

/* To save the results we're interested in, create a table and call it ANOVATest */ 
PROC SQL;
CREATE TABLE ANOVATest AS 
	SELECT 	T1.Test,
			T1.DF AS df_Num,
			T1.MS AS MS_Num,
       		T2.DF AS df_Den, 
			T2.MS AS MS_Den, 
			T1.FValue,
       		T1.ProbF AS PValue
	FROM ANOVA_Test(WHERE = (Source = "Numerator")) AS T1 
	LEFT JOIN ANOVA_Test(WHERE = (Source = "Denominator")) AS T2
	ON T1.Test = T2.Test
ORDER BY T1.Test
; 
QUIT;


/* We can also do this another way...note that this requires some additional steps, though. */
/* Here, we are using the REG procedure on 6 different models. */ 
/* The parts with the underscores are the names of the models, */ 
/* and the MODEL statements describe which variables will be included in each specific model */
/* For example, model _2NoInteract is given by Y = B0 + B1X1 + B2X4 + B3X1*X4 */ 
/* We then save the ANOVA output from each of the models, and save the 6 ANOVA tables into an object called "ANOVA_Model" */ 
ODS EXCLUDE NObs ParameterEstimates FitStatistics;
PROC REG DATA = Dummy;
	_1FullModel:  MODEL Y = X1 X2 X3 X4 X1X4 X2X4 X3X4; /* Define the full model */
	_2NoInteract: MODEL Y = X1 X2 X3 X4;                /* Model with no interaction terms */ 
	_3Age3Model:  MODEL Y = X1 X4 X1X4;                 /* Test Age = 3 */
	_4MaleModel:  MODEL Y = X2 X3 X4 X1X4 X2X4 X3X4;    /* Same Intercept */
	_5Partial:    MODEL Y = X1 X2 X3 X4 X2X4 X3X4;      /* Same Partial Slope */
	_6Coincident: MODEL Y = X2 X3 X4 X2X4 X3X4;         /* Coincident */
	ODS OUTPUT ANOVA = ANOVA_Model(DROP = Dependent);
RUN;
QUIT;
OPTIONS NOLABEL;

/* Next, we save the results that we care about into a new table, called ANOVAModel */
PROC SQL;
	CREATE TABLE ANOVAModel AS 
		SELECT 
			T1.Model,
			T1.DF AS df_SSR, 
			T1.SS AS SSR,
			T1.MS AS MSR,
       			T2.DF AS df_SSE, 
			T2.SS AS SSE,
			T2.MS AS MSE, 
			T1.FValue,
       			T1.ProbF AS PValue,
			SUM(T1.SS,T2.SS) AS SST
		FROM ANOVA_Model(WHERE = (Source = "Model")) AS T1
		LEFT JOIN 
			ANOVA_Model(WHERE = (Source = "Error")) AS T2
			ON T1.Model = T2.Model
			ORDER BY T1.Model
; 
QUIT;
/* Using the values in the table above, obtain the test statistic values we got in the first solution. */ 
/* As an example: */
/* F = [(SSE_reduced - SSE_full)/(# of removed parameters)]/[MSE_full] */ 
/* F = [(3694.262 - 1494.544)/3]/67.93381 = 10.7934375 */ 
 
