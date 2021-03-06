# peru-amag-stats
Codes for basic stats from Peru Amag Project



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

