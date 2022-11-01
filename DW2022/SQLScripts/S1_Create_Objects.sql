USE [Stage1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[S1_PW_Customers]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Customer_Department_Group]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Customer_Department]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Employees]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Employee_Timesheet]
GO
DROP TABLE IF EXISTS [dbo].[S1_PW_Internal_Projects]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_MM_Stock_Take]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_MM_Material]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Stock_Take]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Material]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Internal_Projects]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_PW_Customers]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Employee_Timesheet]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_PW_Customer_Department]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_PW_Customer_Department_Group]
GO
DROP TABLE IF EXISTS [dbo].[S1_MM_Stock_Take]
GO
DROP VIEW IF EXISTS [dbo].[S1_V_Employees]
GO

/***************************Drop Metadata Objects****************************************/

DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP VIEW IF EXISTS [dbo].[V_IB_Latest]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata Objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(1,1) NOT NULL,
	[IB_Description] [nvarchar](50) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IB_Month] [smallint] NULL,
	[IB_Start] [datetime] NOT NULL,
	[IB_End] [datetime] NULL,
	[IB_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch] PRIMARY KEY CLUSTERED 
(
	[IB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Import_Batch_Process](
	[IBP_ID] [int] IDENTITY(1,1) NOT NULL,
	[IB_ID] [int] NOT NULL,
	[IBP_Description] [nvarchar](50) NOT NULL,
	[IBP_Start] [datetime] NOT NULL,
	[IBP_End] [datetime] NULL,
	[IBP_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch_Process] PRIMARY KEY CLUSTERED 
(
	[IBP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process]  WITH CHECK ADD  CONSTRAINT [FK_IBP_IB_ID] FOREIGN KEY([IB_ID])
REFERENCES [dbo].[Import_Batch] ([IB_ID])
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task](
	[IBPT_ID] [int] IDENTITY(1,1) NOT NULL,
	[IBP_ID] [int] NOT NULL,
	[IBPT_Description] [nvarchar](50) NOT NULL,
	[IBPT_Start] [datetime] NOT NULL,
	[IBPT_End] [datetime] NULL,
	[IBPT_Status] [nvarchar](10) NOT NULL,
	[IBPT_Records_In] [int] NULL,
	[IBPT_Records_Failed] [int] NULL,
	[IBPT_Records_Out] [int] NULL,
 CONSTRAINT [PK_Import_Batch_Process_Task] PRIMARY KEY CLUSTERED 
(
	[IBPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process_Task]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_IBP_ID] FOREIGN KEY([IBP_ID])
REFERENCES [dbo].[Import_Batch_Process] ([IBP_ID])
GO

CREATE VIEW [dbo].[V_IB_Latest]
AS
SELECT        IB_Year, IB_Month, MAX(IB_ID) AS Latest_IB_ID, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1)) AS Last_Day_Of_Month
FROM            dbo.Import_Batch
GROUP BY IB_Year, IB_Month, EOMONTH(DATEFROMPARTS(IB_Year, IB_Month, 1))
GO

CREATE PROCEDURE [dbo].[Create_Import_Batch]
	-- Add the parameters for the stored procedure here
	@IB_Description nvarchar(50),
	@IB_Year smallint,
	@IB_Month smallint = NULL,
	@IB_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch] VALUES
           (@IB_Description,
            @IB_Year,
			@IB_Month,
			@IB_Start,
            NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process]
	-- Add the parameters for the stored procedure here
	@IB_ID int,
	@IBP_Description nvarchar(50),
	@IBP_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process] VALUES
           (@IB_ID,
            @IBP_Description,
			@IBP_Start,
			NULL,
			'Running');
	RETURN SCOPE_IDENTITY()
END
GO
CREATE PROCEDURE [dbo].[Create_Import_Batch_Process_Task]
	-- Add the parameters for the stored procedure here
	@IBP_ID int,
	@IBPT_Description nvarchar(50),
	@IBPT_Start datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [dbo].[Import_Batch_Process_Task] VALUES
           (@IBP_ID,
            @IBPT_Description,
			@IBPT_Start,
			NULL,
			'Running',
			NULL,
			NULL,
			NULL);
	RETURN SCOPE_IDENTITY()
END
GO


