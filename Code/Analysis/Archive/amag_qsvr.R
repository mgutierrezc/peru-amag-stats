
library(readstata13)
library(dplyr)
library(stringr)
library(tidyr)
library(data.table)
library(ltm)
library(ggplot2)
library(visdat)
library(devtools)
library(factoextra)
library(coefplot)
library(lmtest)
library(sandwich)
library(stargazer)
library(lfe)
library(stringr)
library(tibble)
setwd("/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME")

df <- read.dta13("Clean_Full_Data.dta")

## Baseline: From survey 1-9 about self and 10-15 about others
## Endline : From Manuel descriptions 1-2 self, 3-8 others, 9-14 the course

# Consistency and  issing values:
  # Work with smaller dataset only with id and qsvr
#dq <- df[, c("DNI",names(df)[str_detect(names(df),"_survey_qvsr1playerqvsr")])]
dq <- df
dq <- as_tibble(dq)

# col_order <- c("DNI",paste0("bs_survey_qvsr1playerqvsr_", 1:15), paste0("en_survey_qvsr1playerqvsr_", 1:14) )
# dq <- dq[, col_order]
# Get rid of all NA in either or both bs and en

# Number of NAs by Baseline or endline
  dq$bsna <- rowSums(is.na(dq[, names(dq)[str_detect(names(dq),"bs_survey_qvsr1playerqvsr")]]))
  dq$enna <- rowSums(is.na(dq[, names(dq)[str_detect(names(dq),"en_survey_qvsr1playerqvsr")]]))

  table(dq$bsna, dq$enna) # Several people with all NA (6223 OF 7064)

# Responses with all zeros
    # Number of zeros
dq$bszero <- rowSums((dq[, names(dq)[str_detect(names(dq),"bs_survey_qvsr1playerqvsr")]] == 0))
dq$enzero <- rowSums((dq[, names(dq)[str_detect(names(dq),"en_survey_qvsr1playerqvsr")]] == 0))
    # Binary variable if sum is of all zeros
dq$bszeroall <- ifelse(dq$bszero == 15 & !is.na(dq$bszero),  1, 0)
dq$enzeroall <- ifelse(dq$enzero == 14 & !is.na(dq$enzero),  1, 0)

  table(dq$bszeroall, dq$enzeroall) # Not so many with all zeros (1), but some all bs or en

table(dq$bszeroall, dq$enzeroall)
table(dq$bszeroall, dq$enna)
table(dq$bsna, dq$enzeroall)

# Want to mark those that: are
  # allbsNA AND allenNA
  # allbsNA AND allenZero
  # allbsZero AND allenNA   
  # allbsZero AND allenZero

# Different categories to cut off from from all NA and all Zero
  # 1: only bs; 2:only en; 3: booth bs and en all NA; 0: neither
  # All NAs, BS NAs(15) or EN NAs (14) -> should not be turn into zero
dq$allNA <- 0
dq$allNA <- ifelse(dq$bsna == 15 & dq$enna !=  14 , 1, dq$allNA )
dq$allNA <- ifelse(dq$bsna != 15 & dq$enna ==  14 , 2, dq$allNA )
dq$allNA <- ifelse(dq$bsna == 15 & dq$enna ==  14 , 3, dq$allNA )

dq$allZero <- 0
dq$allZero <- ifelse(dq$bszeroall !=  1 & dq$enzeroall != 1,
                     0, dq$allZero)
dq$allZero <- ifelse(dq$bszeroall ==  1 & dq$enzeroall != 1,
                     1, dq$allZero)
dq$allZero <- ifelse(dq$bszeroall !=  1 & dq$enzeroall == 1,
                     2, dq$allZero)
dq$allZero <- ifelse(dq$bszeroall ==  1 & dq$enzeroall == 1,
                     3, dq$allZero)


dQ <-dq[dq$allZero != 3 & dq$allNA !=3,] 
colMeans(dQ[,c(7:20, 62:76) ], na.rm = T)
df <- dQ



