USE UberDWH;
GO

INSERT INTO dbo.DimDate (
    DateKey, FullDate, Day, Month, MonthName, Year, DayOfWeek, DayName
)
SELECT DISTINCT
    CONVERT(INT, CONVERT(CHAR(8), d, 112))              AS DateKey,  -- YYYYMMDD
    d                                                   AS FullDate,
    DATEPART(DAY,   d)                                  AS [Day],
    DATEPART(MONTH, d)                                  AS [Month],
    DATENAME(MONTH, d)                                  AS MonthName,
    DATEPART(YEAR,  d)                                  AS [Year],
    DATEPART(WEEKDAY, d)                                AS DayOfWeek,
    DATENAME(WEEKDAY, d)                                AS DayName
FROM (
    SELECT CONVERT(DATE, RequestedAt) AS d
    FROM   UberCoursework.dbo.Rides
    UNION
    SELECT CONVERT(DATE, StartTime) 
    FROM   UberCoursework.dbo.Rides
    WHERE  StartTime IS NOT NULL
    UNION
    SELECT CONVERT(DATE, EndTime)
    FROM   UberCoursework.dbo.Rides
    WHERE  EndTime IS NOT NULL
    UNION
    SELECT CONVERT(DATE, COALESCE(PaidAt, RequestedAt))
    FROM   UberCoursework.dbo.Payments p
    JOIN   UberCoursework.dbo.Rides r ON p.RideID = r.RideID
) AS src
WHERE d IS NOT NULL;
GO

INSERT INTO dbo.DimPassenger (PassengerID, Name, Email, Phone, PaymentMethod)
SELECT 
    p.PassengerID,
    u.Name,
    u.Email,
    u.Phone,
    p.PaymentMethod
FROM UberCoursework.dbo.Passengers p
JOIN UberCoursework.dbo.Users u ON u.UserID = p.PassengerID;
GO

INSERT INTO dbo.DimDriver (DriverID, Name, Email, Phone, LicenseNumber, DriverStatus)
SELECT
    d.DriverID,
    u.Name,
    u.Email,
    u.Phone,
    d.LicenseNumber,
    d.DriverStatus
FROM UberCoursework.dbo.Drivers d
JOIN UberCoursework.dbo.Users u ON u.UserID = d.DriverID;
GO

INSERT INTO dbo.DimVehicle (VehicleID, DriverID, Model, VehicleClass, ManufacturedYear)
SELECT
    v.VehicleID,
    v.DriverID,
    v.Model,
    v.VehicleClass,
    v.ManufacturedYear
FROM UberCoursework.dbo.Vehicles v;
GO

INSERT INTO dbo.DimLocation (LocationID, Address)
SELECT
    l.LocationID,
    l.Address
FROM UberCoursework.dbo.Locations l;
GO

INSERT INTO dbo.DimPromotion (PromoID, Code, DiscountType, DiscountValue, ValidPeriod, IsActive)
SELECT
    p.PromoID,
    p.Code,
    p.DiscountType,
    p.DiscountValue,
    p.ValidPeriod,
    CAST(1 AS BIT) AS IsActive
FROM UberCoursework.dbo.Promotions p;
GO

