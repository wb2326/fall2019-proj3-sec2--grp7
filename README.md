# Project: Can you recognize the emotion from an image of a face? 
<img src="figs/CE.jpg" alt="Compound Emotions" width="500"/>
(Image source: https://www.pnas.org/content/111/15/E1454)

### [Full Project Description](doc/project3_desc.md)

Term: Fall 2019

+ Team ##
+ Team members
	+ Lu, Haotian 
	+ Liu, Jiyuan
	+ Guo, Xudong
	+ Bao, Weijia
	+ Liu, Yanyan

+ Project summary: 

In this project, we created a classification engine for images of different facial expressions. We firstly extract linear distance features using SFFS and KSVM. Then, we also added some nonlinear features such as areas and slopes based on basic features.

In terms of classifiers, we considered GBM, LDA, KNN, Boosting, Random Forest and SVM methods. We cross compared the combinations of feature extraction methods and classifiers in order to find the optimal feature-classifer pair.

We also applied GBM as our baseline model with selected feature set to compare with our advanced model. The final advanced model chosen is (k) SVM+. For code details, please check on lib directory.

Round 1 Model Comparison
![](https://github.com/TZstatsADS/fall2019-proj3-sec2--grp7/blob/master/figs/Round1.png)

Round 2 Model Comparison
![](https://github.com/TZstatsADS/fall2019-proj3-sec2--grp7/blob/master/figs/Round2.png)

**Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 


1. Lu, Haotian: Designed and trained baseline GBM model, KNN, LDA, SVM model in python, compared the results for each model. Collaborated with Jiyuan Liu to complete the main.Rmd.

2. Liu, Jiyuan: Designed and trained feature selection in R. Collaborated with Haotian Lu to complete the main.Rmd.

3. Guo, Xudong: Designed and trained random forest model in Python, helped with model training and feature selection process.

4. Bao, Weijia: Studied and trained ksvm and svm method for feature selection. Collaborated with Yanyan Liu, prepared the presentation and slides; collaborated with Jiyuan Liu to complete the main.Rmd. 

5. Liu, Yanyan: Studied and trained Gabor filter for feature selection. Collaborated with Weijia Bao, prepared the presentation and slides; helped with ReadMe. 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
