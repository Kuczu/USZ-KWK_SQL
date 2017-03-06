USE KWK
GO

-- Dodanie stanowisk do kopalni
INSERT INTO Employees.Positions VALUES (1, 'Dyrektor'), (2, 'G��wny In�ynier'), (3, 'Sztygar G�rniczy'), (4, 'G�rnik')

-- Wypisanie wszystkich stnowisk
SELECT * FROM Employees.Positions

-- Dodanie pracownik�w
EXEC Employees.AddEmployee 1, 'Marian', 'Kowalski', '18060218259', 123456789, '1992-08-09'
EXEC Employees.AddEmployee 2, 'Andrzej', 'Kowalik', '41032818230', 951632341, '1993-01-09'
EXEC Employees.AddEmployee 3, 'Marcin', 'Kowal', '78120801933', 950000341, '1993-02-09'
EXEC Employees.AddEmployee 3, 'J�drzej', 'Kos', '77060318390', 951632111, '1993-03-09'
EXEC Employees.AddEmployee 4, 'Gary', 'D. Lynch', '44033018630', 121632341, '1993-04-09'
EXEC Employees.AddEmployee 4, 'Tomasz', 'Kozie�', '33012301153', 121632341, '1993-05-09'
EXEC Employees.AddEmployee 4, 'Patryk', 'Tomaszewski', '00291919573', 121632341, '1993-06-09'
EXEC Employees.AddEmployee 4, '�ukasz', 'Kozi', '46101812230', 121632341, '1993-07-09'
EXEC Employees.AddEmployee 4, 'Sereniusz', 'Serowy', '63091818833', 121632341, '1993-08-09'
EXEC Employees.AddEmployee 4, 'Syriusz', 'Blue', '25081519113', 121632341, '1993-09-09'


-- Wypisanie pracownik�w
SELECT * FROM Employees.BasicInfo
GO

-- Nadanie pracownikowi zwierzchnika
INSERT INTO Employees.Superior VALUES(2, 1, '1993-01-09'), (3, 2, '1993-02-09'), (4, 2, '1993-02-09'),
									(5, 3, '1993-02-09'), (6, 3, '1993-02-09'), (7, 3, '1993-02-09'),
									(8, 4, '1993-02-09'), (9, 4, '1993-02-09'), (10, 4, '1993-02-09')


-- Wypisanie pracownik�w wraz z ich zwierzchnikami
SELECT BI.FirstName, BI.Surname, BI.Gender, BI.PESEL, B.FirstName AS 'Superior Firstname', B.Surname AS 'Superior Surname'
	FROM Employees.BasicInfo AS BI JOIN Employees.Superior AS SUP ON BI.EmployeeID = SUP.EmployeeID
		JOIN Employees.BasicInfo B ON SUP.SuperiorID = B.EmployeeID

-- Dodanie �cian do kopalni
EXEC Longwall.AddLongwall '730 I', 1500, 250, 3, '1994-01-01'
EXEC Longwall.AddLongwall '731', 1000, 200, 2, '1994-02-01'
EXEC Longwall.AddLongwall '732', 1200, 180, 2, '1994-03-01'

-- Zamkni�cie �ciany
EXEC Longwall.CloseLongwall 3, '2000-12-12'

-- Dodanie pracownikowi dzia�u w kt�rym pracuje
EXEC Employees.AddEmployeeDepartement 2, 1, NULL, '1994-01-02'

-- Wypisanie podstawowych informacji o �cianach
SELECT * FROM Longwall.BasicInfo

-- Dodanie obiekt�w dost�pnych do u�ycia na koplani
INSERT INTO Items VALUES('Kombajn �cianowy', 1000000), ('Kombjan chodnikowy', 500000), ('No�e do kombajnu', 80), ('Kilof', 50), ('�opata', 50), ('Ga�nica', 100), ('Obudowa �P29', 500)

-- Dodanie do �ciany mo�liwych do u�ycia przedmiot�w, z ich ilo�ci� startow� oraz ilo�ci� minimaln�
INSERT INTO Longwall.ActualWarehouseStatus VALUES(1, 1, 1, 1), (1, 3, 80, 50), (1, 4, 10, 5), (1, 5, 10, 5)
SELECT * FROM Longwall.ActualWarehouseStatus

-- Utworzenie ho�dy
INSERT INTO Sales.CoalPileStatus VALUES(1, GETDATE(), 0)
SELECT * FROM Sales.CoalPileStatus

-- Dodanie raportu dziennego
EXEC Longwall.AddDailyRaport 1, 3, 1000000, 10, 'BRAK'

-- Wypisanie dziennych raport�w wraz z nazw� �ciany i danymi wpisuj�cego 
SELECT DR.RaportID, DR.RaportDate, LW.LongwallName, DR.ExcavatedCoalQuantityInKg, DR.WallAdvanceInMeters, DR.Comments, BI.EmployeeID, BI.FirstName, BI.Surname
	FROM  Longwall.DailyRaport AS DR JOIN Employees.BasicInfo AS BI ON DR.EmployeeID = BI.EmployeeID
		JOIN Longwall.BasicInfo AS LW ON LW.LongwallID = DR.LongwallID

-- Dodanie klienta
INSERT INTO Sales.Customers VALUES('KWK', 13456789, 'Katowice', 'Ulica...', '100-100', 'Polska')
SELECT * FROM Sales.Customers

-- Dodanie zam�wie�
EXEC Sales.AddOrder 1, 5000, 100
EXEC Sales.AddOrder 1, 1000

-- Wypisanie zam�wie� oczekuj�cych na realizacje
SELECT C.CompanyName, O.* 
	FROM Sales.Orders AS O JOIN Sales.Customers C ON O.CustomerID = C.CustomerID
	WHERE RecipeDate IS NULL