INSERT INTO dbo.FactRides (
    RideID,
    RequestedDateKey,
    StartDateKey,
    EndDateKey,
    PassengerKey,
    DriverKey,
    VehicleKey,
    StartLocationKey,
    EndLocationKey,
    BaseFare,
    FinalFare,
    RideDurationMinutes,
    RideCount
)
SELECT
    r.RideID,

    -- RequestedDateKey
    CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.RequestedAt), 112)) AS RequestedDateKey,

    -- StartDateKey
    CASE 
        WHEN r.StartTime IS NOT NULL 
            THEN CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.StartTime), 112))
        ELSE NULL
    END AS StartDateKey,

    -- EndDateKey
    CASE 
        WHEN r.EndTime IS NOT NULL 
            THEN CONVERT(INT, CONVERT(CHAR(8), CONVERT(DATE, r.EndTime), 112))
        ELSE NULL
    END AS EndDateKey,

    dp.PassengerKey,
    dd.DriverKey,
    NULL AS VehicleKey,   -- можно позже связать через DriverID/VehicleID, сейчас оставим NULL

    dls.LocationKey AS StartLocationKey,
    dle.LocationKey AS EndLocationKey,

    r.Fare                    AS BaseFare,
    r.Fare                    AS FinalFare,  -- для простоты = BaseFare, без учёта промо
    CASE 
        WHEN r.StartTime IS NOT NULL AND r.EndTime IS NOT NULL 
            THEN DATEDIFF(MINUTE, r.StartTime, r.EndTime)
        ELSE NULL
    END AS RideDurationMinutes,
    1 AS RideCount
FROM UberCoursework.dbo.Rides r
JOIN dbo.DimPassenger dp ON dp.PassengerID = r.PassengerID
LEFT JOIN dbo.DimDriver dd ON dd.DriverID = r.DriverID
JOIN dbo.DimLocation dls ON dls.LocationID = r.StartLocationID
JOIN dbo.DimLocation dle ON dle.LocationID = r.EndLocationID;
GO

INSERT INTO dbo.FactPayments (
    PaymentID,
    RideKey,
    PaymentDateKey,
    Amount,
    PaymentStatus,
    PaymentMethod
)
SELECT
    p.PaymentID,
    fr.RideKey,

    CONVERT(INT, CONVERT(CHAR(8), 
        CONVERT(DATE, COALESCE(p.PaidAt, r.RequestedAt)), 112)) AS PaymentDateKey,

    p.Amount,
    p.PaymentStatus,
    p.PaymentMethod
FROM UberCoursework.dbo.Payments p
JOIN UberCoursework.dbo.Rides r ON r.RideID = p.RideID
JOIN dbo.FactRides fr ON fr.RideID = r.RideID;
GO

INSERT INTO dbo.FactRidePromotions (
    RideKey,
    PromotionKey,
    DiscountValueApplied,
    IsPercentFlag
)
SELECT
    fr.RideKey,
    dp.PromotionKey,
    pr.DiscountValue AS DiscountValueApplied,
    CASE WHEN pr.DiscountType = N'percent' THEN 1 ELSE 0 END AS IsPercentFlag
FROM UberCoursework.dbo.RidePromotions rp
JOIN UberCoursework.dbo.Rides r       ON r.RideID   = rp.RideID
JOIN UberCoursework.dbo.Promotions pr ON pr.PromoID = rp.PromoID
JOIN dbo.FactRides fr                 ON fr.RideID  = r.RideID
JOIN dbo.DimPromotion dp              ON dp.PromoID = pr.PromoID;
GO

INSERT INTO dbo.DimDate (DateKey, FullDate, Day, Month, MonthName, Year, DayOfWeek, DayName)
VALUES
(20250101, '2025-01-01', 1, 1, N'January', 2025, 3, N'Wednesday'),
(20250102, '2025-01-02', 2, 1, N'January', 2025, 4, N'Thursday'),
(20250103, '2025-01-03', 3, 1, N'January', 2025, 5, N'Friday'),
(20250104, '2025-01-04', 4, 1, N'January', 2025, 6, N'Saturday'),
(20250105, '2025-01-05', 5, 1, N'January', 2025, 7, N'Sunday'),
(20250106, '2025-01-06', 6, 1, N'January', 2025, 1, N'Monday'),
(20250107, '2025-01-07', 7, 1, N'January', 2025, 2, N'Tuesday'),
(20250108, '2025-01-08', 8, 1, N'January', 2025, 3, N'Wednesday'),
(20250109, '2025-01-09', 9, 1, N'January', 2025, 4, N'Thursday'),
(20250110, '2025-01-10', 10, 1, N'January', 2025, 5, N'Friday');

