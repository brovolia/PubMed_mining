# PubMed_mining
##Script_pubmed_mining
In this script, I used rentrez package for mining articles with terms of interest. The query to Pubmed is restricted by 200 entities, so I split the query by Chanks. The result is a dataframe with titles, IDs, authors names, and abstracts
##article_search_script
the input data for this script is an output table from GePI  http://gepi.coling.uni-jena.de/, which helps to find the gene and protein interactions for the gene of interest. I converted all article ids to pubmed ids. Next, I retrieved from PubMed abstracts for these articles, then I made the corpora based on these articles and tried to cluster them with adjutant packages based on the content 
##script_references_analysis
Sometimes I review the articles and it's crucial to quickly observe the references, that authors used in the manuscript
  ![top_journals](https://user-images.githubusercontent.com/40294728/233985768-75b4f211-c504-4fe6-b67d-9233e7080d5c.png)
 ![Rplot_year](https://user-images.githubusercontent.com/40294728/233985955-77f28e1f-16bd-48e8-bfd6-1298a9256a52.png)
![Rplot](https://user-images.githubusercontent.com/40294728/233986080-4d1b91e7-43de-4fe7-956e-6129e088f8be.png)
