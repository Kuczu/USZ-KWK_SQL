-- CREATE DATABASE
CREATE DATABASE KWK
GO

USE KWK
GO

-- //////////////// CREATE TABLES
-- CREATE EMPLOYEES
CREATE SCHEMA Employees
GO

CREATE TABLE Employees.Positions(
	PositionID INT,
	PositionName NVARCHAR(50) NOT NULL,
	PRIMARY KEY(PositionID)
)
GO

CREATE TABLE Employees.BasicInfo(
	EmployeeID INT IDENTITY(1,1),
	PositionID INT NOT NULL,
	FirstName NVARCHAR(30) NOT NULL,
	Surname NVARCHAR(30) NOT NULL,
	Gender NCHAR(1) NOT NULL CHECK(Gender = 'M' OR Gender = 'F'),
	PESEL NVARCHAR(11) NOT NULL CHECK(LEN(PESEL) = 11),
	TelephoneNumber INT,
	BirthDATE DATE NOT NULL,
	HireDATE DATE NOT NULL,
	DismissalDATE DATE DEFAULT NULL,
	UNIQUE(PESEL),
	PRIMARY KEY(EmployeeID),
	FOREIGN KEY(PositionID) REFERENCES Employees.Positions(PositionID) 
)
GO

CREATE TABLE Employees.Vacation( -- urlop
	EmployeeID INT,
	StartDATE DATE,
	EndDATE DATE NOT NULL,
	PRIMARY KEY(EmployeeID, StartDATE),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID) 
)
GO

CREATE TABLE Employees.Superior(
	EmployeeID INT,
	SuperiorID INT,
	StartDATE DATE,
	PRIMARY KEY(EmployeeID, StartDATE),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID),
	FOREIGN KEY(SuperiorID) REFERENCES Employees.BasicInfo(EmployeeID)
)
GO

CREATE TABLE Employees.WorkHours(
	EmployeeID INT,
	StartDATE SMALLDATETIME,
	EndDate SMALLDATETIME,
	PRIMARY KEY(EmployeeID, StartDate),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID)
)
GO

-- CREATE AVAIBLE ITEMS IN A MINE
CREATE TABLE Items(
	ItemID INT IDENTITY(1,1),
	ItemName NVARCHAR(150) NOT NULL,
	ItemPrice MONEY CHECK(ItemPrice > 0),
	PRIMARY KEY(ItemID)
)
GO

-- CREATE LONGWALL
CREATE SCHEMA Longwall
GO

CREATE TABLE Longwall.BasicInfo(
	LongwallID INT IDENTITY(1,1),
	LongwallName NVARCHAR(30) UNIQUE NOT NULL,
	LongwallLong INT NOT NULL CHECK(LongwallLong > 0), -- wybieg
	LongwallWide INT NOT NULL CHECK(LongwallWide > 0), -- szerokosc
	LongwallThick INT NOT NULL CHECK(LongwallThick > 0), -- wysokosc
	StartDate DATE NOT NULL,
	EndDate DATE DEFAULT NULL,
	PRIMARY KEY(LongwallID)
)
GO

CREATE TABLE Longwall.DailyRaport(
	RaportID INT IDENTITY(1,1),
	EmployeeID INT NOT NULL,
	LongwallID INT NOT NULL,
	RaportDate DATE NOT NULL,
	ExcavatedCoalQuantityInKg INT NOT NULL CHECK(ExcavatedCoalQuantityInKg >= 0), -- urobek kg
	WallAdvanceInMeters INT NOT NULL CHECK(WallAdvanceInMeters >= 0), -- postep m
	Comments NVARCHAR(MAX) DEFAULT NULL,
	PRIMARY KEY(RaportID),
	UNIQUE(RaportDate, LongwallID),
	FOREIGN KEY(LongwallID) REFERENCES Longwall.BasicInfo(LongwallID),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID)
)
GO