INSERT INTO dbo.DimPassenger (PassengerID, Name, Email, Phone, PaymentMethod)
VALUES
(1, N'Ivan Petrov',   N'ivan1@mail.com',   '+359888111111', N'card'),
(2, N'Maria Ivanova', N'maria@mail.com',   '+359888111112', N'cash'),
(3, N'Georgi Stoyanov',N'georgi@mail.com', '+359888111113', N'card'),
(4, N'Nikolay Borisov',N'nik@mail.com',    '+359888111114', N'card'),
(5, N'Petar Dimitrov', N'petar@mail.com',  '+359888111115', N'cash'),
(6, N'Kaloyan Iliev',  N'kal@mail.com',    '+359888111116', N'card'),
(7, N'Rosen Todorov',  N'rosen@mail.com',  '+359888111117', N'card'),
(8, N'Denis Hristov',  N'denis@mail.com',  '+359888111118', N'cash'),
(9, N'Stefan Marinov', N'stefan@mail.com', '+359888111119', N'card'),
(10,N'Alex Petkov',    N'alex@mail.com',   '+359888111120', N'card');

INSERT INTO dbo.DimDriver (DriverID, Name, Email, Phone, LicenseNumber, DriverStatus)
VALUES
(1, N'Driver One',   N'd1@mail.com', '+359888221001', N'BG11111', N'online'),
(2, N'Driver Two',   N'd2@mail.com', '+359888221002', N'BG22222', N'online'),
(3, N'Driver Three', N'd3@mail.com', '+359888221003', N'BG33333', N'offline'),
(4, N'Driver Four',  N'd4@mail.com', '+359888221004', N'BG44444', N'busy'),
(5, N'Driver Five',  N'd5@mail.com', '+359888221005', N'BG55555', N'online'),
(6, N'Driver Six',   N'd6@mail.com', '+359888221006', N'BG66666', N'offline'),
(7, N'Driver Seven', N'd7@mail.com', '+359888221007', N'BG77777', N'online'),
(8, N'Driver Eight', N'd8@mail.com', '+359888221008', N'BG88888', N'busy'),
(9, N'Driver Nine',  N'd9@mail.com', '+359888221009', N'BG99999', N'online'),
(10,N'Driver Ten',   N'd10@mail.com','+359888221010', N'BG10101', N'online');

INSERT INTO dbo.DimVehicle (VehicleID, DriverID, Model, VehicleClass, ManufacturedYear)
VALUES
(1, 1, N'Toyota Prius', N'Economy', 2018),
(2, 2, N'VW Passat',     N'Comfort', 2019),
(3, 3, N'Audi A6',       N'Premium', 2020),
(4, 4, N'Toyota Yaris',  N'Economy', 2017),
(5, 5, N'BMW X3',        N'Premium', 2021),
(6, 6, N'Hyundai i30',   N'Economy', 2019),
(7, 7, N'Mercedes C220', N'Comfort', 2018),
(8, 8, N'Kia Rio',       N'Economy', 2016),
(9, 9, N'Honda Civic',   N'Comfort', 2019),
(10,10,N'Tesla Model 3', N'Premium', 2022);

INSERT INTO dbo.DimLocation (LocationID, Address)
VALUES
(1, N'Plovdiv Center'),
(2, N'Plovdiv Old Town'),
(3, N'Plovdiv Mall'),
(4, N'Trakiya District'),
(5, N'Smoking District'),
(6, N'Kapana Center'),
(7, N'Plovdiv Station'),
(8, N'Karshiaka'),
(9, N'Marica Riverside'),
(10,N'Airport Plovdiv');

