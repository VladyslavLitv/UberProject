INSERT INTO dbo.Users (Name, Email, Phone, AvgRating)
VALUES 
(N'Ivan Petrov',  N'ivan@example.com', '+359888111222', 4.80),
(N'Maria Dimitrova', N'maria@example.com', '+359888333444', 4.95),
(N'Georgi Stoyanov', N'georgi@example.com', '+359888555666', 4.60);

INSERT INTO dbo.Passengers (PassengerID, PaymentMethod)
VALUES (2, N'card');

INSERT INTO dbo.Drivers (DriverID, LicenseNumber, DriverStatus)
VALUES (1, N'BG1234567', N'online');

INSERT INTO dbo.Vehicles (DriverID, Model, VehicleClass, ManufacturedYear)
VALUES 
(1, N'Toyota Prius', N'Economy', 2018);

INSERT INTO dbo.Locations (Address)
VALUES 
(N'Plovdiv Center'),
(N'Plovdiv Mall');

INSERT INTO dbo.Rides
(PassengerID, DriverID, StartLocationID, EndLocationID, Fare, RideStatus, StartTime, EndTime, RequestedAt)
VALUES
(2, 1, 1, 2, 12.50, N'accepted', SYSDATETIME(), NULL, SYSDATETIME());

INSERT INTO dbo.Promotions (Code, DiscountType, DiscountValue, ValidPeriod)
VALUES
(N'WELCOME10', N'percent', 10, N'2025'),
(N'FIXED5', N'fixed', 5, N'2025');

SELECT * FROM dbo.Rides;

INSERT INTO dbo.RidePromotions (RideID, PromoID)
VALUES
(1, 1),   -- WELCOME10
(1, 2);   -- FIXED5

INSERT INTO dbo.Payments (RideID, Amount, PaymentMethod, PaymentStatus)
VALUES
(1, 12.50, N'card', N'paid');

SELECT * FROM dbo.Rides WHERE RideID = 1;