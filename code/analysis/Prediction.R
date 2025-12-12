library(ggplot2)
library(caTools)

na_data <- read.csv("Sentence_Wise_Discourse_markers_na.csv")


na_df <- na_data[na_data$na != 'Neg na', ]
#na_df <- na_data[na_data$Sentence.Length >10, ]
#na_df <- na_data[na_data$Sentence.Length <20, ]
summary(na_df)

na_df$Type.of.na <- ifelse(na_df$na == "na", 1, 0)

na_df$na.position <- ifelse(na_df$succeed.pos == "PUNCT", 1, 0)
#dividing data

set.seed(123) # For reproducibility
split <- sample.split(na_df$Type.of.na, SplitRatio = 0.7) # 70% training, 30% testing
train_data <- subset(na_df, split == TRUE)
test_data  <- subset(na_df, split == FALSE)

#ggplot(na_df, aes(x = Sentence.Length, fill=na)) +
#  geom_histogram(alpha = 0.5, position = "identity")



model_logistic <- glm(Type.of.na ~ Sentence.Length, 
                      family = binomial, 
                      data = train_data)
summary(model_logistic)

head(train_data)


ggplot(train_data, aes(x = Sentence.Length, y = Type.of.na)) +
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


#train_data$na.position<- as.factor(train_data$na.position)
model_logistic4 <- glm(Type.of.na ~ Sentence.Length*na.position, 
                       family = binomial, 
                       data = train_data)
summary(model_logistic4)

predictions <- predict(model_logistic4, newdata = test_data, type = "response")
head(predictions)

class_predictions <- ifelse(predictions > 0.5, "Yes", "No")
head(class_predictions)

exp(coef(model_logistic4))

library(caret)

#levels(factor(class_predictions))
#levels(factor(test_data$Type.of.na))

#conf_matrix <- confusionMatrix(factor(class_predictions), factor(test_data$Type.of.na))
#print(conf_matrix)

class_predictions_num <- ifelse(class_predictions == "Yes", "1", "0")

# Make factors with same levels
all_levels <- c("0", "1")
class_predictions_num <- factor(class_predictions_num, levels = all_levels)
test_labels <- factor(test_data$Type.of.na, levels = all_levels)

library(caret)
conf_matrix <- confusionMatrix(class_predictions_num, test_labels)
print(conf_matrix)

# Extract precision and recall for class "1"
precision <- conf_matrix$byClass["Pos Pred Value"]
recall <- conf_matrix$byClass["Sensitivity"]