INSERT INTO dbo.DimPromotion (PromoID, Code, DiscountType, DiscountValue, ValidPeriod, IsActive)
VALUES
(1, N'WELCOME10', N'percent', 10, N'2025', 1),
(2, N'FIXED5',    N'fixed',    5, N'2025', 1),
(3, N'SPRING15',  N'percent', 15, N'2025', 1),
(4, N'SUMMER20',  N'percent', 20, N'2025', 1),
(5, N'WINTER7',   N'fixed',    7, N'2025', 1),
(6, N'VIP25',     N'percent', 25, N'2025', 1),
(7, N'PROMO3',    N'fixed',    3, N'2025', 0),
(8, N'FREE2',     N'fixed',    2, N'2025', 1),
(9, N'HOLIDAY12', N'percent', 12, N'2025', 1),
(10,N'DEAL50',    N'percent', 50, N'2025', 0);

INSERT INTO dbo.FactRides (
    RideID, RequestedDateKey, StartDateKey, EndDateKey,
    PassengerKey, DriverKey, VehicleKey,
    StartLocationKey, EndLocationKey,
    BaseFare, FinalFare, RideDurationMinutes, RideCount
)
VALUES
(1, 20250101, 20250101, 20250101, 1, 1, 1, 1, 2, 12.50, 10.50, 15, 1),
(2, 20250102, 20250102, 20250102, 2, 2, 2, 2, 3, 9.00, 9.00, 12, 1),
(3, 20250103, 20250103, 20250103, 3, 3, 3, 3, 4, 15.20, 10.20, 20, 1),
(4, 20250104, 20250104, 20250104, 4, 4, 4, 4, 5, 7.30, 7.30, 8, 1),
(5, 20250105, 20250105, 20250105, 5, 5, 5, 5, 6, 21.00, 16.00, 25, 1),
(6, 20250106, 20250106, 20250106, 6, 6, 6, 6, 7, 11.40, 11.40, 14, 1),
(7, 20250107, 20250107, 20250107, 7, 7, 7, 7, 8, 13.50, 10.00, 18, 1),
(8, 20250108, 20250108, 20250108, 8, 8, 8, 8, 9, 6.00,  6.00,  6,  1),
(9, 20250109, 20250109, 20250109, 9, 9, 9, 9, 10,14.00, 10.00, 22, 1),
(10,20250110, 20250110, 20250110,10,10,10,1, 3, 17.00, 8.50,  30, 1);


INSERT INTO dbo.FactPayments (
    PaymentID, RideKey, PaymentDateKey, Amount, PaymentStatus, PaymentMethod
)
VALUES
(1,1,20250101,10.50,N'paid',N'card'),
(2,2,20250102,9.00,N'paid',N'cash'),
(3,3,20250103,10.20,N'paid',N'card'),
(4,4,20250104,7.30,N'paid',N'card'),
(5,5,20250105,16.00,N'paid',N'cash'),
(6,6,20250106,11.40,N'paid',N'card'),
(7,7,20250107,10.00,N'paid',N'card'),
(8,8,20250108,6.00,N'paid',N'cash'),
(9,9,20250109,10.00,N'paid',N'card'),
(10,10,20250110,8.50,N'paid',N'card');

INSERT INTO dbo.FactRidePromotions (
    RideKey, PromotionKey, DiscountValueApplied, IsPercentFlag
)
VALUES
(1,1,10,1),
(2,2,5,0),
(3,3,15,1),
(4,4,20,1),
(5,5,7,0),
(6,6,25,1),
(7,7,3,0),
(8,8,2,0),
(9,9,12,1),
(10,10,50,1);


SELECT TOP 10 * FROM dbo.DimPassenger;
SELECT TOP 10 * FROM dbo.DimDriver;
SELECT TOP 10 * FROM dbo.DimLocation;
SELECT TOP 10 * FROM dbo.DimPromotion;
SELECT TOP 10 * FROM dbo.FactRides;
SELECT TOP 10 * FROM dbo.FactPayments;
SELECT TOP 10 * FROM dbo.FactRidePromotions;