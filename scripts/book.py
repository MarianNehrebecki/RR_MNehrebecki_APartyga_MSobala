# Step 1: Install packages

import selenium.common.exceptions
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.service import Service
from selenium.common.exceptions import NoSuchElementException

from selenium.webdriver.common.by import By
from time import sleep, time

import pandas as pd
import numpy as np

import matplotlib.pyplot as plt

# Step 2: Start with Time measurement for scraping data
start = time()

# Step 3: Analysis of the URL

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
link = "https://www.goodreads.com/list/best_of_century/21st?id=7.Best_Books_of_the_21st_Century&page="
driver.get(link)

pages = np.arange(1, 2)

# Step 4:  Finding and displaying links for Best books by century

# Generate a list of links for each century
centries_names = ['21st'] + [f'{n}th' for n in range(20, 3, -1)]  # 21st, 20th, 19th, ..., 4th
centries = []
for centry_name in centries_names:
    centries.append((centry_name, driver.find_element(by=By.LINK_TEXT, value=centry_name).get_attribute('href')))

# Going to each centry and get page links from there
centries_with_links = []
for centry_name, centry_link in centries:
    driver.get(centry_link)

    # Is pagination on here?
    try:
        pagination = driver.find_element(by=By.CLASS_NAME, value="pagination")
    except NoSuchElementException:
        centries_with_links.append((centry_name, centry_link))
        continue

    # We are sure there is pagination now
    # Pages are from "← Previous" to "Next →"
    # in fact we just need the number before "Next →" occurance.
    page_links = pagination.find_elements(By.TAG_NAME, 'a')
    last_page = page_links[-2].get_attribute('href')  # -1 is "Next →" so the last number is -2
    last_number = int(last_page.split('=')[-1])

    # links are from: page=, page=2, page=3, ..., page=last_number
    # we are going to generate those links:
    numbers = [''] + [str(n) for n in range(2, last_number+1)]  # , 2, 3 ,4, 5, ..., last
    centries_with_links += [(centry_name, "=".join(last_page.split('=')[:-1] + [str(n)])) for n in numbers]

print(f"There is {len(centries_with_links)} pages to analyze.")
sleep(0.5)

# Step 5:  Scraping multiple pages
print("Web scraping has begun")

# Step 6: Preparation of the storage of the scraping data
element_list = []
skipped = 0
allowed_authors = ["(U.S.)", "(Fils)", "Juan Ruiz (Arcipreste de Hita)"] + [f"{n})" for n in range(0, 10)]
for n, centry_with_link in enumerate(centries_with_links, start=1):
    centry_name, link = centry_with_link
    driver.get(link)
    print(f"Scraping {n} link: {link}  It's {100*n/len(centries_with_links):.2f}% of total amount of pages")
    sleep(0.1)


# Step 7: Scraping of the selected information
    titles = [1]  # just for exception
    try:
        titles = driver.find_elements(by=By.CLASS_NAME, value="bookTitle")
        authors = driver.find_elements(by=By.CLASS_NAME, value="authorName")

        # Avoid authors like (Contributor/Editor), (Pseudonym), (Writer)
        new_authors = []
        for author in authors:
            if author.text.startswith('('):
                continue
            if author.text.endswith(')') and not any(allowed in author.text for allowed in allowed_authors):
                continue
            new_authors.append(author)
        authors = new_authors[:]
        ratings = driver.find_elements(by=By.CLASS_NAME, value="minirating")
        scores = driver.find_elements(by=By.PARTIAL_LINK_TEXT, value="score:")
        votes = driver.find_elements(by=By.PARTIAL_LINK_TEXT, value="voted")
        votes = [vote for vote in votes if vote.text.endswith('voted')]
    except (selenium.common.exceptions.StaleElementReferenceException, IndexError):
        skipped += len(titles)
        continue
    length = len(titles)
    if len(authors) != length or len(ratings) != length or len(scores) != length or len(votes) != length:
        skipped += len(titles)
        continue
    for i in range(length):
        href = titles[i].get_attribute("href")
        element_list.append(
            [centry_name, titles[i].text, authors[i].text, ratings[i].text, scores[i].text, votes[i].text, href])

print("Scraping is done! Now, let's create our dataset!")
print(f"Skipeed books: {skipped}, appended: {len(element_list)}")

# Step 8: End with Time measurement for scraping data
stop = time()
print(stop-start)

# Step 9: Creating dataframes from scraping data
books = pd.DataFrame(element_list)
# We introduce the name of the column
books.columns = ['centries', 'titles', 'authors', 'ratings', 'scores', 'votes', 'website']
# Display our dataframe
print(books)

# Step 9: Cleaning data using pandas

books['votes'] = books['votes'].str.replace(',', '')
books['votes'] = books['votes'].str.extract(r'(\d+)').astype(int)

books['scores'] = books['scores'].str.replace(',', '')
books['scores'] = books['scores'].str.extract(r'(\d+)').astype(int)

books['ratings'] = books['ratings'].str.replace('really liked it ', '')
books['ratings'] = books['ratings'].str.replace(',', '')

books['average rating'] = books['ratings'].apply(lambda x: x.split()[0])
books['average rating'] = books['average rating'].str.replace('really', '')
books['average rating'] = books['average rating'].str.replace('it', '')
books['average rating'] = books['average rating'].str.replace('liked', '')

books['average rating'] = pd.to_numeric(books['average rating'], errors='coerce')

books.drop("ratings", axis=1, inplace=True)
books['average rating'].replace('', np.nan, inplace=True)
books.dropna(subset=['average rating'], inplace=True)

# Step 10: Display the data types of the variables
print(books.dtypes)

# Step 11: Verifying missing data
print(books.isnull().sum())

# Step 12: Save the scraping data into a CSV file
books.to_csv("books_selenium.csv")


# Step 13: Replace the zero values for the variables in the DataFrame to NaN.
books.replace(str(0), np.nan, inplace=True)
books.replace(0, np.nan, inplace=True)

# Step 14: Counting the Number of NaNs for the variables in the DataFrame

count_nan = len(books) - books.count()
print(count_nan)

sleep(3)
driver.close()

# Step 15: Some basic statistics for the variables  in the DataFrame

books.describe()


# Step 16: Plotting the distributions of the variables: votes, scores, average rating

fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(16, 4))
ax1, ax2, ax3 = fig.axes
ax1.hist(books['votes'])
ax1.set_title('votes')
ax2.hist(books['scores'])
ax2.set_title('scores')

ax3.hist(books['average rating'])
ax3.set_title('average rating')

for ax in fig.axes:
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
plt.show()
