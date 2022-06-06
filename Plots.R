library(dplyr)
library(ggplot2)
library(tidyverse)
library(stats)
library(scales)

books <- read.csv('data/book.csv')

View(books)

options(scipen = 10000)

# Deleting repeated Angels & Deamons (appear twice)
books <- books[-c(9241),]

books$truncated_titles <- str_trunc(books$titles, 33)


### 1. Books with the highest scores across centuries ###
plot1 <- books %>%
  arrange(desc(scores)) %>%
  head(20) %>%
  mutate(truncated_titles = fct_reorder(truncated_titles, scores)) %>%
  ggplot(., aes(x = truncated_titles, y = scores, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#bebfe6', '#73824a')) + 
  scale_y_continuous(labels = label_number(suffix = " K", scale = 1e-3)) +
  coord_flip() +
  labs(y = 'Score', x = '', title = '',
       fill = 'Century', caption = 'A book’s total score is based on multiple factors, 
       including the number of people who have voted for it and how highly those voters ranked the book.') +
  theme_minimal() +
  theme(axis.title.x = element_text(size = 8, margin = margin(t = 10)),
        plot.caption = element_text(size = 8, face = "italic"))


### 2. Books that were rated the most times ###
plot2 <- books %>%
  arrange(desc(times.rated)) %>%
  head(20) %>%
  mutate(truncated_titles = fct_reorder(truncated_titles, times.rated)) %>%
  ggplot(., aes(x = truncated_titles, y = times.rated, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#ba8b32', '#bebfe6', '#73824a')) + 
  scale_y_continuous(labels = label_number(suffix = " M", scale = 1e-6)) +
  coord_flip() +
  labs(y = 'Number of times rated', x = '', title = '',
       fill = 'Century') +
  theme_minimal() +
  theme(axis.title.x = element_text(size = 8, margin = margin(t = 10)))

books %>%
  filter(titles == 'Angels & Demons (Robert Langdon, #1)' & centries == '20th')




### 3. Most prolific authors ###

books$books_written <- as.numeric(ave(books$authors, books$authors, FUN = length))

plot3 <- books %>% 
  arrange(desc(books_written)) %>%
  distinct(authors, .keep_all = T) %>%
  filter(authors != 'Anonymous' & authors != 'Unknown') %>%
  head(20) %>%
  mutate(authors = fct_reorder(authors, books_written)) %>%
  ggplot(., aes(x = authors, y = books_written, fill = centries)) +
  geom_bar(stat = 'identity') +
  scale_fill_manual(values =  c('#687796', '#ba8b32', '#bebfe6', '#73824a')) + 
  coord_flip() +
  labs(y = 'Number of books written', x = '', title = '',
       fill = 'Century') +
  theme_minimal() +
  theme(axis.title.x = element_text(size = 8, margin = margin(t = 10)))


