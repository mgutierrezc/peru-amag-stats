# peru-amag-stats
Codes for statistical analysis of Peru Amag Project. Check `Codes` folder to find the scripts for each task

## Analysis
Scripts for AMAG II RCT regressions. The main .do files can be found on [eval_analysis_Regs.do](`https://github.com/mgutierrezc/peru-amag-stats/blob/main/Code/Analysis/eval_analysis_Regs.do`) and [eval_analysis_Figs.do](`https://github.com/mgutierrezc/peru-amag-stats/blob/main/Code/Analysis/eval_analysis_Figs.do`). They generate the tables and figures used on the Overleaf draft for the [paper](https://www.overleaf.com/project/63681e75c819cefea3df3755).

## Case Outcomes
Creates judicial outcomes from Peruvian judicial data scraped from publicly available websites. There are two versions of the code:

- R pipeline (R scripts within the folder)
- Jupyter notebook (Case Outcomes for Amag II.ipynb)

The R pipeline works simultaneously with all the scraped files from 2017 to 2021. The Jupyter creates the same outcomes but for one year at a time and works with data from 2017 and forwards.

It's recommended to use the Jupyter rather than the R scripts as the size of the data and some of its snippets are not fully optimized, such as the fuzzy merge one.

## IAT Reconstructor

This do file obtains whether a player from the Peru-Amag sessions has seen it's IAT feedback or not. 

Requirements:

- Python 3.x. You can download it [here](https://www.python.org/downloads/)



In order to run it, follow this steps:

- Place the all the pagetimes and behavioral raw data within the repo root folder `path\peru-amag-stats`
- Change the path from the `iat_reconstructor ` do file to the repo root folder `path\peru-amag-stats`
- Run the do file

The output will be stored in the folder `path\peru-amag-stats\output`, which will be created when running the do. This do file outputs one db as `.dta`:

- `players_iat_feedback`, which follows this structure:



| participant_code | DNI  | session_code | seen_iat_feedback | consistency_identifier |
| ---------------- | ---- | ------------ | ----------------- | ---------------------- |
|                  |      |              |                   |                        |



- `participant_code`: oTree participant identifier
- `DNI`: experimenter defined participant identifier
- `session_code`: oTree session identifier
- `seen_iat_feedback`: binary indicator of whether the participant has seen its iat feedback (1 if he has seen it, 0 if not)
- `consistency_identifier`: checks whether the data is consistent (observation in behavioral and pagetimes db) or not



**Important:**

This script will automatically detect all pagetime files within the folder by checking which csv files have the substring "PageTimes" in their name, so it's very important to avoid changing the original names of the files.

Also, avoid adding spaces to the raw data file names as Stata will get confused when reading the file names

