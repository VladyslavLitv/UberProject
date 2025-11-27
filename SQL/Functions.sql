CREATE FUNCTION dbo.fn_GetRideDurationMinutes
(
    @RideID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @StartTime DATETIME2(0);
    DECLARE @EndTime   DATETIME2(0);

    SELECT 
        @StartTime = StartTime,
        @EndTime   = EndTime
    FROM dbo.Rides
    WHERE RideID = @RideID;

    IF @StartTime IS NULL OR @EndTime IS NULL
        RETURN NULL;

    RETURN DATEDIFF(MINUTE, @StartTime, @EndTime);
END;
GO

