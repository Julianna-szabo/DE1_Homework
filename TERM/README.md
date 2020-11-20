# Term project

## Gathering the data

I found my data on data.works.
The data has been collected and previously analysed by Brandon Telle.
This is the link: https://data.world/brandon-telle/cruise-ship-locations

Additionally to the data from Brandol Telle I also gathered my own data about the cruise itinieraries by hand from the MSC website.
This is the specific URL: https://www.msccruises.com/en-gl/Plan-Book/Find-Cruise.aspx

## Cleaning the data

The data required some cleaning  since it was very large and had some errors when reading into SQL.
I will shortly describe the cleaning process by table.

1, ships

This table did not require any cleaning. It already had all the data in the correct format.

2, death

There was a lot of data not added to the table here. I needed to click through the URL-s for many webpages to gather the name of the cruise ship and the cruise line by hand. This was neccessary since I later use the ship name to join this table to another table.

3, dailylocation

I deleted some columns from this table which where unneccessary for my analysis. This was crucial since this table has so many observations that limiting the columns made it easier to work with and able to load into MySQL in a reasobale time.

4, cities

This table I ended up discarding since it was not complete and the information was already contained in the dailylocation table.

5. itineraries

Since i put this table together to my liking it did not require cleaning.

## Operational layer

After laoding the tables into SQL, this is the schema they create:

![shema](https://github.com/Julianna_szabo/DE_Homework/TERM/master/shema.png?raw=true)

## Analytical plan

My most interesting table is deaths. It shows the number of people dying on cruise ships from 2005 to 2017.
With the other tables I would like to answer the question:
*Which route did most people die on?*

To do this I need to create the following:
1, An analytical layer 


