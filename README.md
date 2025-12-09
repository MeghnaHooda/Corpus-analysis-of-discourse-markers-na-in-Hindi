# Corpus-analysis-of-discourse-markers-na-in-Hindi
## Project File Structure

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
- Identifying and tagging discourse markers (e.g., *na*)  
- Producing the sentence-level dataset used in the R analysis  

---

### **Sentence_Wise_Discourse_markers_na.xlsx**
Excel sheet containing the full dataset used in the analysis.  

---

### **Plots/**
Folder containing all generated plots, including:
- Histograms  
- Logistic regression curves  
- Distributional comparisons  
- Diagnostic figures  

These figures are referenced in the analysis and paper.


---

### **Prediction.R**
Supplementary R script used for exploratory purposes only.  
Not part of the final analysis presented in the paper.