# Turn to zeros
#df[, names(df)[str_detect(names(df),"_survey_qvsr1playerqvsr")]][is.na(df[, names(df)[str_detect(names(df),"_survey_qvsr1playerqvsr")]])] <- 0
# Subset Basline and Endline by type of question
  # Baseline
  df.qvbs.self <- df[, names(df)[str_detect(names(df),
                                            "bs_survey_qvsr1playerqvsr_[0-9]$")]]
  df.qvbs.other <- df[, names(df)[str_detect(names(df),
                                             "bs_survey_qvsr1playerqvsr_1[0-5]$")]]
  df.qvbs <- df[, names(df)[str_detect(names(df),"bs_survey_qvsr1playerqvsr")]]
  # Endline
  df.qven.self <- df[, names(df)[str_detect(names(df),
                                            "en_survey_qvsr1playerqvsr_[1-2]$")]]
  df.qven.other <- df[, names(df)[str_detect(names(df),
                                             "en_survey_qvsr1playerqvsr_[3-8]$")]]
  df.qven.course <- df[,  names(df)[str_detect(names(df),
                                               "en_survey_qvsr1playerqvsr_9|en_survey_qvsr1playerqvsr_1[0-5]")]]
  df.qven <- df[, names(df)[str_detect(names(df),"en_survey_qvsr1playerqvsr")]]

  # vis_miss(df.qv) + theme(axis.text.x = element_text(face="bold",size=7, angle=90))
  # table(complete.cases(df.qv))
  # table(complete.cases(df.qven), complete.cases(df.qvbs))


# Cronbach test to check internal consistency. By baseline/endline and whole, 
# and by Swelg (1-9) and About others (9-14/15)
  cronbach.alpha(df.qvbs.self[complete.cases(df.qvbs.self),], CI = TRUE)
  cronbach.alpha(df.qvbs.other[complete.cases(df.qvbs.other),], CI = TRUE)
  cronbach.alpha(df.qvbs[complete.cases(df.qvbs),], CI = TRUE)
  
  cronbach.alpha(df.qven.self[complete.cases(df.qven.self),], CI = TRUE)
  cronbach.alpha(df.qven.other[complete.cases(df.qven.other),], CI = TRUE)
  cronbach.alpha(df.qven.course[complete.cases(df.qven.course),], CI = TRUE)
  cronbach.alpha(df.qven[complete.cases(df.qven),], CI = TRUE)

## Histograms
qv <- df[,str_detect(names(df), "_survey_qvsr1playerqvsr") | 
             str_detect(names(df), "DNI")]

par(mfrow = c(3,5), oma = c(1,1,1,1)*2)
for(i in 2:15){
  hist(pull(qv,i), main = "", col = "turquoise3", xlab = "", ylab = "",xlim = c(-3,3))
  title(main = paste("QSVR", str_extract(names(qv)[i], '\\d+$')), cex.main = 0.8)
  t<-table(pull(qv,i))
  print(t)
}

## Change in answers only available in a subset of questions, not sure about comparability at all
    df$delta1 <- df$en_survey_qvsr1playerqvsr_1 - df$bs_survey_qvsr1playerqvsr_2
    df$delta2 <- df$en_survey_qvsr1playerqvsr_2 - df$bs_survey_qvsr1playerqvsr_4
    df$delta3 <- df$en_survey_qvsr1playerqvsr_3 - df$bs_survey_qvsr1playerqvsr_10
    df$delta4 <- df$en_survey_qvsr1playerqvsr_4 - df$bs_survey_qvsr1playerqvsr_11
    df$delta5 <- df$en_survey_qvsr1playerqvsr_5 - df$bs_survey_qvsr1playerqvsr_12
    df$delta6 <- df$en_survey_qvsr1playerqvsr_6 - df$bs_survey_qvsr1playerqvsr_13
    df$delta7 <- df$en_survey_qvsr1playerqvsr_7 - df$bs_survey_qvsr1playerqvsr_14
    df$delta8 <- df$en_survey_qvsr1playerqvsr_8 - df$bs_survey_qvsr1playerqvsr_15
    
index <-   which(str_detect(names(df), "delta") %in% TRUE)

png("barchange_clean.png", width = 500, height = 500)
par(mfrow = c(1,1))
barplot(colMeans(df[,index], na.rm=T), las = 2, cex.axis = 0.9, cex.names = 0.5,
        col = c(rep("tomato",9), rep("orchid4",5)),
        )
