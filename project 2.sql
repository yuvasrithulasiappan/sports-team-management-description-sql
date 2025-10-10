#sports team management system
#Create a Database called "sports_team"
create database sports_team;
use sports_team;

#Create table "Leagues"
CREATE TABLE Leagues (
    LeagueID INT PRIMARY KEY,
    LeagueName VARCHAR(50),
    Country VARCHAR(50)
);
DESC Leagues;
alter table leagues modify Country VARCHAR(100);
alter table leagues modify LeagueName VARCHAR (100);

#Create table "Teams"
CREATE TABLE Teams (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(50),
    City VARCHAR(50),
    LeagueID INT,
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID)
);
DESC Teams; 
alter table Teams modify TeamName VARCHAR(100);
alter table Teams modify  City VARCHAR(50);

#Create table "Players"
CREATE TABLE Players (
    PlayerID INT PRIMARY KEY,
    PlayerName VARCHAR(50),
    Age INT,
    Position VARCHAR(30),
    TeamID INT,
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
DESC players;
alter table players modify PlayerName VARCHAR(150);

#Create table "Matches"
CREATE TABLE Matches (
    MatchID INT PRIMARY KEY,
    MatchDate DATE,
    Team1ID INT,
    Team2ID INT,
    LeagueID INT,
    FOREIGN KEY (Team1ID) REFERENCES Teams(TeamID),
    FOREIGN KEY (Team2ID) REFERENCES Teams(TeamID),
    FOREIGN KEY (LeagueID) REFERENCES Leagues(LeagueID)
);
DESC Matches;

#Create table "Scores"
CREATE TABLE Scores (
    ScoreID INT PRIMARY KEY,
    MatchID INT,
    TeamID INT,
    Goals INT,
    FOREIGN KEY (MatchID) REFERENCES Matches(MatchID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
DESC scores;
set sql_safe_updates=0;

# insert values into Leagues
INSERT INTO Leagues (LeagueID, LeagueName, Country)
VALUES 
(1, 'Premier League', 'England'),
(2, 'La Liga', 'Spain'),
(3, 'Serie A', 'Italy');

#Insert values into Teams
INSERT INTO Teams (TeamID, TeamName, City, LeagueID)VALUES
(101, 'Manchester United', 'Manchester', 1),
(102, 'Chelsea', 'London', 1),
(201, 'Barcelona', 'Barcelona', 2),
(202, 'Real Madrid', 'Madrid', 2),
(301, 'AC Milan', 'Milan', 3),
(302, 'Juventus', 'Turin', 3);

#Insert values into Players
INSERT INTO Players (PlayerID, PlayerName, Age, Position, TeamID)VALUES
(1, 'Bruno Fernandes', 29, 'Midfielder', 101),
(2, 'Marcus Rashford', 27, 'Forward', 101),
(3, 'Mason Mount', 26, 'Midfielder', 102),
(4, 'Raheem Sterling', 30, 'Forward', 102),
(5, 'Robert Lewandowski', 36, 'Forward', 201),
(6, 'Pedri', 23, 'Midfielder', 201),
(7, 'Vinicius Jr', 25, 'Forward', 202),
(8, 'Luka Modric', 39, 'Midfielder', 202),
(9, 'Olivier Giroud', 38, 'Forward', 301),
(10, 'Federico Chiesa', 28, 'Forward', 302);

#Insert values into Matches
INSERT INTO Matches (MatchID, MatchDate, Team1ID, Team2ID, LeagueID)VALUES
(1, '2025-09-10', 101, 102, 1),
(2, '2025-09-12', 201, 202, 2),
(3, '2025-09-15', 301, 302, 3);

#Insert values into Scores
INSERT INTO Scores (ScoreID, MatchID, TeamID, Goals)VALUES
(1, 1, 101, 2),  -- Man United scored 2
(2, 1, 102, 1),  -- Chelsea scored 1
(3, 2, 201, 3),  -- Barcelona scored 3
(4, 2, 202, 2),  -- Real Madrid scored 2
(5, 3, 301, 1),  -- AC Milan scored 1
(6, 3, 302, 1);  -- Juventus scored 1 (Draw)
#select statements
select * from Leagues;
select * from Teams;
select * from players;
select * from Matches;
select * from Scores;

/*Queries*/
#1.Show scores of a specific match
select * from scores WHERE matchID=1;
select * from scores WHERE matchID=2;
select * from scores WHERE matchID=3;

#2.Show team names with their league names
select teamname,(select leaguename from leagues a where a.leagueid=b.leagueid )as leaguename from teams b;

#3.Display all player names along with their team names and league names.
select a.leaguename,b.teamname,c.playername from leagues a left join teams b on a.leagueid=b.leagueid left join players c on b.teamid=c.teamid;

#4.List all matches with both team names and their scores
select * from scores a left join teams b on a.teamid=b.teamid inner join matches c on b.leagueid=c.leagueid; 

#5.Find matches where both teams scored more than 2 goals;
SELECT MatchID FROM Scores GROUP BY  MatchID HAVING MIN(Goals) > 2;

#6.Create a trigger to update a log table when a score is updated.
CREATE TRIGGER AfterScoreUpdate
AFTER UPDATE ON Scores
FOR EACH ROW
INSERT INTO ScoreLog (ScoreID, OldGoals, NewGoals)
VALUES (OLD.ScoreID, OLD.Goals, NEW.Goals);

#7.create a view for each team’s total goals in all matches
CREATE OR REPLACE VIEW TeamGoalsView AS
SELECT T.TeamName,
    SUM(S.Goals) AS TotalGoals FROM Teams T
JOIN 
    Scores S ON T.TeamID = S.TeamID GROUP BY  T.TeamName;
SELECT * FROM TeamGoalsView;

#8.Show all players in a specific team.
DELIMITER $$
CREATE PROCEDURE ShowPlayersByTeam(IN team_id INT)
BEGIN
    SELECT PlayerName FROM Players WHERE TeamID = team_id;
END$$
DELIMITER ;
CALL ShowPlayersByTeam(101);