CREATE TABLE Longwall.ActualWarehouseStatus(
	LongwallID INT NOT NULL,
	ItemID INT NOT NULL,
	AvailableAmount INT NOT NULL,
	MinimumAmount INT NOT NULL CHECK(MinimumAmount > 0),
	PRIMARY KEY(LongwallID, ItemID),
	FOREIGN KEY(LongwallID) REFERENCES Longwall.BasicInfo(LongwallID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)
GO

CREATE TABLE Longwall.UsedResources(
	RaportID INT,
	ItemID INT NOT NULL,
	ItemUsedAmount INT NOT NULL CHECK(ItemUsedAmount > 0),
	PRIMARY KEY(RaportID, ItemID),
	FOREIGN KEY(RaportID) REFERENCES Longwall.DailyRaport(RaportID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)
GO

CREATE TABLE Longwall.ItemsOrder(
	LongwallID INT NOT NULL,
	ItemID INT NOT NULL,
	OrderedItemAmount INT NOT NULL CHECK(OrderedItemAmount > 0),
	OrderDate DATE NOT NULL,
	PRIMARY KEY(LongwallID, ItemID, OrderDate),
	FOREIGN KEY(LongwallID) REFERENCES Longwall.BasicInfo(LongwallID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)
GO

-- CREATE MINE FACE
CREATE SCHEMA MineFace
GO

CREATE TABLE MineFace.BasicInfo(
	MineFaceID INT IDENTITY(1,1),
	MineFaceName NVARCHAR(30) UNIQUE NOT NULL,
	MineFaceLong INT NOT NULL CHECK(MineFaceLong > 0), -- dlugosc
	MineFaceThick INT NOT NULL CHECK(MineFaceThick > 0), -- wysokosc
	MineFaceSectionalArea INT NOT NULL CHECK(MineFaceSectionalArea > 0), -- pole przekroju
	MineFaceTimber INT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE DEFAULT NULL,
	PRIMARY KEY(MineFaceID),
	FOREIGN KEY(MineFaceTimber) REFERENCES Items(ItemID)
)
GO

CREATE TABLE MineFace.DailyRaport(
	RaportID INT IDENTITY(1,1),
	EmployeeID INT NOT NULL,
	MineFaceID INT NOT NULL,
	RaportDate DATE NOT NULL, -- data z godzina bo rozne odcinki
	TimberScaleInMeters INT NOT NULL CHECK(TimberScaleInMeters >= 0), -- podzialka m
	ExcavatedCoalQuantityInKg INT NOT NULL CHECK(ExcavatedCoalQuantityInKg >= 0), -- urobek kg
	MineFaceAdvanceInMeters INT NOT NULL CHECK(MineFaceAdvanceInMeters >= 0), -- postep m
	Comments NVARCHAR(MAX) DEFAULT NULL,
	PRIMARY KEY(RaportID),
	UNIQUE(RaportDate, MineFaceID),
	FOREIGN KEY(MineFaceID) REFERENCES MineFace.BasicInfo(MineFaceID),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID)
)
GO

CREATE TABLE MineFace.ActualWarehouseStatus(
	MineFaceID INT NOT NULL,
	ItemID INT NOT NULL,
	AvailableAmount INT NOT NULL,
	MinimumAmount INT NOT NULL,
	PRIMARY KEY(MineFaceID, ItemID),
	FOREIGN KEY(MineFaceID) REFERENCES MineFace.BasicInfo(MineFaceID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)
GO

CREATE TABLE MineFace.UsedResources(
	RaportID INT,
	ItemID INT NOT NULL,
	ItemUsedAmount INT NOT NULL CHECK(ItemUsedAmount > 0),
	PRIMARY KEY(RaportID, ItemID),
	FOREIGN KEY(RaportID) REFERENCES MineFace.DailyRaport(RaportID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)
GO

CREATE TABLE MineFace.ItemsOrder(
	MineFaceID INT NOT NULL,
	ItemID INT NOT NULL,
	OrderedItemAmount INT NOT NULL CHECK(OrderedItemAmount > 0),
	OrderDate DATE NOT NULL,
	PRIMARY KEY(MineFaceID, ItemID, OrderDate),
	FOREIGN KEY(MineFaceID) REFERENCES MineFace.BasicInfo(MineFaceID),
	FOREIGN KEY(ItemID) REFERENCES Items(ItemID)
)


-- CREATE EMPLOYEES DEPARTEMENT
CREATE TABLE Employees.EmployeeDepartement(
	ID INT IDENTITY(1,1),
	LongwallID INT,
	MineFaceID INT,
	EmployeeID INT NOT NULL,
	WorkStartDate DATE NOT NULL,
	WorkStopDate DATE DEFAULT NULL,
	PRIMARY KEY(ID),
	FOREIGN KEY(LongwallID) REFERENCES Longwall.BasicInfo(LongwallID),
	FOREIGN KEY(MineFaceID) REFERENCES MineFace.BasicInfo(MineFaceID),
	FOREIGN KEY(EmployeeID) REFERENCES Employees.BasicInfo(EmployeeID),
	CONSTRAINT CK_ValidateDate CHECK(WorkStartDate > WorkStopDate)
)
GO

-- CREATE SALES DEPARTAMENT
CREATE SCHEMA Sales
GO

CREATE TABLE Sales.CoalPileStatus( -- holda
	CoalPileID INT,
	LastModificationDATE DATE,
	CurrentCoalQuantity INT CHECK(CurrentCoalQuantity >= 0),
	PRIMARY KEY(CoalPileID)
)
GO 

CREATE TABLE Sales.Customers(
	CustomerID INT IDENTITY(1,1),
	CompanyName NVARCHAR(30),
	Telephone INT,
	City NVARCHAR(30),
	Adress NVARCHAR(30),
	PostalCode NVARCHAR(30),
	Country NVARCHAR(30),
	PRIMARY KEY(CustomerID)
)
GO

CREATE TABLE Sales.Orders(
	OrderID INT IDENTITY(1,1),
	OrderDate SMALLDATETIME  NOT NULL,
	RecipeDate SMALLDATETIME  DEFAULT NULL,
	CustomerID INT NOT NULL,
	QuantityInKg INT NOT NULL CHECK(QuantityInKg > 0),
	UnitPriceInZl money NOT NULL DEFAULT 100 CHECK(UnitPriceInZl >= 0),
	PRIMARY KEY(OrderID),
	FOREIGN KEY(CustomerID) REFERENCES Sales.Customers(CustomerID)
)
GO


-- //////////////// CREATE FUNCTIONS

CREATE FUNCTION Employees.IsEmployeeWithGivenIDExists(@EmployeeID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT FirstName FROM Employees.BasicInfo WHERE EmployeeID = @EmployeeID)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

-- sprawdza czy pracownik o danym ID jest na urlopie
CREATE FUNCTION Employees.IsEmployeeAtVacation(@EmployeeID INT)
RETURNS BIT
BEGIN
	DECLARE @EmployeeVacationDate AS DATE

	SET @EmployeeVacationDate = (SELECT MAX(EndDate)
			FROM Employees.Vacation
			WHERE EmployeeID = @EmployeeID)
	
	IF @EmployeeVacationDATE IS NULL OR @EmployeeVacationDate < GETDATE()
	BEGIN
		RETURN 0
	END

	RETURN 1 
END
GO

CREATE FUNCTION Employees.IsEmployeeAtVacationWithGivenPeriod(@EmployeeID INT, @StartDate DATE, @EndDate DATE)
RETURNS BIT
BEGIN
	IF EXISTS((SELECT TOP(1) StartDate
			FROM Employees.Vacation
			WHERE EmployeeID = @EmployeeID AND
				(StartDate BETWEEN @StartDate AND @EndDate) AND
				(EndDate BETWEEN @StartDate AND @EndDate))
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

-- sprawdza czy pracownik jest na emeryturze
CREATE FUNCTION Employees.IsEmplyeeAtRetired(@EmployeeID INT)
RETURNS BIT
BEGIN
	DECLARE @EmployeeRetireDate AS DATE

	SET @EmployeeRetireDate = (SELECT DismissalDate
			FROM Employees.BasicInfo
			WHERE EmployeeID = @EmployeeID)
	
	IF @EmployeeRetireDate IS NULL OR @EmployeeRetireDate < GETDATE()
	BEGIN
		RETURN 0
	END

	RETURN 1 
END
GO

-- zwraca sume postêpu danej œciany w metrach
CREATE FUNCTION Longwall.SumOfWallAdvanceInMeters(@LongwallID INT)
RETURNS INT
BEGIN
	RETURN (SELECT SUM(WallAdvanceInMeters)
			FROM Longwall.DailyRaport
			WHERE LongwallID = @LongwallID)
END
GO

-- zwraca liczbe dni ruchu sciany
CREATE FUNCTION Longwall.DaysOfActivityOfLongwall(@LongwallID INT)
RETURNS INT
BEGIN
	DECLARE @StartDATE AS DATE
	DECLARE @EndDATE AS DATE

	SET @StartDATE = (SELECT StartDATE
			FROM Longwall.BasicInfo
			WHERE LongwallID = @LongwallID)

	SET @EndDATE = (SELECT EndDATE
			FROM Longwall.BasicInfo
			WHERE LongwallID = @LongwallID)

	IF @EndDATE IS NULL
	BEGIN
		SET @EndDATE = GETDATE()
	END

	RETURN DATEDIFF(dayofyear, @StartDATE, @EndDATE)
END
GO

-- zwraca sume urobku wegla danej œciany w kg
CREATE FUNCTION Longwall.SumOfExcavatedCoalQuantityInKg(@LongwallID INT)
RETURNS INT
BEGIN
	RETURN (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM Longwall.DailyRaport
			WHERE LongwallID = @LongwallID)
END
GO

-- zwraca sume postêpu danego chodnika w metrach
CREATE FUNCTION MineFace.SumOfMineFaceAdvanceInMeters(@MineFaceID INT)
RETURNS INT
BEGIN
	RETURN (SELECT SUM(MineFaceAdvanceInMeters)
			FROM MineFace.DailyRaport
			WHERE MineFaceID = @MineFaceID)
END
GO

-- zwraca sume urobku wegla danego chodnika w kg
CREATE FUNCTION MineFace.SumOfExcavatedCoalQuantityInKg(@MineFaceID INT)
RETURNS INT
BEGIN
	RETURN (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM MineFace.DailyRaport
			WHERE MineFaceID = @MineFaceID)
END
GO

-- zwraca liczbe dni drazenia chodnika
CREATE FUNCTION MineFace.DaysOfActivityOfMineFace(@MineFaceID INT)
RETURNS INT
BEGIN
	DECLARE @StartDATE AS DATE
	DECLARE @EndDATE AS DATE

	SET @StartDATE =(SELECT StartDATE
			FROM MineFace.BasicInfo
			WHERE MineFaceID = @MineFaceID)

	SET @EndDATE = (SELECT EndDATE
			FROM MineFace.BasicInfo
			WHERE MineFaceID = @MineFaceID)

	IF @EndDATE IS NULL
	BEGIN
		SET @EndDATE = GETDATE()
	END

	RETURN DATEDIFF(dayofyear, @StartDATE, @EndDATE)
END
GO

-- zwraca liczbe nagodzin danego pracowanika w danym okresie
CREATE FUNCTION Employees.EmployeeOvertime(@StartDate SMALLDATETIME, @EndDate SMALLDATETIME, @EmployeeID INT)
RETURNS INT
BEGIN
	DECLARE @SumOfHours AS INT

	SET @SumOfHours = (SELECT (SUM(DATEDIFF(hour, StartDate, EndDate) - 8))
			FROM Employees.WorkHours
			WHERE (EmployeeID = @EmployeeID AND
				(StartDate BETWEEN @StartDate AND @EndDate) AND
				(EndDate BETWEEN @StartDate AND @EndDate) AND
				DATEDIFF(hour, StartDate, EndDate) > 8))

	IF @SumOfHours IS NULL
	BEGIN
		RETURN 0
	END

	RETURN @SumOfHours
END
GO

-- zwraca liczbe przepracowanych godzin w danym okresie
CREATE FUNCTION Employees.EmployeeWorkHours(@StartDate SMALLDATETIME, @EndDate SMALLDATETIME, @EmployeeID INT)
RETURNS INT
BEGIN
	DECLARE @SumOfHours AS INT

	SET @SumOfHours = (SELECT SUM(DATEDIFF(hour, StartDate, EndDate))
			FROM Employees.WorkHours
			WHERE (EmployeeID = @EmployeeID AND
				(StartDate BETWEEN @StartDate AND @EndDate) AND
				(EndDate BETWEEN @StartDate AND @EndDate)) )

	IF @SumOfHours IS NULL
	BEGIN
		RETURN 0
	END

	RETURN @SumOfHours
END
GO

-- zwraca liczbe przepracowanych godzin od pocz¹tku pracy
CREATE FUNCTION Employees.EmployeeWorkHoursFromStart(@EmployeeID INT)
RETURNS INT
BEGIN
	DECLARE @SumOfHours AS INT

	SET @SumOfHours = (SELECT SUM(DATEDIFF(hour, StartDate, EndDate))
			FROM Employees.WorkHours
			WHERE (EmployeeID = @EmployeeID) )

	IF @SumOfHours IS NULL
	BEGIN
		RETURN 0
	END

	RETURN @SumOfHours
END
GO

-- zwraca liczbe dni nieobecnosci w pracy
CREATE FUNCTION Employees.EmployeeVacationDays(@EmployeeID INT)
RETURNS INT
BEGIN
	DECLARE @SumOfDays AS INT

	SET @SumOfDays = (SELECT SUM(DATEDIFF(day, StartDate, EndDate))
			FROM Employees.Vacation
			WHERE EmployeeID = @EmployeeID)

	IF @SumOfDays IS NULL
	BEGIN
		RETURN 0
	END

	RETURN @SumOfDays
END
GO

-- zwraca iloœæ wydobytego wêgla od poczatku istnienia kopalni w kilogramach
CREATE FUNCTION Sales.AllTimeExcavatedCoalQuantityInKg()
RETURNS INT
BEGIN
	DECLARE @CoalSumFromLongwalls AS INT
	DECLARE @CoalSumFromMineface AS INT

	SET @CoalSumFromLongwalls = (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM Longwall.DailyRaport)

	SET @CoalSumFromMineface = (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM MineFace.DailyRaport)
	
	IF @CoalSumFromLongwalls IS NULL
	BEGIN
		SET @CoalSumFromLongwalls = 0
	END

	IF @CoalSumFromMineface IS NULL
	BEGIN
		SET @CoalSumFromMineface = 0
	END

	RETURN (@CoalSumFromLongwalls + @CoalSumFromMineface) 
END
GO

-- zwraca iloœæ wydobytego wêgla w danym okresie istnienia kopalni w kilogramach
CREATE FUNCTION Sales.ExcavatedCoalQuantityInKg(@StartDATE DATE, @EndDATE DATE)
RETURNS INT
BEGIN
	DECLARE @CoalSumFromLongwalls AS INT
	DECLARE @CoalSumFromMineface AS INT
	DECLARE @returnSum AS INT

	SET @CoalSumFromLongwalls = (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM Longwall.DailyRaport
			WHERE (RaportDATE BETWEEN @StartDATE AND @EndDATE))

	SET @CoalSumFromMineface = (SELECT SUM(ExcavatedCoalQuantityInKg)
			FROM MineFace.DailyRaport
			WHERE (RaportDATE BETWEEN @StartDATE AND @EndDATE))

	IF @CoalSumFromLongwalls IS NULL
	BEGIN
		SET @CoalSumFromLongwalls = 0
	END

	IF @CoalSumFromMineface IS NULL
	BEGIN
		SET @CoalSumFromMineface = 0
	END

	SET @returnSum = (@CoalSumFromLongwalls + @CoalSumFromMineface)

	RETURN @returnSum  
END
GO

-- zwraca ilosc oczekujacych zamowien
CREATE FUNCTION Sales.NumberOfUnrealizedOrders()
RETURNS INT
BEGIN
	RETURN (SELECT COUNT(*) FROM Sales.Orders WHERE RecipeDate IS NULL)
END
GO

-- zwraca ilosc wegla i pieniedzy z niezrealizowanych zamowien w kilogramach
CREATE FUNCTION Sales.QuantityAndMoneyOfCoalFromUnrealizedOrders()
RETURNS @returnTable TABLE(
		QuanitityOfCoalInKg INT,
		MoneyFromOrdersInZl MONEY
	)
BEGIN
	INSERT INTO @returnTable
		SELECT SUM(QuantityInKg), SUM(QuantityInKg * UnitPriceInZl) FROM Sales.Orders
		WHERE RecipeDATE IS NULL

	RETURN
END
GO

CREATE FUNCTION Sales.GetLastUnrealizedOrderIdAndQuantity()
RETURNS @returnTable TABLE(
		OrderID INT,
		QuanitityOfCoalInKg INT
	)
BEGIN
	DECLARE @OrderID INT
	DECLARE @Quantity INT

	SELECT TOP(1) @OrderID = OrderID, @Quantity = QuantityInKg
				FROM Sales.Orders
				WHERE RecipeDATE IS NULL 
				ORDER BY OrderDATE ASC

	IF @OrderID IS NOT NULL
	BEGIN
		INSERT INTO @returnTable VALUES(@OrderID, @Quantity)
	END
	ELSE
	BEGIN
		INSERT INTO @returnTable VALUES(NULL, NULL)
	END

	RETURN
END
GO

CREATE FUNCTION Employees.IsPeselContainsOnlyDigits(@PESEL NVARCHAR(11))
RETURNS BIT
BEGIN
	IF EXISTS(SELECT 1 WHERE @PESEL NOT LIKE '%[^0-9]%')
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Employees.IsPeselChecksumValid(@PESEL NVARCHAR(11))
RETURNS BIT
BEGIN
	DECLARE @a INT = CAST(SUBSTRING(@PESEL, 1, 1) AS INT)
	DECLARE @b INT = CAST(SUBSTRING(@PESEL, 2, 1) AS INT)
	DECLARE @c INT = CAST(SUBSTRING(@PESEL, 3, 1) AS INT)
	DECLARE @d INT = CAST(SUBSTRING(@PESEL, 4, 1) AS INT)
	DECLARE @e INT = CAST(SUBSTRING(@PESEL, 5, 1) AS INT)
	DECLARE @f INT = CAST(SUBSTRING(@PESEL, 6, 1) AS INT)
	DECLARE @g INT = CAST(SUBSTRING(@PESEL, 7, 1) AS INT)
	DECLARE @h INT = CAST(SUBSTRING(@PESEL, 8, 1) AS INT)
	DECLARE @i INT = CAST(SUBSTRING(@PESEL, 9, 1) AS INT)
	DECLARE @j INT = CAST(SUBSTRING(@PESEL, 10, 1) AS INT)
	DECLARE @k INT = CAST(SUBSTRING(@PESEL, 11, 1) AS INT)

	DECLARE @checksum INT = @a + 3 * @b + 7 * @c + 9 * @d + @e + 3 * @f + 7 * @g + 9 * @h + @i + 3 * @j + @k

	IF @checksum % 10 = 0
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Employees.GetGenderFromPesel(@PESEL NVARCHAR(11))
RETURNS NVARCHAR(1)
BEGIN
	IF CAST(SUBSTRING(@PESEL, 10, 1 ) AS INT) % 2 = 0
	BEGIN
		RETURN 'F'
	END

	RETURN 'M'
END
GO

CREATE FUNCTION Employees.IsPositionWithGivenIDExists(@PositionID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT PositionID FROM Employees.Positions WHERE PositionID = @PositionID)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Longwall.IsLongwallWithGivenIdExists(@LongwallID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT TOP(1) LongwallName
				FROM Longwall.BasicInfo
				WHERE LongwallID = @LongwallID			
		)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION MineFace.IsMineFaceWithGivenIdExists(@MinefaceID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT TOP(1) MineFaceName
				FROM MineFace.BasicInfo
				WHERE MineFaceID = @MinefaceID			
		)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Longwall.GetLongwallStartDate(@LongwallID INT)
RETURNS DATE
BEGIN
	RETURN (SELECT StartDate FROM Longwall.BasicInfo WHERE LongwallID = @LongwallID)
END
GO

CREATE FUNCTION Mineface.GetMineFaceStartDate(@MineFaceID INT)
RETURNS DATE
BEGIN
	RETURN (SELECT StartDate FROM MineFace.BasicInfo WHERE MineFaceID = @MineFaceID)
END
GO


CREATE FUNCTION Longwall.IsLongwallWithGivenDateWorks(@LongwallID INT, @Date DATE)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT StartDate 
				FROM Longwall.BasicInfo 
				WHERE LongwallID = @LongwallID AND 
					StartDate <= @Date AND 
					(EndDate >= @Date OR EndDate IS NULL)
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION MineFace.IsMineFaceWithGivenDateWorks(@MinefaceID INT, @Date DATE)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT StartDate 
				FROM MineFace.BasicInfo 
				WHERE MineFaceID = @MinefaceID AND 
					StartDate <= @Date AND 
					(EndDate >= @Date OR EndDate IS NULL)
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Longwall.IsRaportWithGivenIdExists(@RaportID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT RaportID 
				FROM Longwall.DailyRaport
				WHERE RaportID = @RaportID
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION MineFace.IsRaportWithGivenIdExists(@RaportID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT RaportID 
				FROM MineFace.DailyRaport
				WHERE RaportID = @RaportID
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Longwall.GetLongwallIdFromRaport(@RaportID INT)
RETURNS INT
BEGIN
	RETURN (SELECT TOP(1) LongwallID FROM Longwall.DailyRaport WHERE RaportID = @RaportID)
END
GO

CREATE FUNCTION MineFace.GetMineFaceIdFromRaport(@RaportID INT)
RETURNS INT
BEGIN
	RETURN (SELECT TOP(1) MineFaceID FROM MineFace.DailyRaport WHERE RaportID = @RaportID)
END
GO

CREATE FUNCTION Longwall.IsRaportWithGivenIdLastOne(@RaportID INT)
RETURNS BIT
BEGIN
	DECLARE @LongwallID INT = Longwall.GetLongwallIdFromRaport(@RaportID)

	IF (SELECT TOP(1) RaportID 
			FROM Longwall.DailyRaport
			WHERE LongwallID = @LongwallID
			ORDER BY RaportDATE
		) = @RaportID
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Mineface.IsRaportWithGivenIdLastOne(@RaportID INT)
RETURNS BIT
BEGIN
	DECLARE @MinefaceID INT = Mineface.GetLongwallIdFromRaport(@RaportID)

	IF (SELECT TOP(1) RaportID 
			FROM MineFace.DailyRaport
			WHERE MineFaceID = @MinefaceID
			ORDER BY RaportDATE
		) = @RaportID
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION IsItemWithGivenIdExists(@ItemID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT ItemID 
				FROM Items
				WHERE ItemID = @ItemID
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Longwall.IsItemAvaibleAtLongwallWarehouse(@ItemID INT, @LongwallID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT ItemID 
				FROM Longwall.ActualWarehouseStatus
				WHERE ItemID = @ItemID AND
					LongwallID = @LongwallID
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION MineFace.IsItemAvaibleAtLongwallWarehouse(@ItemID INT, @MinefaceID INT)
RETURNS BIT
BEGIN
	IF EXISTS(SELECT ItemID 
				FROM MineFace.ActualWarehouseStatus
				WHERE ItemID = @ItemID AND
					MineFaceID = @MinefaceID
			)
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO

CREATE FUNCTION Employees.GetLastWorkDepartmentId(@EmployeeID INT)
RETURNS INT
BEGIN
	RETURN (SELECT TOP(1) ID 
				FROM Employees.EmployeeDepartement
				WHERE EmployeeID = @EmployeeID AND
					WorkStopDATE IS NOT NULL
				ORDER BY WorkStartDATE
			)
END
GO


-- //////////////// CREATE PROCEDURES

--EMPLOYEES
CREATE PROCEDURE Employees.GetBirthDateFromPesel
	@PESEL NVARCHAR(11),
	@BirthDate DATE OUTPUT
AS
BEGIN
	DECLARE @PeselYearPart INT = CAST(SUBSTRING(@PESEL, 1, 2) AS INT)
	DECLARE @PeselMonthPart INT = CAST(SUBSTRING(@PESEL, 3, 2) AS INT)
	DECLARE @PeselDayPart INT = CAST(SUBSTRING(@PESEL, 5, 2) AS INT)

	IF @PeselDayPart > 31
	BEGIN
		;THROW 50005, 'Birth day is incorrect!', 1
	END

	DECLARE @Period INT = @PeselMonthPart / 20
	DECLARE @BirthMonth INT = @PeselMonthPart % 20

	IF @BirthMonth > 12 OR @BirthMonth = 0
	BEGIN
		;THROW 50006, 'Birth month is incorrect!', 1 
	END

	DECLARE @BirthYear INT

	IF @Period < 4
	BEGIN
		SET @BirthYear = 1900 + 100 * @Period + @PeselYearPart
	END
	ELSE --@Period == 4
	BEGIN
		SET @BirthYear = 1800 + @PeselYearPart
	END

	SET @BirthDATE =  CAST(
				CAST(@BirthYear AS VARCHAR(4)) + 
				RIGHT('0' + CAST(@BirthMonth AS VARCHAR(2)), 2) +
				RIGHT('0' + CAST(@PeselDayPart AS VARCHAR(2)), 2)
			AS DATE)
END
GO

CREATE PROCEDURE Employees.AddEmployee
	@PositionID INT,
	@FirstName NVARCHAR(30),
	@Surname NVARCHAR(30),
	@PESEL NVARCHAR(11),
	@TelephoneNumber INT,
	@HireDATE DATE
AS
BEGIN
	IF Employees.IsPositionWithGivenIDExists(@PositionID) = 'false'
	BEGIN
		;Throw 50007, 'Position with given PositionID doesn''t exists', 1
	END

	IF @FirstName IS NULL OR @FirstName = ''
	BEGIN
		;THROW 50000, 'Firstname can''t be empty!', 1
	END

	IF @Surname IS NULL OR @Surname = ''
	BEGIN
		;THROW 50001, 'Surname can''t be empty!', 1
	END

	IF LEN(@PESEL) != 11
	BEGIN
		;THROW 50002, 'Pesel has to be 11 numnber length!', 1
	END

	IF Employees.IsPeselContainsOnlyDigits(@PESEL) = 'false'
	BEGIN
		;THROW 50003, 'Pesel can contains only digits!', 1
	END

	IF Employees.IsPeselChecksumValid(@PESEL) = 'false'
	BEGIN
		;THROW 50004, 'Pesel doesn''t have valid checksum!', 1
	END

	DECLARE @Gender NVARCHAR(1) =  Employees.GetGenderFromPesel(@PESEL)

	DECLARE @BirthDATE DATE

	BEGIN TRY
		EXEC Employees.GetBirthDATEFromPesel @PESEL, @BirthDATE OUTPUT
	END TRY

	BEGIN CATCH
		;THROW
	END CATCH

	INSERT INTO Employees.BasicInfo
		VALUES(@PositionID, @FirstName, @Surname, @Gender, @PESEL, @TelephoneNumber, @BirthDATE, @HireDATE, DEFAULT)
END
GO

CREATE PROCEDURE Employees.AddEmployeeVacation
	@EmployeeID INT,
	@StartDATE DATE,
	@EndDATE DATE
AS
BEGIN
	IF @StartDATE < @EndDATE
	BEGIN
		;THROW 50010, 'Incorrect dates!', 1
	END

	IF Employees.IsEmployeeWithGivenIDExists(@EmployeeID) = 'false'
	BEGIN
		;THROW 50009, 'Employee with given ID doesn''t exists!', 1
	END

	IF Employees.IsEmployeeAtVacationWithGivenPeriod(@EmployeeID, @StartDATE, @EndDATE) = 'true'
	BEGIN
		;THROW 50008, 'Employee already has vacation at this period!', 1
	END

	INSERT INTO Employees.Vacation
		VALUES(@EmployeeID, @StartDATE, @EndDATE)
END
GO

--LONGWALL
CREATE PROCEDURE Longwall.AddLongwall
	@LongwallName NVARCHAR(30),
	@LongwallLong INT,
	@LongwallWide INT,
	@LongwallThick INT,
	@StartDATE DATE
AS
BEGIN
	IF @LongwallName IS NULL OR @LongwallName = ''
	BEGIN
		;THROW 50010, 'Longwall name can''t be empty!', 1
	END

	IF @LongwallLong <= 0 OR @LongwallThick <= 0 OR @LongwallWide <= 0
	BEGIN
		;THROW 50011, 'The dimensions of the longwall must be positive!', 1
	END

	INSERT INTO Longwall.BasicInfo
		VALUES(@LongwallName, @LongwallLong, @LongwallWide, @LongwallThick, @StartDATE, DEFAULT)
END
GO

CREATE PROCEDURE MineFace.AddMineface
	@MinefaceName NVARCHAR(30),
	@MineFaceLong INT,
	@MineFaceThick INT,
	@MineFaceSectionalArea INT,
	@MineFaceTimber INT,
	@StartDATE DATE
AS
BEGIN
	IF @MinefaceName IS NULL OR @MinefaceName = ''
	BEGIN
		;THROW 50010, 'Mineface name can''t be empty!', 1
	END

	IF @MineFaceLong <= 0 OR @MineFaceThick <= 0 OR @MineFaceSectionalArea <= 0 OR @MineFaceTimber <= 0
	BEGIN
		;THROW 50011, 'The dimensions of the Mineface must be positive!', 1
	END

	INSERT INTO MineFace.BasicInfo
		VALUES(@MinefaceName, @MineFaceLong, @MineFaceThick, @MineFaceSectionalArea, @MineFaceTimber, @StartDATE, DEFAULT)
END
GO

CREATE PROCEDURE Longwall.CloseLongwall
	@LongwallID INT,
	@LongwallEndDATE DATE
AS
BEGIN
	IF Longwall.IsLongwallWithGivenIdExists(@LongwallID) = 'false'
	BEGIN
		;THROW 50012, 'Longwall with given id doesn''t exists!', 1
	END

	IF Longwall.GetLongwallStartDATE(@LongwallID) > @LongwallEndDATE
	BEGIN
		;THROW 50013, 'End date is incorrect!', 1
	END

	UPDATE Longwall.BasicInfo SET EndDATE = @LongwallEndDATE WHERE LongwallID = @LongwallID
END
GO

CREATE PROCEDURE Mineface.CloseMineface
	@MinefaceID INT,
	@MinefaceEndDATE DATE
AS
BEGIN
	IF MineFace.IsMineFaceWithGivenIdExists(@MinefaceID) = 'false'
	BEGIN
		;THROW 50012, 'Mineface with given id doesn''t exists!', 1
	END

	IF MineFace.GetMineFaceStartDate(@MinefaceID) > @MinefaceEndDATE
	BEGIN
		;THROW 50013, 'End date is incorrect!', 1
	END

	UPDATE MineFace.BasicInfo SET EndDATE = @MinefaceEndDATE WHERE @MinefaceID = @MinefaceID
END
GO

CREATE PROCEDURE Longwall.AddDailyRaport
	@LongwallID INT,
	@EmployeeID INT,
	@ExcavatedCoalQuantityInKg INT,
	@WallAdvanceInMeters INT,
	@Comments VARCHAR(MAX) NULL
AS
BEGIN
	IF Longwall.IsLongwallWithGivenIdExists(@LongwallID) = 'false'
	BEGIN
		;THROW 50012, 'Longwall with given id doesn''t exists!', 1
	END

	IF Employees.IsEmployeeWithGivenIDExists(@EmployeeID) = 'false'
	BEGIN
		;THROW 50014, 'Employee with given id doesn''t exists!', 1
	END

	IF @ExcavatedCoalQuantityInKg < 0 OR @WallAdvanceInMeters < 0
	BEGIN
		;THROW 50015, 'The progression data of the longwall can''t be negative!', 1
	END

	IF Longwall.IsLongwallWithGivenDATEWorks(@LongwallID, GETDATE()) = 'false'
	BEGIN
		;THROW 50016, 'Longwall doesn''t work!', 1
	END

	INSERT INTO Longwall.DailyRaport
		VALUES(@EmployeeID, @LongwallID, GETDATE(), @ExcavatedCoalQuantityInKg, @WallAdvanceInMeters, @Comments)
END
GO

CREATE PROCEDURE Mineface.AddDailyRaport
	@MinefaceID INT,
	@EmployeeID INT,
	@TimberScaleInMeters INT,
	@ExcavatedCoalQuantityInKg INT,
	@MineFaceAdvanceInMeters INT,
	@Comments VARCHAR(MAX) NULL
AS
BEGIN
	IF MineFace.IsMineFaceWithGivenIdExists(@MinefaceID) = 'false'
	BEGIN
		;THROW 50012, 'Mineface with given id doesn''t exists!', 1
	END

	IF Employees.IsEmployeeWithGivenIDExists(@EmployeeID) = 'false'
	BEGIN
		;THROW 50014, 'Employee with given id doesn''t exists!', 1
	END

	IF @ExcavatedCoalQuantityInKg < 0 OR @MineFaceAdvanceInMeters < 0
	BEGIN
		;THROW 50015, 'The progression data of the longwall can''t be negative!', 1
	END

	IF MineFace.IsMineFaceWithGivenDateWorks(@MinefaceID, GETDATE()) = 'false'
	BEGIN
		;THROW 50016, 'Longwall doesn''t work!', 1
	END

	IF @TimberScaleInMeters <= 0
	BEGIN
		;THROW 50017, 'Timber scale has to positive!', 1
	END

	INSERT INTO Mineface.DailyRaport
		VALUES(@EmployeeID, @MinefaceID, GETDATE(), @TimberScaleInMeters, @ExcavatedCoalQuantityInKg, @MineFaceAdvanceInMeters, @Comments)
END
GO

CREATE PROCEDURE Longwall.AddUsedResource
	@RaportID INT,
	@ItemID INT,
	@ItemUsedAmount INT
AS
BEGIN
	IF @ItemUsedAmount <= 0
	BEGIN
		;THROW 50015, 'You cannot add used reosurce with used amount <= 0!', 1
	END

	IF Longwall.IsRaportWithGivenIdLastOne(@RaportID) = 'false'
	BEGIN
		;THROW 50014, 'This raport is not the last one!', 1
	END

	BEGIN TRAN T1
		BEGIN TRY
			INSERT INTO Longwall.UsedResources VALUES (@RaportID, @ItemID, @ItemUsedAmount)
		END TRY

		BEGIN CATCH

			ROLLBACK TRAN T1
			;THROW
		END CATCH

	COMMIT TRAN T1
END
GO

CREATE PROCEDURE Mineface.AddUsedResource
	@RaportID INT,
	@ItemID INT,
	@ItemUsedAmount INT
AS
BEGIN
	IF @ItemUsedAmount <= 0
	BEGIN
		;THROW 50015, 'You cannot add used reosurce with used amount <= 0!', 1
	END

	IF MineFace.IsRaportWithGivenIdLastOne(@RaportID) = 'false'
	BEGIN
		;THROW 50014, 'This raport is not the last one!', 1
	END

	BEGIN TRAN T1
		BEGIN TRY
			INSERT INTO MineFace.UsedResources VALUES (@RaportID, @ItemID, @ItemUsedAmount)
		END TRY

		BEGIN CATCH

			ROLLBACK TRAN T1
			;THROW
		END CATCH

	COMMIT TRAN T1
END
GO

CREATE PROCEDURE Sales.AddOrder
	@CustomerID INT,
	@QuantityInKg INT,
	@UnitPriceZl MONEY = 100
AS
BEGIN
	BEGIN TRAN T1

		BEGIN TRY
			INSERT INTO Sales.Orders VALUES (GETDATE(), NULL, @CustomerID, @QuantityInKg, @UnitPriceZl)
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN T1
			;THROW
		END CATCH

	COMMIT TRAN T1
END
GO

CREATE PROCEDURE Employees.AddEmployeeDepartement
	@EmployeeID INT,
	@LongwallID INT,
	@MineFaceID INT,
	@StartDATE DATE
AS
BEGIN
	IF (@LongwallID IS NOT NULL AND @MineFaceID IS NOT NULL) OR
		(@LongwallID IS NULL AND @MineFaceID IS NULL)
	BEGIN
		;THROW 50020, 'Incorrect department!', 1
	END

	DECLARE @ID INT = Employees.GetLastWorkDepartmentId(@EmployeeID)

	BEGIN TRAN AddEmployeeDepartement
		BEGIN TRY
			INSERT INTO Employees.EmployeeDepartement VALUES(@LongwallID, @MineFaceID, @EmployeeID, @StartDATE, NULL)
			UPDATE Employees.EmployeeDepartement SET WorkStopDATE = @StartDATE WHERE ID = @ID
		END TRY

		BEGIN CATCH
			ROLLBACK
			;THROW
		END CATCH

	COMMIT
END
GO


-- //////////////// CREATE TRIGGERS

CREATE TRIGGER Longwall.t_UpDateWarhouseStatus
	ON Longwall.UsedResources
AFTER INSERT
AS
BEGIN
	DECLARE @RaportID INT = (SELECT TOP(1) RaportID FROM INSERTED)
	DECLARE @UsedAmount INT = (SELECT TOP(1) ItemUsedAmount FROM INSERTED)
	DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)

	DECLARE @LongwallID INT = Longwall.GetLongwallIdFromRaport(@RaportID)

	BEGIN TRY
		UPDATE Longwall.ActualWarehouseStatus SET AvailableAmount = AvailableAmount - @UsedAmount
			WHERE LongwallID = @LongwallID AND ItemID = @ItemID
	END TRY

	BEGIN CATCH
		;THROW
	END CATCH
END
GO

CREATE TRIGGER MineFace.t_UpDateWarhouseStatus
	ON Mineface.UsedResources
AFTER INSERT
AS
BEGIN
	DECLARE @RaportID INT = (SELECT TOP(1) RaportID FROM INSERTED)
	DECLARE @UsedAmount INT = (SELECT TOP(1) ItemUsedAmount FROM INSERTED)
	DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)

	DECLARE @MinefaceID INT = Mineface.GetMineFaceIdFromRaport(@RaportID)

	BEGIN TRY
		UPDATE MineFace.ActualWarehouseStatus SET AvailableAmount = AvailableAmount - @UsedAmount
			WHERE MineFaceID = @MinefaceID AND ItemID = @ItemID
	END TRY

	BEGIN CATCH
		;THROW
	END CATCH
END
GO

CREATE TRIGGER Longwall.t_OrderItem
	ON Longwall.ActualWarehouseStatus
AFTER UPDATE
AS
BEGIN
	DECLARE @AvaibleAmount INT = (SELECT TOP(1) AvailableAmount FROM INSERTED)
	DECLARE @MinimumAmount INT = (SELECT TOP(1) MinimumAmount FROM INSERTED)
	DECLARE @DeletedAmount INT = (SELECT TOP(1) AvailableAmount FROM DELETED)

	IF @DeletedAmount > @AvaibleAmount
		BEGIN
		BEGIN TRY
			IF @AvaibleAmount < @MinimumAmount
			BEGIN
				DECLARE @LongwallID INT = (SELECT TOP(1) LongwallID FROM INSERTED)
				DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)

				INSERT INTO Longwall.ItemsOrder VALUES (@LongwallID, @ItemID, (@MinimumAmount - @AvaibleAmount), GETDATE())
			END
		END TRY

		BEGIN CATCH
			;THROW
		END CATCH
	END
END
GO

CREATE TRIGGER Mineface.t_OrderItem
	ON Mineface.ActualWarehouseStatus
AFTER UPDATE
AS
BEGIN
	DECLARE @AvaibleAmount INT = (SELECT TOP(1) AvailableAmount FROM INSERTED)
	DECLARE @MinimumAmount INT = (SELECT TOP(1) MinimumAmount FROM INSERTED)
	DECLARE @DeletedAmount INT = (SELECT TOP(1) AvailableAmount FROM DELETED)

	IF @DeletedAmount > @AvaibleAmount
		BEGIN
		BEGIN TRY
			IF @AvaibleAmount < @MinimumAmount
			BEGIN
				DECLARE @minefaceID INT = (SELECT TOP(1) MineFaceID FROM INSERTED)
				DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)

				INSERT INTO MineFace.ItemsOrder VALUES (@minefaceID, @ItemID, (@MinimumAmount - @AvaibleAmount), GETDATE())
			END
		END TRY

		BEGIN CATCH
			;THROW
		END CATCH
	END
END
GO

CREATE TRIGGER Longwall.t_ItemDelivery
	ON Longwall.ItemsOrder
FOR INSERT
AS
BEGIN
	DECLARE @LongwallID INT = (SELECT TOP(1) LongwallID FROM INSERTED)
	DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)
	DECLARE @OrderedAmount INT = (SELECT TOP(1) OrderedItemAmount FROM INSERTED)

	BEGIN TRY
		UPDATE Longwall.ActualWarehouseStatus SET AvailableAmount = AvailableAmount + @OrderedAmount
			WHERE LongwallID = @LongwallID AND ItemID = @ItemID
	END TRY

	BEGIN CATCH
		;THROW
	END CATCH
END
GO

CREATE TRIGGER Mineface.t_ItemDelivery
	ON Mineface.ItemsOrder
FOR INSERT
AS
BEGIN
	DECLARE @MineFaceID INT = (SELECT TOP(1) MineFaceID FROM INSERTED)
	DECLARE @ItemID INT = (SELECT TOP(1) ItemID FROM INSERTED)
	DECLARE @OrderedAmount INT = (SELECT TOP(1) OrderedItemAmount FROM INSERTED)

	BEGIN TRY
		UPDATE Mineface.ActualWarehouseStatus SET AvailableAmount = AvailableAmount + @OrderedAmount
			WHERE MineFaceID = @MineFaceID AND ItemID = @ItemID
	END TRY

	BEGIN CATCH
		;THROW
	END CATCH
END
GO

CREATE TRIGGER Longwall.t_AddExcavatedCoalAtCoalPile
	ON Longwall.DailyRaport
AFTER INSERT
AS
BEGIN
	DECLARE @AddedCoal INT = (SELECT TOP(1) ExcavatedCoalQuantityInKg FROM INSERTED)

	BEGIN TRY
		UPDATE Sales.CoalPileStatus SET LastModificationDATE = GETDATE(), CurrentCoalQuantity = CurrentCoalQuantity + @AddedCoal WHERE CoalPileID = 1
	END TRY

	BEGIN CATCH
		;Throw		
	END CATCH
END
GO

CREATE TRIGGER Mineface.t_AddExcavatedCoalAtCoalPile
	ON Mineface.DailyRaport
AFTER INSERT
AS
BEGIN
	DECLARE @AddedCoal INT = (SELECT TOP(1) ExcavatedCoalQuantityInKg FROM INSERTED)

	BEGIN TRY
		UPDATE Sales.CoalPileStatus SET LastModificationDATE = GETDATE(), CurrentCoalQuantity = CurrentCoalQuantity + @AddedCoal WHERE CoalPileID = 1
	END TRY

	BEGIN CATCH
		;Throw		
	END CATCH
END
GO

CREATE TRIGGER Sales.t_RealizePendingOrder
	ON Sales.CoalPileStatus
AFTER UPDATE 
AS
BEGIN
	DECLARE @OrderID INT
	DECLARE @OrderQuantity INT

	SELECT @OrderID = OrderID, @OrderQuantity = QuanitityOfCoalInKg FROM Sales.GetLastUnrealizedOrderIdAndQuantity()

	DECLARE @CurrentCoalQuantity INT = (SELECT TOP(1) CurrentCoalQuantity FROM INSERTED)

	WHILE @OrderID IS NOT NULL
	BEGIN
		IF @CurrentCoalQuantity >= @OrderQuantity
		BEGIN
			BEGIN TRAN T1
				UPDATE Sales.Orders SET RecipeDATE = GETDATE() WHERE OrderID = @OrderID
				UPDATE Sales.CoalPileStatus SET LastModificationDATE = GETDATE(), CurrentCoalQuantity = CurrentCoalQuantity - @OrderQuantity WHERE CoalPileID = 1 
			COMMIT TRAN T1

			SELECT @OrderID = OrderID, @OrderQuantity = QuanitityOfCoalInKg FROM Sales.GetLastUnrealizedOrderIdAndQuantity()
			SET @CurrentCoalQuantity = (SELECT CurrentCoalQuantity FROM Sales.CoalPileStatus)
		END
		ELSE
		BEGIN
			SET @OrderID = NULL 
		END
	END
END
GO

CREATE TRIGGER Sales.t_RealizeOrder
	ON Sales.Orders
FOR INSERT
AS
BEGIN
	DECLARE @OrderID INT

	SELECT @OrderID = OrderID FROM Sales.GetLastUnrealizedOrderIdAndQuantity()

	IF @OrderID IS NULL OR @OrderID = (SELECT TOP(1) OrderID FROM INSERTED)
	BEGIN
		DECLARE @CurrentCoalQuantity INT = (SELECT CurrentCoalQuantity FROM Sales.CoalPileStatus WHERE CoalPileID = 1)
		DECLARE @OrderQuantity INT = (SELECT TOP(1) QuantityInKg FROM INSERTED)

		IF @CurrentCoalQuantity >= @OrderQuantity
		BEGIN
			UPDATE Sales.Orders SET RecipeDATE = GETDATE() WHERE OrderID = @OrderID
			UPDATE Sales.CoalPileStatus SET LastModificationDATE = GETDATE(), CurrentCoalQuantity = CurrentCoalQuantity - @OrderQuantity WHERE CoalPileID = 1 
		END
	END
END