title(main = "Average change in survey questions from baseline to endline", 
      cex.main = 1.1)
dev.off()



iqsvr <-   which(str_detect(names(df), "delta") %in% TRUE)
coefdf <- as.data.frame(cbind(rep(NA,length(iqsvr)),rep(NA,length(iqsvr))))
lmm <- list()


for(i in  iqsvr){
fmla <- as.formula(paste0(names(df[i])," ~socratic_treated + Age_rounded + as.factor(Curso) + as.factor(Cargo) + as.factor(Género)"  ))
#fmla <- as.formula(paste0(names(df[i])," ~socratic_treated " ))

print(names(df[i]))
lmm[[i-min(iqsvr)+1]] <- lm(fmla, data = df)
s <- summary(lmm[[i-min(iqsvr)+1]] )
#a <- coeftest(lmm[[i-165]] , vcov =  vcovCL, cluster = ~Curso)
coefdf[i-min(iqsvr)+1, 1] <-  lmm[[i-min(iqsvr)+1]]$coefficients[2]
coefdf[i-min(iqsvr)+1, 2] <-  s$coefficients[2,2]
}

names(coefdf) <- c("coef", "se")
coefdf$lci <- coefdf$coef - qnorm(0.95)* coefdf$se
coefdf$uci <- coefdf$coef + qnorm(0.95)* coefdf$se
coefdf$lci95 <- coefdf$coef - qnorm(0.975)* coefdf$se
coefdf$uci95 <- coefdf$coef + qnorm(0.975)* coefdf$se
coefdf$col <- ifelse(coefdf$uci >0 & coefdf$lci<0, "gray60", "indianred")


