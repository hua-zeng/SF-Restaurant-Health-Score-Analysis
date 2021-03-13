# SF-Restaurant-Health-Score-Analysis
The data of SF restaurant health score included information of year 2014-2016 and January of 2017. The minimum health score (inspection score) received by the restaurant during 2014-2017 is 46.  The maximum health score (inspection score) received by the restaurant during 2014-2017 is 100.  

![Figure 1](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig1.jpg)
![Figure 2](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig2.jpg)

From **Figure 1**, most restaurants had a health score between 85 and 90. The health score is significantly different for the resultants with different risk level based on the ANOVA test. In all the years, the percentage of restaurants in the low risk category is highest among all risk categories. The percentages are all greater than 35% (40.8% in 2014, 35.9% in 2015, 39.2% in 2016, and 46.5% in 2017 respectively).  The number restaurants in low risk, moderate risk, or high risk is 13,873 in 2014, 9,573 in 2015, 16,983 in 2016, and 374 in January of 2017.  

![Figure 3](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig3.jpg)
![Figure 4](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig4.jpg)

From **Figure 3**, the heat map indicates that more restaurants have low risk events in the first period of the year compared to the second period of the year. In 2014-2016, most restaurants with high risk events were located in the north and west of San Francisco based on **Figure 4**. 

![Figure 3](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig5.jpg)
![Figure 4](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig6.jpg)

The average health score on restaurant level ranged from 56 to 100. Most restaurants had a health score in the range of 85-95 based on **Figure 5**. The number of total risk events of all the restaurants is distributed between 0 and 96. The number is right skewed with most restaurants had less than 10 risk events. There are 376 restaurants with perfect health score and no risk events have been found. **Figure 6** shows the trend of average health score by month. From the plot, it seems the average health score increased during the spring period (February-May), and decreased in the summer period (June-August). 

![Figure 7](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig7.jpg)

From **Figure 7** we can see the total number of high risk events, no risk events, and month are significant variables which impact the average health score. The residual stand of error is 0.2825, which indicates that on average, using the least squares regression line to predict head count from reported health score, results in an error of about 0.2825. 

![Figure 8](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig8.jpg)

The k-Nearest Neighbor prediction method was used to predict the risk category based on health score, the longitude, and the latitude of the restaurant. The algorithm had an accuracy of 0.6622 based on the confusion matrix results from **Figure 8**.

![Figure 9](https://github.com/hua-zeng/SF-Restaurant-Health-Score-Analysis/blob/main/fig9.jpg)

**Figure 9** shows the word cloud for the violation description from the inspections. “Food”, “violation”, “inadequate”, “risk”, and “unclean” were the top 5 most frequent seen words in the description.

The results showed a significant association between health score vs total number of risks, latitude, and longitude. The research indicates that health condition is better in the spring period compared to other parts of the year. In the summer, the health score is less than the average of the year. The project provided a way to predict the risk category of a restaurant health condition in San Francisco based on its health score and geographic information. It also provided a list of perfect health score restaurants during the study period for consumers to choose. 

**Reference:**

Restaurants Health Score Data in San Francisco (https://data.sfgov.org/Health-and-Social-Services/Restaurant-Scores-LIVES-Standard/pyih-qa8i/data)

