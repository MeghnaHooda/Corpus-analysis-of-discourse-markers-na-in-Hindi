library(ggplot2)

# Load dataset

na_data <- read.csv("C:/Users/meghn/OneDrive/Documents/Phd - work/Stats/Term Paper/Corpus-analysis-of-discourse-markers-na-in-Hindi/data/Sentence_Wise_Discourse_markers_na.csv")

# Inspect structure and summary
head(na_data)
summary(na_data)

dp_na_df <- na_data[na_data$na == 'Neg na', ]

summary(dp_na_df)

# Subset: only 'na' occurrences
dp_na_df <- na_data[na_data$na == 'na', ]
dp_na_df
head(dp_na_df)

# Subset: exclude 'Neg na'

na_df <- na_data[na_data$na != 'Neg na', ]

# =====================================================
# Histogram of all sentence lengths with mean & median
# ======================================================

ggplot(na_data, aes(x = Sentence.Length)) +
  geom_histogram()+
  geom_vline(xintercept = mean(na_data$Sentence.Length), color = "red")+
  annotate("text",
           x = mean(dp_na_df$Sentence.Length)+4,
           y = 10000,                     # place at top of plot
           label = paste("Mean =", round(mean(na_data$Sentence.Length), 2)),
           color = "red",
           vjust = -0.5)+
  geom_vline(xintercept = median(na_data$Sentence.Length), color = "blue")+
  annotate("text",
           x = median(dp_na_df$Sentence.Length)+3.9,
           y = 10500,
           label = paste("Median =", round(median(na_df$Sentence.Length), 2)),
           color = "blue",
           vjust = -0.5)

# =============================================
# Overlapping histograms for na vs other types
# ==============================================

ggplot(na_data, aes(x = Sentence.Length, fill=na, color=na)) +
  geom_histogram(alpha = 1, position = "identity")+
  geom_histogram(data = dp_na_df,
                 aes(x = Sentence.Length, fill = na),
                 alpha = 0.8)

# ===============================================
# Histograms only for na with mean & median
# ================================================

ggplot(dp_na_df, aes(x = Sentence.Length)) +
  geom_histogram()+
  geom_vline(xintercept = mean(dp_na_df$Sentence.Length), color = "red")+
  annotate("text",
           x = mean(dp_na_df$Sentence.Length)+5.5,
           y = 250,                     # place at top of plot
           label = paste("Mean =", round(mean(dp_na_df$Sentence.Length), 2)),
           color = "red",
           vjust = -0.5)+
  geom_vline(xintercept = median(dp_na_df$Sentence.Length), color = "blue")+
  annotate("text",
           x = median(dp_na_df$Sentence.Length)+5.5,
           y = 260,
           label = paste("Median =", round(median(dp_na_df$Sentence.Length), 2)),
           color = "blue",
           vjust = -0.5)

# Recreate na_df subset

na_df <- na_data[na_data$na != 'Neg na', ]
summary(na_df)

# =====================
# Logistic Regression
# =====================

# Create binary indicator for na (1 = na, 0 = others)

na_df$Type.of.na <- ifelse(na_df$na == "na", 1, 0)

# Fit logistic regression
model_logistic <- glm(Type.of.na ~ Sentence.Length, 
                      family = binomial, 
                      data = na_df)
summary(model_logistic)

#In probability terms, longer sentences are associated with lower probability
#of occurrence of na.

# Interpretation: longer sentences = lower probability of na

# =========================================
# Check dispersion (under/over-dispersion)
# =========================================
resid_deviance <- deviance(model_logistic)
resid_df <- df.residual(model_logistic)

dispersion_ratio <- resid_deviance / resid_df
dispersion_ratio
#underdispersion

head(na_df)


# ===========================================
# Plot logistic regression
# ===========================================

ggplot(na_df, aes(x = Sentence.Length, y = Type.of.na)) +
  geom_jitter(height = 0.02, alpha = 0.3, color = "steelblue") +
  stat_smooth(method = "glm",
              method.args = list(family = binomial),
              se = TRUE,
              color = "red",
              fill = "pink",
              size = 1.2) +
  labs(title = "Logistic Regression: Presence of na ~ Sentence.Length",
       x = "Sentence Length",
       y = "Probability of Presence of na = 1") +
  theme_bw()


# =================================================
# Testing effect of position (clause-final or not)
# =================================================

# Create new binary variable: clause-final or not
na_df$na.position <- ifelse(na_df$succeed.pos == "PUNCT", 1, 0)

#na_df$na.position<- as.factor(na_df$na.position)

# Interaction: Sentence length * clause-final position
model_logistic4 <- glm(Type.of.na ~ Sentence.Length*na.position, 
                       family = binomial, 
                       data = na_df)
summary(model_logistic4)

# ===========================================================
# Plot logistic curves separated by clause-final vs non-final
# ============================================================

ggplot(na_df, aes(x = Sentence.Length, y = Type.of.na, color = na.position)) +
  geom_jitter(height = 0.02, alpha = 0.25, size = 0.8) +
  stat_smooth(method = "glm",
              method.args = list(family = binomial),
              se = TRUE,
              fullrange = FALSE,
              size = 1.1) +
  labs(title = "Logistic fit of Presence of na by Sentence Length",
       subtitle = "Separate curves for each na.position",
       x = "Sentence Length",
       y = "Probability(presence of na = 1)",
       color = "Clause final na") +
  theme_minimal()

#Exploratory Analysis

# ================================
# Add preceding POS as predictor
# ================================

na_df$precede.pos<- as.factor(na_df$precede.pos)

model_logistic2 <- glm(Type.of.na ~ Sentence.Length+precede.pos, 
                      family = binomial, 
                      data = na_df)
summary(model_logistic2)

# ============================
# Add Verb.Type as predictor
# ============================

na_df$Verb.Type<- as.factor(na_df$Verb.Type)
summary(na_df)
levels(na_df$Verb.Type)

model_logistic3 <- glm(Type.of.na ~ Sentence.Length+Verb.Type, 
                       family = binomial, 
                       data = na_df)
summary(model_logistic3)

