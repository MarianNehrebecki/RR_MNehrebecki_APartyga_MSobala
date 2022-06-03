library(dplyr)
library(ggplot2)
library(tidyverse)
library(stats)

books <- read.csv('data/book.csv')

View(books)

options(scipen = 10000)

# Deleting repeated Angels & Deamons (appear twice)
books <- books[-c(9241),]


### 1. Books with the highest scores across centuries ###
books %>%
  arrange(desc(scores)) %>%
  head(20) %>%
  mutate(titles = fct_reorder(titles, scores)) %>%
  ggplot(., aes(x = titles, y = scores, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#bebfe6', '#73824a')) + 
  coord_flip() +
  labs(y = 'Score', x = 'Book title', title = '20 Books with highest score on Goodreads',
       fill = 'Century', caption = 'A book’s total score is based on multiple factors, 
       including the number of people who have voted for it and how highly those voters ranked the book.') +
  theme(plot.title = element_text(hjust = .5, margin = margin(b = 20)),
        axis.text.x = element_text(margin = margin(b = 10)),
        axis.text.y = element_text(margin = margin(l = 10)),
        plot.caption = element_text(size = 8, face = "italic"))


### 2. Books that were rated the most times ###
books %>%
  arrange(desc(times.rated)) %>%
  head(20) %>%
  mutate(titles = fct_reorder(titles, times.rated)) %>%
  ggplot(., aes(x = titles, y = times.rated, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#ba8b32', '#bebfe6', '#73824a')) + 
  coord_flip() +
  labs(y = 'Number of times rated', x = 'Book title', title = 'Top 20 most rated books',
       fill = 'Century') +
  theme(plot.title = element_text(hjust = .5, margin = margin(b = 20)),
        axis.text.x = element_text(margin = margin(b = 10)),
        axis.text.y = element_text(margin = margin(l = 10)))

books %>%
  filter(titles == 'Angels & Demons (Robert Langdon, #1)' & centries == '20th')




### 3. Most proflic authors ###

books$books_written <- as.numeric(ave(books$authors, books$authors, FUN = length))

books %>% 
  arrange(desc(books_written)) %>%
  distinct(authors, .keep_all = T) %>%
  filter(authors != 'Anonymous' & authors != 'Unknown') %>%
  head(20) %>%
  mutate(authors = fct_reorder(authors, books_written)) %>%
  ggplot(., aes(x = authors, y = books_written, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#687796', '#ba8b32', '#bebfe6', '#73824a')) + 
  coord_flip() +
  labs(y = 'Number of books written', x = 'Author', title = 'Top 20 prolific authors',
       fill = 'Century') +
  theme(plot.title = element_text(hjust = .5, margin = margin(b = 20)),
        axis.text.x = element_text(margin = margin(b = 10)),
        axis.text.y = element_text(margin = margin(l = 10)))