/***************************Create Data Objects****************************************/
CREATE TABLE [dbo].[S1_MM_Stock_Take](
	[ST_Year] [smallint] NOT NULL,
	[ST_Item_ID] [nvarchar](10) NOT NULL,
	[ST_Material] [nvarchar](20) NOT NULL,
	[ST_Item_Category] [nvarchar](20) NOT NULL,
	[ST_Item_Detail_1] [nvarchar](20) NOT NULL,
	[ST_Item_Detail_2] [nvarchar](20) NOT NULL,
	[ST_Item_Size] [nvarchar](20) NOT NULL,
	[ST_Item_Size_Unit_of_Measure] [nvarchar](5) NOT NULL,
	[ST_Item_Size_Note] [nvarchar](20) NOT NULL,
	[ST_Item_Comment] [nvarchar](50) NOT NULL,
	[ST_Item_Standard_Length_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Width_or_Diameter_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Height_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Interior_Diameter_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Standard_Thinkness_or_Wall_mm] [numeric](10, 2) NOT NULL,
	[ST_Item_Length_Measured_m] [numeric](10, 3) NULL,
	[ST_Item_Width_Measured_m] [numeric](10, 3) NULL,
	[ST_Item_Full_Units_Counted] [smallint] NULL,
	[ST_Item_Quantity_Unit_of_Measure] [nvarchar](10) NOT NULL,
	[ST_Item_Quantity_Scrapped] [float] NULL,
	[ST_Item_Unit_Price_incl_VAT] [numeric](10, 2) NULL,
	[ST_VAT] [numeric](10, 2) NOT NULL,
	[ST_Item_Source_Quantity_on_Hand_Value_excl_VAT] [float] NOT NULL,
	[ST_Transaction_ID] [nvarchar](20) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_MM_Stock_Take]  WITH CHECK ADD  CONSTRAINT [FK_S1_MM_Stock_Take_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

-- Selects the material attributes (dimension data) and performs group by. Only the latest import batch's data is selected
CREATE VIEW [dbo].[S1_V_MM_Material]
AS
SELECT        dbo.S1_MM_Stock_Take.ST_Year AS M_Year, dbo.S1_MM_Stock_Take.ST_Item_ID AS M_Material_Item_ID, dbo.S1_MM_Stock_Take.ST_Material AS M_Material_Type, 
                         dbo.S1_MM_Stock_Take.ST_Item_Category AS M_Material_Item_Category, dbo.S1_MM_Stock_Take.ST_Item_Detail_1 AS M_Material_Item_Detail_1, dbo.S1_MM_Stock_Take.ST_Item_Detail_2 AS M_Material_Item_Detail_2, 
                         dbo.S1_MM_Stock_Take.ST_Item_Size AS M_Material_Item_Size, dbo.S1_MM_Stock_Take.ST_Item_Size_Unit_of_Measure AS M_Material_Item_Size_Unit_Of_Measure, 
                         dbo.S1_MM_Stock_Take.ST_Item_Size_Note AS M_Material_Item_Size_Note, dbo.S1_MM_Stock_Take.ST_Item_Standard_Length_mm AS M_Material_Item_Standard_Length_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Width_or_Diameter_mm AS M_Material_Item_Standard_Width_or_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Height_mm AS M_Material_Item_Standard_Height_mm,
                          dbo.S1_MM_Stock_Take.ST_Item_Standard_Interior_Diameter_mm AS M_Material_Item_Standard_Interior_Diameter_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Thinkness_or_Wall_mm AS M_Material_Item_Standard_Thinkness_or_Wall_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Quantity_Unit_of_Measure AS M_Material_Item_Quantity_Unit_of_Measure
FROM            dbo.S1_MM_Stock_Take INNER JOIN
                         dbo.V_IB_Latest ON dbo.S1_MM_Stock_Take.ST_Year = dbo.V_IB_Latest.IB_Year INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_MM_Stock_Take.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID AND dbo.V_IB_Latest.Latest_IB_ID = dbo.Import_Batch_Process.IB_ID
GROUP BY dbo.S1_MM_Stock_Take.ST_Year, dbo.S1_MM_Stock_Take.ST_Item_ID, dbo.S1_MM_Stock_Take.ST_Material, dbo.S1_MM_Stock_Take.ST_Item_Category, dbo.S1_MM_Stock_Take.ST_Item_Detail_1, 
                         dbo.S1_MM_Stock_Take.ST_Item_Detail_2, dbo.S1_MM_Stock_Take.ST_Item_Size, dbo.S1_MM_Stock_Take.ST_Item_Size_Unit_of_Measure, dbo.S1_MM_Stock_Take.ST_Item_Size_Note, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Length_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Width_or_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Height_mm, 
                         dbo.S1_MM_Stock_Take.ST_Item_Standard_Interior_Diameter_mm, dbo.S1_MM_Stock_Take.ST_Item_Standard_Thinkness_or_Wall_mm, dbo.S1_MM_Stock_Take.ST_Item_Quantity_Unit_of_Measure
GO

-- Selects the natural keys and measurements (fact data). Only the latest import batch's data is selected
CREATE VIEW [dbo].[S1_V_MM_Stock_Take]
AS
SELECT        dbo.S1_MM_Stock_Take.ST_Transaction_ID, dbo.S1_MM_Stock_Take.ST_Year, dbo.S1_MM_Stock_Take.ST_Item_ID AS ST_Material_Item_ID, dbo.S1_MM_Stock_Take.ST_Item_Comment AS ST_Stock_Take_Comment, 
                         dbo.S1_MM_Stock_Take.ST_Item_Length_Measured_m AS ST_Length_Measured_m, dbo.S1_MM_Stock_Take.ST_Item_Width_Measured_m AS ST_Width_Measured_m, 
                         dbo.S1_MM_Stock_Take.ST_Item_Full_Units_Counted AS ST_Full_Units_Counted, dbo.S1_MM_Stock_Take.ST_Item_Quantity_Scrapped AS ST_Quantity_Scrapped, 
                         dbo.S1_MM_Stock_Take.ST_Item_Unit_Price_incl_VAT AS ST_Unit_Price_incl_VAT, dbo.S1_MM_Stock_Take.ST_VAT AS ST_VAT_Decimal, 
                         dbo.S1_MM_Stock_Take.ST_Item_Source_Quantity_on_Hand_Value_excl_VAT AS ST_Source_Quantity_on_Hand_Value_excl_VAT
FROM            dbo.S1_MM_Stock_Take INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.S1_MM_Stock_Take.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                         dbo.V_IB_Latest ON dbo.Import_Batch_Process.IB_ID = dbo.V_IB_Latest.Latest_IB_ID AND dbo.S1_MM_Stock_Take.ST_Year = dbo.V_IB_Latest.IB_Year
GO

CREATE TABLE [dbo].[S1_PW_Customers](
	[C_Customer_ID] [nvarchar](20) NOT NULL,
	[C_Department_ID] [nvarchar](20) NOT NULL,
	[C_Customer_Name] [nvarchar](100) NOT NULL,
	[C_Contact_Person] [nvarchar](50) NOT NULL,
	[C_Address_Line_1] [nvarchar](100) NOT NULL,
	[C_Address_Line_2] [nvarchar](100) NOT NULL,
	[C_City_Town] [nvarchar](50) NOT NULL,
	[C_Postal_Code] [nvarchar](4) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Customers]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Customers_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S1_PW_Employees](
	[E_Employee_ID] [nvarchar](20) NOT NULL,
	[E_Employee_Name] [nvarchar](50) NOT NULL,
	[E_Employee_Surname] [nvarchar](50) NOT NULL,
	[IPBT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Employees]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Employees_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S1_PW_Employees] CHECK CONSTRAINT [FK_S1_PW_Employees_Import_Batch_Process_Task]