png("coeffplotchange_clean.png", width = 600, height = 600)
  plot(x = 1:length(iqsvr), y = coefdf$coef, ylim = range(coefdf$uci95, coefdf$lci95),
       col = coefdf$col, pch = 19, cex = 1.5,
       axes =FALSE,
       xlab = "",
       ylab = "estimated coefficient of treatment ITT")
  segments(x0 = c(1:14), y0 = coefdf$lci95, y1 = coefdf$uci95,
           col = "gray60", lwd=2 )
  segments(x0 = c(1:14), y0 = coefdf$lci, y1 = coefdf$uci, lwd = 3,
           col = coefdf$col )
  abline(h = 0, lty = 2, col = "gray70")
  axis(1, at = 1:14, labels = paste("change", 1:14), las = 2, cex.axis = 0.8)
  axis(2,  las = 2, cex.axis = 0.8)
  title(sub ="estimated regression coefficients, 90 and 95 percent CI", cex.sub = 0.8)
  title(main ="Estimated treatment effect(ITT)
        Change in QVSR questions", cex.sub = 0.8)
dev.off()



stargazer(lmm[[1]], lmm[[2]], lmm[[3]], lmm[[4]], 
          type = "latex")
stargazer(lmm[[5]],lmm[[6]], lmm[[7]], lmm[[8]], 
          type = "latex")



# 
# # Avergae DV
# dff$m.qsvA <- (dff$en_survey_qvsr1playerqvsr_1 + dff$en_survey_qvsr1playerqvsr_2 +
#   dff$en_survey_qvsr1playerqvsr_3 + dff$en_survey_qvsr1playerqvsr_4 + dff$en_survey_qvsr1playerqvsr_5 +
#   dff$en_survey_qvsr1playerqvsr_6 + dff$en_survey_qvsr1playerqvsr_7 + dff$en_survey_qvsr1playerqvsr_8 +
#   dff$en_survey_qvsr1playerqvsr_9)/9
# 
# dff$m.qsvB <- (dff$en_survey_qvsr1playerqvsr_10 + dff$en_survey_qvsr1playerqvsr_11 + dff$en_survey_qvsr1playerqvsr_12 +
#                  dff$en_survey_qvsr1playerqvsr_13 + dff$en_survey_qvsr1playerqvsr_14)/5
# 
# 
# coefdf.2 <- as.data.frame(cbind(rep(NA,2),rep(NA,2)))
# lmm.2 <- list()
# for(i in 180:181){
#   fmla <- as.formula(paste0(names(dff[i])," ~socratic_treated + Age_rounded + as.factor(course) + as.factor(Cargo) + as.factor(Género)|0|0|Curso "  ))
#   print(names(dff[i]))
#   lmm.2[[i-179]] <- felm(fmla, data = dff)
#   s <- summary(lmm.2[[i-179]] )
#   #a <- coeftest(lmm[[i-165]] , vcov =  vcovCL, cluster = ~Curso)
#   coefdf.2[i-179, 1] <-  lmm.2[[i-179]] $coefficients[2]
#   coefdf.2[i-179, 2] <-  s$coefficients[2,2]
# }
# 
# names(coefdf.2) <- c("coef", "cse")
# coefdf.2$lci <- coefdf.2$coef - qnorm(0.95)* coefdf.2$cse
# coefdf.2$uci <- coefdf.2$coef + qnorm(0.95)* coefdf.2$cse
# coefdf.2$lci95 <- coefdf.2$coef - qnorm(0.975)* coefdf.2$cse
# coefdf.2$uci95 <- coefdf.2$coef + qnorm(0.975)* coefdf.2$cse
# coefdf.2$col <- ifelse(coefdf.2$uci >0 & coefdf.2$lci<0, "gray60", "indianred")
# 
# 
# stargazer(lmm.2[[1]], lmm.2[[2]], 
#           type = "text", keep = "socratic_treated")
# 
# stargazer(lmm.2[[1]], lmm.2[[2]], 
#           type = "latex")
# 
# 

### ToT


df$saw_video <- NA
df$saw_video <- ifelse(df$bs_participant_index_in_pages >16 & 
                         is.na(df$bs_participant_index_in_pages) == F , 1, df$saw_video)
df$saw_video <- ifelse(df$bs_participant_index_in_pages >0 & df$bs_participant_index_in_pages <= 16 , 0 , df$saw_video)

df$socratic_actual <- NA
df$socratic_actual <- ifelse(df$saw_video == 0 , 0 , df$socratic_actual)
df$socratic_actual <- ifelse(df$saw_video == 1 & df$socratic_treated ==  1, 1, df$socratic_actual)

table(df$socratic_actual, df$socratic_treated)
table(df$socratic_treated)
table(df$socratic_actual)

        
        
          iqsvr <-   which(str_detect(names(df), "delta") %in% TRUE)
          coefdf <- as.data.frame(cbind(rep(NA,length(iqsvr)),rep(NA,length(iqsvr))))
          lmm <- list()
          
          
        for(i in  iqsvr){
          fmla <- as.formula(paste0(names(df[i])," ~socratic_actual + Age_rounded + as.factor(Curso) + as.factor(Cargo) + as.factor(Género)"  ))
          #fmla <- as.formula(paste0(names(df[i])," ~socratic_treated " ))
          
          print(names(df[i]))
          lmm[[i-min(iqsvr)+1]] <- lm(fmla, data = df)
          s <- summary(lmm[[i-min(iqsvr)+1]] )
          #a <- coeftest(lmm[[i-165]] , vcov =  vcovCL, cluster = ~Curso)
          coefdf[i-min(iqsvr)+1, 1] <-  lmm[[i-min(iqsvr)+1]]$coefficients[2]
          coefdf[i-min(iqsvr)+1, 2] <-  s$coefficients[2,2]
        }
        
        names(coefdf) <- c("coef", "se")
        coefdf$lci <- coefdf$coef - qnorm(0.95)* coefdf$se
        coefdf$uci <- coefdf$coef + qnorm(0.95)* coefdf$se
        coefdf$lci95 <- coefdf$coef - qnorm(0.975)* coefdf$se
        coefdf$uci95 <- coefdf$coef + qnorm(0.975)* coefdf$se
        coefdf$col <- ifelse(coefdf$uci >0 & coefdf$lci<0, "gray60", "indianred")
        
        
        png("coeffplotchangetot.png", width = 600, height = 600)
        plot(x = 1:length(iqsvr), y = coefdf$coef, ylim = range(coefdf$uci95, coefdf$lci95),
             col = coefdf$col, pch = 19, cex = 1.5,
             axes =FALSE,
             xlab = "",
             ylab = "estimated coefficient of treatment ToT")
        segments(x0 = c(1:14), y0 = coefdf$lci95, y1 = coefdf$uci95,
                 col = "gray60", lwd=2 )
        segments(x0 = c(1:14), y0 = coefdf$lci, y1 = coefdf$uci, lwd = 3,
                 col = coefdf$col )
        abline(h = 0, lty = 2, col = "gray70")
        axis(1, at = 1:14, labels = paste("change", 1:14), las = 2, cex.axis = 0.8)
        axis(2,  las = 2, cex.axis = 0.8)
        title(sub ="estimated regression coefficients, 90 and 95 percent CI", cex.sub = 0.8)
        title(main ="Estimated treatment effect(ToT)
              Change in QVSR questions", cex.sub = 0.8)
        dev.off()




stargazer(lmm[[1]], lmm[[2]], lmm[[3]], lmm[[4]], 
          type = "latex")
stargazer(lmm[[5]],lmm[[6]], lmm[[7]], lmm[[8]], 
          type = "latex")

m0 <- colMeans(df[df$socratic_actual == 0,iqsvr ], na.rm = T)
m1 <- colMeans(df[df$socratic_actual == 1,iqsvr ], na.rm = T)

cbind(m0,m1, m1-m0)

### TOT ON EN RAW
iqsvr  <-   which(str_detect(names(df), "bs_survey_qvsr1playerqvsr") %in% TRUE)
coefdf <- as.data.frame(cbind(rep(NA,length(iqsvr)),rep(NA,length(iqsvr))))
lmm <- list()

# DD <- df
# table(df$allNA)
# df <- df[df$allNA==0, ]
# df <- DD
for(i in  iqsvr){
  fmla <- as.formula(paste0(names(df[i])," ~socratic_actual + Age_rounded + as.factor(Curso) + as.factor(Cargo) + as.factor(Género)"  ))
  #fmla <- as.formula(paste0(names(df[i])," ~socratic_treated " ))
  
  print(names(df[i]))
  lmm[[i-min(iqsvr)+1]] <- lm(fmla, data = df)
  s <- summary(lmm[[i-min(iqsvr)+1]] )
  #a <- coeftest(lmm[[i-165]] , vcov =  vcovCL, cluster = ~Curso)
  coefdf[i-min(iqsvr)+1, 1] <-  lmm[[i-min(iqsvr)+1]]$coefficients[2]
  coefdf[i-min(iqsvr)+1, 2] <-  s$coefficients[2,2]
}

names(coefdf) <- c("coef", "se")
coefdf$lci <- coefdf$coef - qnorm(0.95)* coefdf$se
coefdf$uci <- coefdf$coef + qnorm(0.95)* coefdf$se
coefdf$lci95 <- coefdf$coef - qnorm(0.975)* coefdf$se
coefdf$uci95 <- coefdf$coef + qnorm(0.975)* coefdf$se
coefdf$col <- ifelse(coefdf$uci >0 & coefdf$lci<0, "gray60", "indianred")

par(mfrow=c(1,1))
png("coeffplot_enqvsrtot.png", width = 600, height = 600)
plot(x = 1:length(iqsvr), y = coefdf$coef, ylim = range(coefdf$uci95, coefdf$lci95),
     col = coefdf$col, pch = 19, cex = 1.5,
     axes =FALSE,
     xlab = "",
     ylab = "estimated coefficient of treatment ITT")
segments(x0 = c(1:length(iqsvr)), y0 = coefdf$lci95, y1 = coefdf$uci95,
         col = "gray60", lwd=2 )
segments(x0 = c(1:length(iqsvr)), y0 = coefdf$lci, y1 = coefdf$uci, lwd = 3,
         col = coefdf$col )
abline(h = 0, lty = 2, col = "gray70")
axis(1, at = 1:15, labels = paste("Q", 1:15), las = 2, cex.axis = 0.8)
axis(2,  las = 2, cex.axis = 0.8)
title(sub ="estimated regression coefficients, 90 and 95 percent CI", cex.sub = 0.8)
title(main ="Estimated treatment effect(ToT)
QVSR questions (baseline, levels)", cex.sub = 0.8)
dev.off()


