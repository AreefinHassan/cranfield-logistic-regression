# Cranfield Logistic Regression — Profitability of UK Firms

A logistic regression analysis of what makes a firm profitable, using the
Cranfield data on 429 UK private-sector firms. The analysis fits a full
model, simplifies it by dropping firm size, and checks the fitted model
with deviance residuals, an ROC curve, and a likelihood-ratio test against
the intercept-only model.

**Course:** MATH 6364 Statistical Methods, Fall 2023, University of Texas
Rio Grande Valley

## Data

`data/Cranfield.csv` — 429 firms, 6 columns:

| Column | Description |
|---|---|
| `Sector` | Sector of the firm: 1 = primary, 2 = secondary, 3 = tertiary |
| `Size` | Firm size: 1 = 200–500 employees, 2 = 501–1,000, 3 = more than 1,000 |
| `Incent` | Incentives index, 0–16 (0 = no incentives offered, 16 = all four types offered to all four employee groups) |
| `Eval` | Formal evaluation procedure: 1 if performance is regularly evaluated, 0 otherwise |
| `Profit` | Response: 1 if gross revenues are "well in excess of costs", 0 otherwise |
| `SectRec` | Sector recoded: primary/secondary combined vs. tertiary |

209 of the 429 firms are profitable. The data come from the 1999 UK survey
of the Cranfield Network on European Human Resource Management (Cranet-E),
a research network studying human resource management in public and private
organizations with more than 200 employees (Brewster & Hegewisch, 1994).

## Analysis

1. **Success proportions** — the proportion of profitable firms is plotted
   against the incentives index, firm size, sector, and the evaluation
   indicator.
2. **Full logistic model** — `Profit` on `Size`, `Sector`, `Eval`, and a
   linear term in `Incent`, fit with `PROC LOGISTIC` (reference coding).
3. **Model simplification** — firm size is dropped and the reduced model
   is re-estimated.
4. **Diagnostics** — deviance residuals (`PROC UNIVARIATE`), ROC curve and
   AUC, and a likelihood-ratio comparison of the fitted model against the
   intercept-only model.

## Results

**Full model** (AIC 548.181, c = 0.707):

| Effect | p-value |
|---|---|
| Size | 0.4554 — not significant once the other variables are in the model |
| Sector | < 0.0001 |
| Eval | 0.0352 |
| Incent | < 0.0001 |

**Simplified model** — `Sector`, `Eval`, `Incent` only (AIC 545.751,
SC 566.058, −2 Log L 535.751; likelihood-ratio χ² = 58.6875, df = 4,
p < 0.0001; c = 0.705, AUC = 0.7048):

| Parameter | Estimate | p-value | Odds ratio |
|---|---|---|---|
| Intercept | 0.6260 | 0.4447 | — |
| Sector 2 vs 1 | −2.0138 | 0.0131 | 0.133 |
| Sector 3 vs 1 | −1.1107 | 0.1738 | 0.329 |
| Eval 1 vs 0 | 0.4583 | 0.0299 | 1.581 |
| Incent (per unit) | 0.1353 | < 0.0001 | 1.145 |

Dropping firm size improves AIC and SC while barely changing
discrimination (c falls from 0.707 to 0.705). Sector and the incentives
index are the strongest predictors of profitability; formal evaluation
also helps (odds ratio 1.58). Each additional incentive point multiplies
the odds of being profitable by about 1.15.

**Diagnostics:** the deviance residuals have mean −0.0098 and standard
deviation 1.119, with location tests giving no evidence against a zero
mean (t-test p = 0.8561), so the fitted model shows no systematic bias.
The likelihood-ratio test against the intercept-only model
(−2 Log L 594.438 vs. 535.751) strongly rejects the null.

## Files

```
cranfield-logistic-regression/
├── README.md
├── code/
│   └── cranfield_logistic_regression.sas   # SAS code for the full analysis
├── data/
│   └── Cranfield.csv                      # 429 firms
└── report/
    └── Cranfield_Logistic_Regression.pdf   # Full written report with SAS output
```

## How to run

Requires SAS with `PROC LOGISTIC`, `PROC SQL`, `PROC SGPLOT`, and
`PROC UNIVARIATE`. Run `code/cranfield_logistic_regression.sas` from the
repository root so the relative path `data/Cranfield.csv` resolves.

One note: the code printout this script was transcribed from truncates the
final `PROC SQL` step that compares the full and null model
−2 log-likelihoods, so that step is reproduced in the script only as far
as the printout shows.
