CREATE DATABASE UberCoursework;
GO

USE UberCoursework;
GO

CREATE TABLE dbo.Users (
	UserID int IDENTITY(1,1) primary key,
	Name nvarchar(100) not null,
	Email nvarchar(255) not null,
	Phone nvarchar(50) null,
	AvgRating decimal(3,2) null
);
GO

create table dbo.Passengers (
	PassengerID int primary key,
	PaymentMethod nvarchar(50) null,

	constraint FK_Passengers_Users
	foreign key (PassengerID)
	references dbo.Users(UserID)
);
GO

create table dbo.Drivers(
	DriverID int primary key,
	LicenseNumber nvarchar(50) not null,
	DriverStatus nvarchar(20) not null,

	constraint FK_Drivers_Users
	foreign key (DriverID)
	references dbo.Users(UserID)
);
GO

create table dbo.Vehicles (
	VehicleID int identity(1,1) primary key,
	DriverID int not null,
	Model nvarchar(100) not null,
	VehicleClass nvarchar(50) not null,
	ManufacturedYear smallint null,

	constraint FK_Vehicles_Drivers
	foreign key (DriverID)
	references dbo.Drivers(DriverID)
);
GO

create table dbo.Locations (
	LocationID int identity(1,1) primary key,
	Address nvarchar(255) not null
);
GO

create table dbo.Rides (
	RideID int identity(1,1) primary key,
	PassengerID int not null,
	DriverID int null,
	StartLocationID int null,
	EndLocationID int null,
	Fare decimal(10,2) null,
	RideStatus nvarchar(20) not null,
	StartTime datetime2(0) null,
	EndTime dateTime2(0) null,
	RequestedAt dateTime2(0) not null

	constraint FK_Rides_Passengers
	foreign key (PassengerID)
	references dbo.Passengers(PassengerID),

	constraint FK_Rides_Drivers
	foreign key (DriverID)
	references dbo.Drivers(DriverID),

	constraint FK_Rides_StartLocation
	foreign key (StartLocationID)
	references dbo.Locations(LocationID),

	constraint FK_Rides_EndLocation
	foreign key (EndLocationID)
	references dbo.Locations(LocationID)
);
GO

create table dbo.Payments (
	PaymentID int identity(1,1) primary key,
	RideID int null,
	Amount decimal(10,2) not null,
	PaymentMethod nvarchar(50) not null,
	PaymentStatus nvarchar(20) not null,
	PaidAt datetime2(0) null,

	constraint FK_Payment_Rides
	foreign key (RideID)
	references dbo.Rides(RideID),

	constraint UQ_Payments_RideID unique (RideID)
);
GO

create table dbo.Promotions (
	PromoID int identity(1,1) primary key,
	Code nvarchar(50) not null,
	DiscountType nvarchar(20) not null,
	DiscountValue decimal(10,2) not null,
	ValidPeriod nvarchar(50) null

	constraint UQ_Promotions_Code unique (Code)
);
GO


create table dbo.RidePromotions (
	RideID int not null,
	PromoID int not null,

	constraint PK_RidePromotions primary key (RideID, PromoID),

	constraint FK_RidePromotions_Rides
	foreign key (RideID)
	references dbo.Rides(RideID),

	constraint FK_RidePromotions_Promotions
	foreign key (PromoID)
	references dbo.Promotions(PromoID)
);
GO

alter table dbo.Drivers
add constraint CHK_Driver_Status
check (DriverStatus in (N'online', N'offline', N'busy'));
GO

alter table dbo.Rides
add constraint CHK_Ride_Status
check (RideStatus in (N'requested', N'accepted', N'completed', N'cancelled'));
GO

alter table dbo.Payments
add constraint CHK_Payment_Status
check (PaymentStatus in (N'pending', N'paid', N'refunded'));
GO

alter table dbo.Promotions
add constraint CHK_Promotion_Status
check (DiscountType in (N'percent', N'fixed'));
GO

alter table dbo.Rides
add constraint CHK_Rides_Fare_Positive
check (Fare is NULL or Fare >= 0);
GO

alter table dbo.Promotions
add constraint CHK_Promotions_DiscountValue_Positive
check (DiscountValue >= 0);
GO

alter table dbo.Payments
add constraint CHK_Payment_Amount_Positive
check (Amount > 0);
GO

alter table dbo.Rides
add constraint DF_Rides_Status
default N'requested' for RideStatus;
GO

alter table dbo.Payments
add constraint DF_Payments_Status
default N'pending' for PaymentStatus;
GO

alter table dbo.Payments
add constraint DF_Payments_PaidAt
default sysdatetime() for PaidAt;
GO