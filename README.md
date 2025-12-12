# Corpus-analysis-of-discourse-markers-na-in-Hindi
## Project File Structure

project-root/
|-- README.md # Project overview and setup instructions
|-- pyproject.toml # Dependencies and environment setup
|-- data/Sentence_Wise_Discourse_markers_na.xlsx #Cleaned/processed data
|-- code/
| |-- preprocessing/ # Data preparation scripts
|     ‘-- sentence_wise_discourse_markers.py #Python script
| ‘-- analysis/ # Statistical analysis scripts
|     |-- Analysis_na.R #R script of the full analysis
|     ‘-- Prediction.R #upplementary R script used for exploratory purposes
|-- results/
| |-- figures/ # Generated plots and visualizations
| ‘-- tables/ # Statistical output tables
|-- paper/
  |-- paper.pdf # Final paper submission
  ‘-- term paper.ppt # Presentation

### **Analysis_na.R**
Main R script containing the full analysis used in the paper.  
Includes:
- Data cleaning and preprocessing  
- Descriptive statistics  
- Visualizations  
- Logistic regression models   

---

### **sentence_wise_discourse_markers.py**
Python script used to extract all sentences from the raw corpus.  
Responsible for:
- Detecting sentence boundaries  
- Identifying and tagging discourse markers (*na*)  
- Producing the sentence-level dataset used in the R analysis  

---

### **Sentence_Wise_Discourse_markers_na.xlsx**
Excel sheet containing the full dataset used in the analysis.  

---

### **Prediction.R**
Supplementary R script used for exploratory purposes only.  
Not part of the final analysis presented in the paper.
