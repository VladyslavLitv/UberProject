CREATE DATABASE UberDWH;
GO

USE UberDWH;
GO

CREATE TABLE dbo.DimDate (
    DateKey    INT          NOT NULL PRIMARY KEY, 
    FullDate   DATE         NOT NULL,
    Day        TINYINT      NOT NULL,
    Month      TINYINT      NOT NULL,
    MonthName  NVARCHAR(20) NOT NULL,
    Year       SMALLINT     NOT NULL,
    DayOfWeek  TINYINT      NOT NULL,
    DayName    NVARCHAR(20) NOT NULL
);
GO

CREATE TABLE dbo.DimPassenger (
    PassengerKey   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PassengerID    INT           NOT NULL,
    Name           NVARCHAR(100) NOT NULL,
    Email          NVARCHAR(255) NOT NULL,
    Phone          NVARCHAR(50)  NULL,
    PaymentMethod  NVARCHAR(50)  NULL
);
GO

CREATE TABLE dbo.DimDriver (
    DriverKey     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    DriverID      INT           NOT NULL,
    Name          NVARCHAR(100) NOT NULL,
    Email         NVARCHAR(255) NOT NULL,
    Phone         NVARCHAR(50)  NULL,
    LicenseNumber NVARCHAR(50)  NOT NULL,
    DriverStatus  NVARCHAR(20)  NOT NULL
);
GO

CREATE TABLE dbo.DimVehicle (
    VehicleKey       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    VehicleID        INT           NOT NULL,
    DriverID         INT           NOT NULL,
    Model            NVARCHAR(100) NOT NULL,
    VehicleClass     NVARCHAR(50)  NOT NULL,
    ManufacturedYear SMALLINT      NULL
);
GO

CREATE TABLE dbo.DimLocation (
    LocationKey INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    LocationID  INT            NOT NULL,
    Address     NVARCHAR(255)  NOT NULL
);
GO

CREATE TABLE dbo.DimPromotion (
    PromotionKey   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PromoID        INT           NOT NULL,
    Code           NVARCHAR(50)  NOT NULL,
    DiscountType   NVARCHAR(20)  NOT NULL,
    DiscountValue  DECIMAL(10,2) NOT NULL,
    ValidPeriod    NVARCHAR(50)  NULL,
    IsActive       BIT           NULL
);
GO

CREATE TABLE dbo.FactRides (
    RideKey            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- PK, SK
    RideID             INT           NOT NULL,

    RequestedDateKey   INT           NOT NULL,
    StartDateKey       INT           NULL,
    EndDateKey         INT           NULL,

    PassengerKey       INT           NOT NULL,
    DriverKey          INT           NULL,
    VehicleKey         INT           NULL,
    StartLocationKey   INT           NOT NULL,
    EndLocationKey     INT           NOT NULL,

    BaseFare           DECIMAL(10,2) NULL,
    FinalFare          DECIMAL(10,2) NULL,
    RideDurationMinutes INT          NULL,
    RideCount          INT           NOT NULL DEFAULT 1,

    CONSTRAINT FK_FactRides_RequestedDate
        FOREIGN KEY (RequestedDateKey) REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_FactRides_StartDate
        FOREIGN KEY (StartDateKey) REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_FactRides_EndDate
        FOREIGN KEY (EndDateKey) REFERENCES dbo.DimDate(DateKey),

    CONSTRAINT FK_FactRides_Passenger
        FOREIGN KEY (PassengerKey) REFERENCES dbo.DimPassenger(PassengerKey),

    CONSTRAINT FK_FactRides_Driver
        FOREIGN KEY (DriverKey) REFERENCES dbo.DimDriver(DriverKey),

    CONSTRAINT FK_FactRides_Vehicle
        FOREIGN KEY (VehicleKey) REFERENCES dbo.DimVehicle(VehicleKey),

    CONSTRAINT FK_FactRides_StartLocation
        FOREIGN KEY (StartLocationKey) REFERENCES dbo.DimLocation(LocationKey),

    CONSTRAINT FK_FactRides_EndLocation
        FOREIGN KEY (EndLocationKey) REFERENCES dbo.DimLocation(LocationKey)
);
GO

CREATE TABLE dbo.FactPayments (
    PaymentKey     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PaymentID      INT           NOT NULL,
    RideKey        INT           NOT NULL,
    PaymentDateKey INT           NOT NULL,
    Amount         DECIMAL(10,2) NOT NULL,
    PaymentStatus  NVARCHAR(20)  NOT NULL,
    PaymentMethod  NVARCHAR(50)  NOT NULL,

    CONSTRAINT FK_FactPayments_Ride
        FOREIGN KEY (RideKey) REFERENCES dbo.FactRides(RideKey),

    CONSTRAINT FK_FactPayments_Date
        FOREIGN KEY (PaymentDateKey) REFERENCES dbo.DimDate(DateKey)
);
GO

CREATE TABLE dbo.FactRidePromotions (
    RidePromotionKey     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- PK, SK
    RideKey              INT           NOT NULL,
    PromotionKey         INT           NOT NULL,
    DiscountValueApplied DECIMAL(10,2) NULL,
    IsPercentFlag        BIT           NULL,

    CONSTRAINT FK_FactRidePromotions_Ride
        FOREIGN KEY (RideKey) REFERENCES dbo.FactRides(RideKey),

    CONSTRAINT FK_FactRidePromotions_Promotion
        FOREIGN KEY (PromotionKey) REFERENCES dbo.DimPromotion(PromotionKey)
);
GO
