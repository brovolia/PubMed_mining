library(bib2df)
library(ggplot2)
library(dplyr)
library(adegenet)
library(tidyverse)
library(tm)
library(wordcloud)

#I converted .txt file with list of references to .bib file using https://anystyle.io/
#convert .bib to df format with bib2df package
ref <- bib2df("./anystyle.bib")

#top 10 journals
top_ten_journals <- ref %>%
  filter(!is.na(JOURNAL)) %>%
  group_by(JOURNAL) %>%
  summarize(n = n()) %>%
  arrange(desc(n)) %>% 
  top_n(10, n)
#plot top journals
ggplot(top_ten_journals) +
  geom_col(aes(fct_reorder(JOURNAL, n), n, fill = n), 
           colour = "grey30", width = 1) +
  labs(x = "", y = "", title = "Top 10 journals") +
  coord_flip() +
  scale_fill_gradientn("n", colours = greenpal(10)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_x_discrete(expand = c(0, 0)) 

#year of publication
ref <- ref[ref$DATE>1990, ]
year_pub <- ref %>% 
  filter(is.na(DATE) == FALSE) %>% 
  mutate(DATE = as.numeric(DATE)) %>% 
  mutate(age = 2015 - DATE) %>%
  summarize(median_age = median(age),
            median_year = median(DATE))
year_pub
#plot year of publication
ref %>% 
  filter(is.na(DATE) == FALSE) %>% 
  ggplot(aes(x = as.numeric(DATE))) +
  geom_bar(width = 1, fill = greenpal(6)[4]) +
  geom_vline(data = year_pub, aes(xintercept = median_year), 
             colour = "grey30", size = 1) +
  labs(x = "", y = "") +
  ggtitle("Number of publication per year") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  axis(1, at = seq(1990, 2022, by = 1))

#word cloud    
  pubcorpus <- Corpus(VectorSource(ref$TITLE)) %>% 
    tm_map(content_transformer(tolower)) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeWords, stopwords('english'))  

  my_wordcloud1 <- wordcloud(pubcorpus, max.words = 200, random.order = FALSE)  
  