/* ------------------------------------------------------------------
   Cranfield logistic regression
   MATH 6364 Statistical Methods, Fall 2023
   Analysis of the Cranfield data: profitability of 429 UK private-
   sector firms as a function of firm size, sector, formal
   evaluation, and an incentives index.

   Run this script from the repository root so the relative data
   path below resolves to data/Cranfield.csv.
   Requires SAS with PROC LOGISTIC, PROC SQL, PROC SGPLOT and
   PROC UNIVARIATE.
   ------------------------------------------------------------------ */

/* Import the Cranfield data */
PROC IMPORT DATAFILE='data/Cranfield.csv' OUT=work.Cranfield DBMS=CSV REPLACE;
    GETNAMES=YES;
RUN;

/* Calculating Success Proportions */
proc sql;
    create table success_proportions as
    select Incent, mean(Profit) as Success_Proportion
    from work.Cranfield
    group by Incent;
quit;

/* Step 2: Plotting the Data */
proc sgplot data=success_proportions;
    scatter x=Incent y=Success_Proportion;
    xaxis label="Incentive Index";
    yaxis label="Success Proportion";
    title "Success Proportions vs. Incentive Index";
run;

/* Calculating Success Proportions for Size */
proc sql;
    create table success_size as
    select Size, mean(Profit) as Success_Proportion
    from work.Cranfield
    group by Size;
quit;

/* Plotting Success Proportions vs. Size */
proc sgplot data=success_size;
    scatter x=Size y=Success_Proportion / markerattrs=(symbol=circlefilled);
    xaxis label="Size of Firm";
    yaxis label="Success Proportion";
    title "Success Proportions vs. Size of Firm";
run;

/* Calculating Success Proportions for Sector */
proc sql;
    create table success_sector as
    select Sector, mean(Profit) as Success_Proportion
    from work.Cranfield
    group by Sector;
quit;

/* Plotting Success Proportions vs. Sector */
proc sgplot data=success_sector;
    scatter x=Sector y=Success_Proportion / markerattrs=(symbol=circlefilled);
    xaxis label="Sector";
    yaxis label="Success Proportion";
    title "Success Proportions vs. Sector";
run;

/* Calculating Success Proportions for Evaluation */
proc sql;
    create table success_eval as
    select Eval, mean(Profit) as Success_Proportion
    from work.Cranfield
    group by Eval;
quit;

/* Plotting Success Proportions vs. Evaluation */
proc sgplot data=success_eval;
    scatter x=Eval y=Success_Proportion / markerattrs=(symbol=circlefilled);
    xaxis label="Evaluation Indicator";
    yaxis label="Success Proportion";
    title "Success Proportions vs. Evaluation Indicator";
run;

/*logistic with all variables*/
proc logistic data=work.Cranfield;
    class Size(ref='1') Sector(ref='1') Eval(ref='0') / param=ref;
    model Profit(event='1') = Size Sector Eval Incent;
run;

/*logistic with omiting some variables*/
proc logistic data=work.Cranfield;
    class Sector(ref='1') Eval(ref='0') / param=ref;
    model Profit(event='1') = Sector Eval Incent;
run;

/*deviance*/
proc logistic data=work.Cranfield outmodel=model_info;
    class Sector(ref='1') Eval(ref='0') / param=ref;
    model Profit(event='1') = Sector Eval Incent;
    output out=work.logistic_out p=predicted resdev=deviance;
run;

proc univariate data=work.logistic_out;
    histogram deviance;
run;

/*ROC*/
proc logistic data=work.Cranfield plots(only)=roc;
    class Sector(ref='1') Eval(ref='0') / param=ref;
    model Profit(event='1') = Sector Eval Incent;
run;

/*log Likelihood function */

/* Fit Full Model */
proc logistic data=work.Cranfield outmodel=model_info;
    class Sector(ref='1') Eval(ref='0') / param=ref;
    model Profit(event='1') = Sector Eval Incent;
    ods output FitStatistics=FitStats;
run;

/* Fit Null Model */
proc logistic data=work.Cranfield;
    model Profit(event='1') = ;
    ods output FitStatistics=NullFitStats;
run;

proc print data=FitStats;
run;

proc print data=NullFitStats;
run;

/* NOTE: the code printout this script was transcribed from ends here.
   The final PROC SQL step comparing the full and null model
   -2 log-likelihoods is truncated in the source printout, so it is
   reproduced below only as far as the printout shows. */
proc sql;
    select a.Criterion as LogLikelihoodCriterion,
           a.InterceptAndCovariates as FullModelLL,
           b.InterceptOnly as NullModelLL
    from FitStats a, NullFitStats b
