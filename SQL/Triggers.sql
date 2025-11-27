--Trigger for completed rides
CREATE TRIGGER dbo.TR_Payments_AfterInsert
ON dbo.Payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE r
    SET 
        r.RideStatus = N'completed',
        r.EndTime    = ISNULL(r.EndTime, SYSDATETIME())
    FROM dbo.Rides r
    JOIN inserted i ON r.RideID = i.RideID
    WHERE i.PaymentStatus = N'paid';
END;
GO


UPDATE dbo.Rides
SET 
    RideStatus = N'completed',
    StartTime  = DATEADD(MINUTE, -15, SYSDATETIME()),
    EndTime    = SYSDATETIME()
WHERE RideID = 1;

