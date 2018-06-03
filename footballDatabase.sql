/*
use master
go
drop database football
go
*/
create database football
go
use football
go

create table Managers(
	Ssn char(10),
	Name varchar(25) NOT NULL,
	Salary tinyint, --in millions
	PRIMARY KEY (Ssn)
);

insert into Managers values('9999999999', 'Vacated', 0)
insert into Managers values('1234567890', 'Alex Ferguson', 5)
insert into Managers values('1234567891', 'Jose Mourinho', 24)
insert into Managers values('1234567892', 'Mauricio Pochettino', 17)
insert into Managers values('1234567893', 'Antonio Conte', 19)

select * from Managers

create table Teams(
	Name varchar(20) NOT NULL,
	NumTrophies tinyint,
	ManagerSsn char(10) NOT NULL DEFAULT '9999999999',
	PRIMARY KEY (Name),
	FOREIGN KEY (ManagerSsn) REFERENCES Managers(Ssn) ON DELETE SET DEFAULT ON UPDATE CASCADE
);

insert into Teams values('Manchester United', 20, '1234567891')
insert into Teams values('Tottenham', 2, '1234567892')
insert into Teams values('Chelsea', 6, '1234567893')
insert into Teams(Name, NumTrophies) values('Manchester City', 4)

select * from Teams

create table Matches(
	HomeTeamName varchar(20) NOT NULL,
	AwayTeamName varchar(20) NOT NULL,
	result char(3) CHECK(result like '_:_'),
	PRIMARY KEY(HomeTeamName, AwayTeamName),
	FOREIGN KEY (HomeTeamName) REFERENCES Teams(Name),
	FOREIGN KEY (AwayTeamName) REFERENCES Teams(Name),
	CHECK( HomeTeamName != AwayTeamName )
);

insert into Matches values('Manchester United', 'Tottenham', '2:1')
insert into Matches values('Tottenham', 'Manchester United', '0:2')
insert into Matches values('Manchester United', 'Chelsea', '3:0')
insert into Matches values('Manchester city', 'Tottenham', '1:2')
insert into Matches values('Tottenham', 'Chelsea', '2:1')

select * from Matches

create table TeamGrounds(
	TeamName varchar(20),
	GroundName varchar(20),
	PRIMARY KEY(TeamName, GroundName),
	FOREIGN KEY (TeamName) REFERENCES Teams(Name) ON DELETE CASCADE ON UPDATE CASCADE,
);

insert into TeamGrounds values('Manchester United', 'Old Trafford')
insert into TeamGrounds values('Manchester City', 'Etihad')
insert into TeamGrounds values('Tottenham', 'Wembley')
insert into TeamGrounds values('Chelsea', 'Stamford Bridge')

select * from TeamGrounds

create table Players(
	Ssn char(10),
	KitNumber tinyint,
	TeamName varchar(20) NOT NULL,
	Fname varchar(10),
	LName varchar(10),
	Age tinyint,
	Salary tinyint, --in millions
	Address varchar(30),
	PRIMARY KEY(Ssn),
	FOREIGN KEY (TeamName) REFERENCES Teams(Name) ON DELETE CASCADE ON UPDATE CASCADE
);

insert into Players values('0000000001', '25', 'Manchester United', 'Antonio', 'Valencia', 32, 16, 'Downtown Abbey, Manchester')
insert into Players values('0000000002', '7', 'Manchester United', 'Alexis', 'Sanchez', 29, 45, 'Stretford, Manchester')
insert into Players values('0000000003', '9', 'Manchester United', 'Romelu', 'Lukaku', 25, 30, 'Downtown Abbey, Manchester')
insert into Players values('0000000004', '6', 'Manchester United', 'Paul', 'Pogba', 25, 50, 'Downtown Abbey, Manchester')

insert into Players values('0000000005', '7', 'Manchester City', 'Rahim', 'Sterling', 23, 32, 'Downtown Abbey, Manchester')
insert into Players values('0000000006', '10', 'Manchester City', 'Sergio', 'Aguero', 29, 27, 'Stretford, Manchester')

insert into Players values('0000000007', '7', 'Tottenham', 'Heung-min', 'Son', 25, 20, 'Trafalgar Square, London')
insert into Players values('0000000008', '9', 'Tottenham', 'Harry', 'Kane', 25, 22, 'Upper side, London')

insert into Players values('0000000009', '7', 'Chelsea', 'Eden', 'Hazard', 25, 36, 'Trafalgar Square, London')


select * from Players 

--------------------------------------------------------------------------------------------------------------------------
/* 1. Изведете отбора, имената и възрастта на всички футболисти, които живеят на 'Downtown Abbey, Manchester'
и тренират на Old Trafford
*/
select TeamName, Fname, LName, Age
from Players
where Address = 'Downtown Abbey, Manchester' 
	and TeamName in (select TeamName from TeamGrounds where GroundName = 'Old Trafford')
	

/* 2. Изведете името на мениджърът начело на отбора, в който играе Harry Kane
*/
select m.Name
from Players p join Teams t on p.TeamName = t.Name and p.Fname='Harry' and p.LName='Kane' 
	join Managers m on t.ManagerSsn = m.Ssn


/* 3. За всеки отбор, в който има поне един играч, изведете името на отбора, общата заплата, която плаща на играчи,
и заплатата, която плаща на мениджър
*/
select TeamName, sum(p.salary) as PlayerSalaries, max(m.salary) as ManagerSalary
from Players p join Teams t on p.TeamName = t.Name join Managers m on t.ManagerSsn = m.Ssn
group by TeamName


/* 4. За всеки изигран мач, в който има двама футболисти с един и същ номер, изкарайте имената на двата отбора, 
номера и имената на тези футболисти
*/
select m.HomeTeamName, m.AwayTeamName, pht.KitNumber, pht.Fname, pht.LName, pat.Fname, pat.LName
from Matches m join Players pht on pht.TeamName = m.HomeTeamName join Players pat on pat.TeamName = m.AwayTeamName
where pht.KitNumber = pat.KitNumber


/* 5. За всеки мениджър, различен от специалният запис 'Vacated', изведете всички играчи, които той ръководи.
Ако за някой мениджър няма нито един играч да се изписва NULL
*/
select m.Name, p.Fname, p.LName
from Managers m left join Teams t on m.Ssn = t.ManagerSsn left join Players p on t.Name = p.TeamName
where m.Name != 'Vacated'

/* 6. За всеки играч изкарайте всички резултати на мачовете на неговият отбор
*/
select p.Fname, p.LName, t.Name as PlaysIn, m.*
from Players p join Teams t on p.TeamName = t.Name join Matches m on (t.Name = m.HomeTeamName OR t.Name = m.AwayTeamName)
order by p.Fname, p.LName


--test filter on task5
select task5.Name, task5.LastName
from (select m.Name as managerName, p.Fname as Name, p.LName as LastName
		from Managers m left join Teams t on m.Ssn = t.ManagerSsn left join Players p on t.Name = p.TeamName
		where m.Name != 'Vacated') task5
where managerName = 'Mauricio Pochettino'

--test filter on task6
select HomeTeamName, AwayTeamName, result
from (select p.Fname as firstName, p.LName as lastName, t.Name as PlaysIn, m.*
		from Players p join Teams t on p.TeamName = t.Name join Matches m on (t.Name = m.HomeTeamName OR t.Name = m.AwayTeamName)) as task6
where firstName = 'Alexis' and lastName = 'Sanchez'
