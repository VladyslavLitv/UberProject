--Create a ride
CREATE PROCEDURE dbo.CreateRide
    @PassengerID     INT,
    @StartLocationID INT,
    @EndLocationID   INT,
    @Fare            DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Rides (
        PassengerID,
        DriverID,
        StartLocationID,
        EndLocationID,
        Fare,
        RideStatus,
        StartTime,
        EndTime,
        RequestedAt
    )
    VALUES (
        @PassengerID,
        NULL,                 
        @StartLocationID,
        @EndLocationID,
        @Fare,
        N'requested',         
        NULL,
        NULL,
        SYSDATETIME()
    );
END;

EXEC dbo.CreateRide 
    @PassengerID     = 2,
    @StartLocationID = 1,
    @EndLocationID   = 2,
    @Fare            = 15.50;

GO

SELECT * FROM dbo.Rides ORDER BY RideID DESC;
