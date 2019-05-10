library("RMySQL")
myconnection <- dbConnect(dbDriver("MySQL"),
                          host="mydb.ics.purdue.edu",
                          username="mdw_guest",
                          password="MDW_csp2018",
                          dbname="mdw")

# n = -1 fetches all results. n > 0 is a head query.
easyquery <- function(x, n=-1) {
  fetch(dbSendQuery(myconnection, x), n=n)
}

###############################################

# Here are the players from
# the Boston Red Sox in the year 2008
myDF <- easyquery("SELECT m.playerID, b.yearID, b.teamID,
                   m.nameFirst, m.nameLast
                   FROM Batting b JOIN Master m
                   ON b.playerID = m.playerID
                   WHERE b.teamID = 'BOS'
                   AND b.yearID = 2008;")

myDF

easyquery("SHOW TABLES")
easyquery("DESC Batting")


# K's by Nolan Ryan

myDF <- easyquery("SELECT m.playerID, p.yearID, p.SO,
                   m.nameFirst, m.nameLast
                   FROM Pitching p JOIN Master m
                   ON p.playerID = m.playerID
                   where m.nameFirst = 'Nolan' and m.nameLast = 'Ryan';")

myDF

sum(myDF$SO)

# find players hitting more than 600 hr

hr600 = easyquery("SELECT m.playerID,
                   m.nameFirst, m.nameLast, sum(b.HR) sHR
                   FROM Batting b JOIN Master m
                   ON b.playerID = m.playerID
                   group by b.playerID
                   having sHR > 600
                   ")

hr600

# find players in 40-40 club; >=40 hr and >=40 stolen bases

pl4040 = easyquery("SELECT m.playerID, b.yearID, b.SB, b.HR,
                   m.nameFirst, m.nameLast
                   FROM Batting b JOIN Master m
                   ON b.playerID = m.playerID
                   where SB >= 40 and HR >= 40")

pl4040

# Find largest number of home runs by an individual by year

hrmax_year = easyquery("SELECT m.playerID, b.yearID,
                         m.nameFirst, m.nameLast, sum(b.HR) sHR
                         FROM Batting b JOIN Master m
                         ON b.playerID = m.playerID
                         group by b.playerID, b.yearID")

tapply(hrmax_year$sHR, INDEX = list(hrmax_year$playerID, hrmax_year$yearID), FUN = max, na.rm = T)
