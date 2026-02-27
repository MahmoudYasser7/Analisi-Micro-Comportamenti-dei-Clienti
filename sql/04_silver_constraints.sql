USE Analisi;
GO

  
ALTER TABLE dbo.[silver customersup]
ADD CONSTRAINT [pk silver customersup] PRIMARY KEY ([user id]);
GO

ALTER TABLE dbo.[silver bookings]
ADD CONSTRAINT [pk silver bookings] PRIMARY KEY ([booking id]);
GO

ALTER TABLE dbo.[silver ancillaries]
ADD CONSTRAINT [pk silver ancillaries] PRIMARY KEY ([ancillary id]);
GO


CREATE INDEX [idx silver bookings user]
ON dbo.[silver bookings] ([user id]);
GO

CREATE INDEX [idx silver ancillaries booking]
ON dbo.[silver ancillaries] ([booking id]);
GO

CREATE INDEX [idx silver bookings destination]
ON dbo.[silver bookings] ([destination]);
GO

CREATE INDEX [idx silver bookings channel]
ON dbo.[silver bookings] ([channel]);
GO

CREATE INDEX [idx silver bookings currency]
ON dbo.[silver bookings] ([currency]);
GO

CREATE INDEX [idx silver ancillaries product]
ON dbo.[silver ancillaries] ([product type]);
GO