GO


CREATE TABLE [dbo].[S1_PW_Customer_Department](
	[D_Department_ID] [nvarchar](20) NOT NULL,
	[D_Department_Name] [nvarchar](60) NOT NULL,
	[D_Customer_Group_ID] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Customer_Department]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Customer_Department_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[S1_PW_Customer_Department_Group](
	[G_Customer_Group_ID] [nvarchar](10) NOT NULL,
	[G_Customer_Group_Name] [nvarchar](50) NOT NULL,
	[G_Internal_Or_External] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Customer_Department_Group]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Customer_Department_Group_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO


CREATE TABLE [dbo].[S1_PW_Employee_Timesheet](
	[E_Year] [int] NOT NULL,
	[E_Week_of_Year] [int] NOT NULL,
	[E_Week_End_Date] [date] NOT NULL,
	[E_Project_ID] [nvarchar](7) NOT NULL,
	[E_Employee] [nvarchar](20) NULL,
	[E_Hours] [decimal](38, 4) NULL,
	[IPBT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Employee_Timesheet]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Employee_Timesheet_Import_Batch_Process_Task] FOREIGN KEY([IPBT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[S1_PW_Employee_Timesheet] CHECK CONSTRAINT [FK_S1_PW_Employee_Timesheet_Import_Batch_Process_Task]
GO

CREATE TABLE [dbo].[S1_PW_Internal_Projects](
	[IP_Project_ID] [nvarchar](7) NOT NULL,
	[IP_Request_Date] [date] NOT NULL,
	[IP_Customer_ID] [nvarchar](12) NOT NULL,
	[IP_Project_Category] [nvarchar](50) NOT NULL,
	[IP_Project_Description] [nvarchar](200) NOT NULL,
	[IP_Status] [nvarchar](50) NOT NULL,
	[IP_Labour_Costs] [decimal](38,4) NULL,
	[IP_Material_Costs] [decimal](38,4)  NULL,
	[IP_Handling_Fee] [decimal](38,4) NULL,
	[IP_Service_Billing_Number] [nvarchar](50) NOT NULL,
	[IBPT_ID] [int] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[S1_PW_Internal_Projects]  WITH CHECK ADD  CONSTRAINT [FK_S1_PW_Internal_Projects_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

-- Selects the material attributes (dimension data) and performs group by. Only the latest import batch's data is selected
CREATE VIEW [dbo].[S1_V_Material]
AS
SELECT ST_Year, ST_Item_ID, ST_Material, ST_Item_Category, ST_Item_Detail_1, ST_Item_Size, ST_Item_Detail_2, ST_Item_Size_Unit_of_Measure, ST_Item_Size_Note, ST_Item_Standard_Length_mm, ST_Item_Standard_Width_or_Diameter_mm, 
                  ST_Item_Standard_Height_mm, ST_Item_Standard_Interior_Diameter_mm, ST_Item_Standard_Thinkness_or_Wall_mm, ST_Item_Quantity_Unit_of_Measure, IBPT_ID
FROM     dbo.S1_MM_Stock_Take
GROUP BY ST_Year, ST_Item_ID, ST_Material, ST_Item_Category, ST_Item_Detail_1, ST_Item_Size, ST_Item_Detail_2, ST_Item_Size_Unit_of_Measure, ST_Item_Size_Note, ST_Item_Standard_Length_mm, 
                  ST_Item_Standard_Width_or_Diameter_mm, ST_Item_Standard_Height_mm, ST_Item_Standard_Interior_Diameter_mm, ST_Item_Standard_Thinkness_or_Wall_mm, ST_Item_Quantity_Unit_of_Measure, IBPT_ID
GO

-- Selects the natural keys and measurements (fact data). Only the latest import batch's data is selected
CREATE VIEW [dbo].[S1_V_Stock_Take]
AS
SELECT ST_Year, ST_Item_ID, ST_Item_Comment, ST_Item_Length_Measured_m, ST_Item_Width_Measured_m, ST_Item_Full_Units_Counted, ST_Item_Quantity_Scrapped, ST_VAT, ST_Item_Source_Quantity_on_Hand_Value_excl_VAT, 
                  ST_Transaction_ID, ST_Item_Unit_Price_incl_VAT, IBPT_ID
FROM     dbo.S1_MM_Stock_Take
GROUP BY ST_Year, ST_Item_ID, ST_Item_Comment, ST_Item_Length_Measured_m, ST_Item_Width_Measured_m, ST_Item_Full_Units_Counted, ST_Item_Quantity_Scrapped, ST_VAT, ST_Item_Source_Quantity_on_Hand_Value_excl_VAT, 
                  ST_Transaction_ID, ST_Item_Unit_Price_incl_VAT, IBPT_ID
GO

-- Selects all the details from internal projects, such as Project ID, project request date, Customer ID, Project Status, Project Description, Project Category and costs such as materials and handling fees, as well as the service billing number
CREATE VIEW [dbo].[S1_V_Internal_Projects]
AS
SELECT dbo.S1_PW_Internal_Projects.IP_Project_ID, dbo.S1_PW_Internal_Projects.IP_Request_Date, dbo.S1_PW_Internal_Projects.IP_Customer_ID, dbo.S1_PW_Internal_Projects.IP_Project_Category, 
                  dbo.S1_PW_Internal_Projects.IP_Project_Description, dbo.S1_PW_Internal_Projects.IP_Status, dbo.S1_PW_Internal_Projects.IP_Labour_Costs, dbo.S1_PW_Internal_Projects.IP_Material_Costs, 
                  dbo.S1_PW_Internal_Projects.IP_Handling_Fee, dbo.S1_PW_Internal_Projects.IP_Service_Billing_Number, dbo.S1_PW_Internal_Projects.IBPT_ID, dbo.Import_Batch.IB_Year
FROM     dbo.S1_PW_Internal_Projects INNER JOIN
                  dbo.Import_Batch_Process_Task ON dbo.S1_PW_Internal_Projects.IBPT_ID = dbo.Import_Batch_Process_Task.IBPT_ID INNER JOIN
                  dbo.Import_Batch_Process ON dbo.Import_Batch_Process_Task.IBP_ID = dbo.Import_Batch_Process.IBP_ID INNER JOIN
                  dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID
GROUP BY dbo.S1_PW_Internal_Projects.IP_Project_ID, dbo.S1_PW_Internal_Projects.IP_Request_Date, dbo.S1_PW_Internal_Projects.IP_Customer_ID, dbo.S1_PW_Internal_Projects.IP_Project_Category, 
                  dbo.S1_PW_Internal_Projects.IP_Project_Description, dbo.S1_PW_Internal_Projects.IP_Status, dbo.S1_PW_Internal_Projects.IP_Labour_Costs, dbo.S1_PW_Internal_Projects.IP_Material_Costs, 
                  dbo.S1_PW_Internal_Projects.IP_Handling_Fee, dbo.S1_PW_Internal_Projects.IP_Service_Billing_Number, dbo.S1_PW_Internal_Projects.IBPT_ID, dbo.Import_Batch.IB_Year
GO

-- Selects the details from the Customer, such as the Customer ID, name, Customer department, contact person, address lines, town/city and postal code
CREATE VIEW [dbo].[S1_V_PW_Customers]
AS
SELECT        dbo.Import_Batch.IB_Year, dbo.S1_PW_Customers.C_Customer_ID, dbo.S1_PW_Customers.C_Department_ID, dbo.S1_PW_Customers.C_Customer_Name, dbo.S1_PW_Customers.C_Contact_Person, 
                         dbo.S1_PW_Customers.C_Address_Line_1, dbo.S1_PW_Customers.C_Address_Line_2, dbo.S1_PW_Customers.C_City_Town, dbo.S1_PW_Customers.C_Postal_Code, dbo.S1_PW_Customers.IBPT_ID
FROM            dbo.Import_Batch INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch.IB_ID = dbo.Import_Batch_Process.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S1_PW_Customers ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S1_PW_Customers.IBPT_ID
GROUP BY dbo.Import_Batch.IB_Year, dbo.S1_PW_Customers.C_Customer_ID, dbo.S1_PW_Customers.C_Department_ID, dbo.S1_PW_Customers.C_Customer_Name, dbo.S1_PW_Customers.C_Contact_Person, 
                         dbo.S1_PW_Customers.C_Address_Line_1, dbo.S1_PW_Customers.C_Address_Line_2, dbo.S1_PW_Customers.C_City_Town, dbo.S1_PW_Customers.C_Postal_Code, dbo.S1_PW_Customers.IBPT_ID
GO

-- CUSTOMER DEPARTMENT VIEW WITH BATCH YEAR
--Selects the customer department names(dimension) and the department ID they belong to, and performs a group by. Only latest import batch's data is selected
CREATE VIEW [dbo].[S1_V_PW_Customer_Department]
AS
SELECT        dbo.S1_PW_Customer_Department.D_Department_ID, dbo.S1_PW_Customer_Department.D_Department_Name, dbo.S1_PW_Customer_Department.D_Customer_Group_ID, dbo.S1_PW_Customer_Department.IBPT_ID, 
                         dbo.Import_Batch.IB_Year
FROM            dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S1_PW_Customer_Department ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S1_PW_Customer_Department.IBPT_ID
GROUP BY dbo.S1_PW_Customer_Department.D_Department_ID, dbo.S1_PW_Customer_Department.D_Department_Name, dbo.S1_PW_Customer_Department.D_Customer_Group_ID, dbo.S1_PW_Customer_Department.IBPT_ID, 
                         dbo.Import_Batch.IB_Year
GO

-- CUSTOMER DEPARTMENT GROUP VIEW WITH BATCH YEAR
--Selects the customer department group names and the column which indicates if it is an internal or an external department(dimension) then performs a group by. Only the latest import batch's data is selected.
CREATE VIEW [dbo].[S1_V_PW_Customer_Department_Group]
AS
SELECT        dbo.S1_PW_Customer_Department_Group.G_Customer_Group_ID, dbo.S1_PW_Customer_Department_Group.G_Customer_Group_Name, dbo.S1_PW_Customer_Department_Group.G_Internal_Or_External, 
                         dbo.S1_PW_Customer_Department_Group.IBPT_ID, dbo.Import_Batch.IB_Year
FROM            dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S1_PW_Customer_Department_Group ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S1_PW_Customer_Department_Group.IBPT_ID
GROUP BY dbo.S1_PW_Customer_Department_Group.G_Customer_Group_ID, dbo.S1_PW_Customer_Department_Group.G_Customer_Group_Name, dbo.S1_PW_Customer_Department_Group.G_Internal_Or_External, 
                         dbo.S1_PW_Customer_Department_Group.IBPT_ID, dbo.Import_Batch.IB_Year
GO

-- Selects all the details of the Employee Timesheet table, such as the week of year, the week end date, the project ID, the employee name, the hours worked, and the year
CREATE VIEW [dbo].[S1_V_Employee_Timesheet]
AS
SELECT        dbo.S1_PW_Employee_Timesheet.E_Week_of_Year, dbo.S1_PW_Employee_Timesheet.E_Week_End_Date, dbo.S1_PW_Employee_Timesheet.E_Project_ID, dbo.S1_PW_Employee_Timesheet.E_Employee, 
                         SUM(dbo.S1_PW_Employee_Timesheet.E_Hours) AS E_Hours, dbo.S1_PW_Employee_Timesheet.IPBT_ID, dbo.S1_PW_Employee_Timesheet.E_Year, dbo.Import_Batch.IB_Year
FROM            dbo.Import_Batch INNER JOIN
                         dbo.Import_Batch_Process ON dbo.Import_Batch.IB_ID = dbo.Import_Batch_Process.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S1_PW_Employee_Timesheet ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S1_PW_Employee_Timesheet.IPBT_ID
GROUP BY dbo.S1_PW_Employee_Timesheet.E_Week_of_Year, dbo.S1_PW_Employee_Timesheet.E_Week_End_Date, dbo.S1_PW_Employee_Timesheet.E_Project_ID, dbo.S1_PW_Employee_Timesheet.E_Employee, 
                         dbo.S1_PW_Employee_Timesheet.E_Hours, dbo.S1_PW_Employee_Timesheet.IPBT_ID, dbo.S1_PW_Employee_Timesheet.E_Year, dbo.Import_Batch.IB_Year
GO

-- Selects all the details of the Employee table, such as the employee ID and the employee name
CREATE VIEW [dbo].[S1_V_Employees]
AS
SELECT        dbo.S1_PW_Employees.E_Employee_ID, dbo.S1_PW_Employees.E_Employee_Name, dbo.S1_PW_Employees.E_Employee_Surname, dbo.Import_Batch.IB_Year, dbo.S1_PW_Employees.IPBT_ID
FROM            dbo.Import_Batch_Process INNER JOIN
                         dbo.Import_Batch ON dbo.Import_Batch_Process.IB_ID = dbo.Import_Batch.IB_ID INNER JOIN
                         dbo.Import_Batch_Process_Task ON dbo.Import_Batch_Process.IBP_ID = dbo.Import_Batch_Process_Task.IBP_ID INNER JOIN
                         dbo.S1_PW_Employees ON dbo.Import_Batch_Process_Task.IBPT_ID = dbo.S1_PW_Employees.IPBT_ID
GROUP BY dbo.S1_PW_Employees.E_Employee_ID, dbo.S1_PW_Employees.E_Employee_Name, dbo.S1_PW_Employees.E_Employee_Surname, dbo.Import_Batch.IB_Year, dbo.S1_PW_Employees.IPBT_ID
GO