USE [AtomicDW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***************************Drop Data Objects****************************************/
DROP TABLE IF EXISTS [dbo].[Stock_Take_Fact]
GO
DROP TABLE IF EXISTS [dbo].[Stock_Take_Indicators]
GO
DROP TABLE IF EXISTS [dbo].[Material]
GO
DROP VIEW IF EXISTS [dbo].[V_Min_Year_Key_Per_Year]
GO
/****** Object:  Table [dbo].[Annual_Project_Costs_Analysis]    Script Date: 2022/08/10 14:52:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Annual_Project_Costs_Analysis]') AND type in (N'U'))
DROP TABLE [dbo].[Annual_Project_Costs_Analysis]
GO

/****** Object:  Table [dbo].[Employee_Timesheet_Fact]    Script Date: 2022/08/10 14:53:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employee_Timesheet_Fact]') AND type in (N'U'))
DROP TABLE [dbo].[Employee_Timesheet_Fact]
GO

/****** Object:  Table [dbo].[Customer]    Script Date: 2022/08/10 11:43:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Customer]') AND type in (N'U'))
DROP TABLE [dbo].[Customer]
GO

/****** Object:  Table [dbo].[Employee]    Script Date: 2022/08/10 11:32:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employee]') AND type in (N'U'))
DROP TABLE [dbo].[Employee]
GO

/****** Object:  Table [dbo].[Project]    Script Date: 2022/08/09 19:07:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Project]') AND type in (N'U'))
DROP TABLE [dbo].[Project]
GO

/****** Object:  Table [dbo].[Project_Status]    Script Date: 2022/08/09 19:14:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Project_Status]') AND type in (N'U'))
DROP TABLE [dbo].[Project_Status]
GO
DROP TABLE IF EXISTS [dbo].[Date]
GO

/***************************Drop Metadata Objects****************************************/
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process_Task]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch_Process]
GO
DROP PROCEDURE IF EXISTS [dbo].[Create_Import_Batch]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task_Error_Log]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process_Task]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch_Process]
GO
DROP TABLE IF EXISTS [dbo].[Import_Batch]
GO

/***************************Create metadata objects******************************/
CREATE TABLE [dbo].[Import_Batch](
	[IB_ID] [int] IDENTITY(0,1) NOT NULL,
	[IB_Description] [nvarchar](50) NOT NULL,
	[IB_Year] [smallint] NOT NULL,
	[IB_Month] [smallint] NOT NULL,
	[IB_Start] [datetime] NOT NULL,
	[IB_End] [datetime] NULL,
	[IB_Status] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Import_Batch] PRIMARY KEY CLUSTERED 
(
	[IB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT INTO [dbo].[Import_Batch] /*Default values insert*/
     VALUES
           ('Insert_Default_Values'
           ,1900
           ,1
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed')
GO

CREATE TABLE [dbo].[Import_Batch_Process](
	[IBP_ID] [int] IDENTITY(0,1) NOT NULL,
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
INSERT INTO [dbo].[Import_Batch_Process] /*Default values insert*/
     VALUES
           (0
           ,'Insert_Default_Values'
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed')
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task](
	[IBPT_ID] [int] IDENTITY(0,1) NOT NULL,
	[IBP_ID] [int] NOT NULL,
	[IBPT_Description] [nvarchar](50) NOT NULL,
	[IBPT_Start] [datetime] NOT NULL,
	[IBPT_End] [datetime] NULL,
	[IBPT_Status] [nvarchar](10) NOT NULL,
	[IBPT_Records_In] [int] NULL,
	[IBPT_Records_Failed] [int] NULL,
	[IBPT_Records_Out] [int] NULL,
	[IBPT_Dim_Historical] [int] NULL,
	[IBPT_Dim_Changing] [int] NULL,
	[IBPT_Dim_New] [int] NULL,
	[IBPT_Dim_Unchanged] [int] NULL,
	[IBPT_Dim_Fixed_Errors] [int] NULL,
 CONSTRAINT [PK_Import_Batch_Process_Task] PRIMARY KEY CLUSTERED 
(
	[IBPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Batch_Process_Task]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_IBP_ID] FOREIGN KEY([IBP_ID])
REFERENCES [dbo].[Import_Batch_Process] ([IBP_ID])
GO
INSERT INTO [dbo].[Import_Batch_Process_Task]  /*Default values insert*/
     VALUES
           (0
           ,'Insert_Default_Values'
           ,'1900-01-01'
           ,'1900-01-01'
           ,'Completed'
           ,NULL
           ,NULL
           ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL)
GO

CREATE TABLE [dbo].[Import_Batch_Process_Task_Error_Log](
	[IBPT_ID] [int] NOT NULL,
	[ErrorDescription] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Import_Batch_Process_Task_Error_Log]  WITH CHECK ADD  CONSTRAINT [FK_IBPT_Error_Log_IBPT_ID] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE PROCEDURE [dbo].[Create_Import_Batch]
	-- Add the parameters for the stored procedure here
	@IB_Description nvarchar(50),
	@IB_Year smallint,
	@IB_Month smallint,
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
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL);
	RETURN SCOPE_IDENTITY()
END
GO

/***************************Create Dimension Tables******************************/
CREATE TABLE [dbo].[Date](
	[Date_Key] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[Date_Description] [nvarchar](20) NOT NULL,
	[Month_Of_Year] [tinyint] NOT NULL,
	[Month] [nvarchar](10) NOT NULL,
	[Year] [int] NOT NULL,
	[Year_Month] [nchar](7) NOT NULL,
	[Week_End_Date] [date] NOT NULL,
	[Week_Of_Year] [int] NOT NULL,
 CONSTRAINT [PK_Date] PRIMARY KEY CLUSTERED 
(
	[Date_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_Date] UNIQUE NONCLUSTERED 
(
	[Date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE VIEW [dbo].[V_Min_Year_Key_Per_Year]
AS
SELECT        MIN(Date_Key) AS Date_Key, [Year]
FROM            dbo.Date
GROUP BY [Year]
GO

CREATE TABLE [dbo].[Material](
	[Material_Item_Key] [int] IDENTITY(1,1) NOT NULL,
	[Material_Item_ID] [nvarchar](10) NOT NULL,
	[Material_Current_Group] [nvarchar](20) NOT NULL,
	[Material_Group] [nvarchar](20) NOT NULL,
	[Material_Type] [nvarchar](20) NOT NULL,
	[Material_Item_Current_Name] [nvarchar](150) NOT NULL,
	[Material_Item_Name] [nvarchar](150) NOT NULL,
	[Material_Category_Item_Type] [nvarchar](50) NOT NULL,
	[Material_Item_Category] [nvarchar](20) NOT NULL,
	[Material_Item_Detail_1] [nvarchar](20) NOT NULL,
	[Material_Item_Detail_2] [nvarchar](20) NOT NULL,
	[Material_Item_Size] [nvarchar](20) NOT NULL,
	[Material_Item_Size_Unit_Of_Measure] [nvarchar](5) NOT NULL,
	[Material_Item_Size_Note] [nvarchar](20) NOT NULL,
	[Material_Item_Standard_Length_mm] [numeric](10, 2) NOT NULL,
	[Material_Item_Standard_Width_or_Diameter_mm] [numeric](10, 2) NOT NULL,
	[Material_Item_Standard_Height_mm] [numeric](10, 2) NOT NULL,
	[Material_Item_Standard_Interior_Diameter_mm] [numeric](10, 2) NOT NULL,
	[Material_Item_Standard_Thinkness_or_Wall_mm] [numeric](10, 2) NOT NULL,
	[Material_Item_Quantity_Unit_of_Measure] [nvarchar](10) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiration_Date] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED 
(
	[Material_Item_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Material]  WITH CHECK ADD  CONSTRAINT [FK_Material_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[Stock_Take_Indicators](
	[Stock_Take_Indicators_Key] [int] IDENTITY(1,1) NOT NULL,
	[Stock_Take_Comment] [nvarchar](50) NOT NULL,
	[Length_Measured_Indicator] [nvarchar](50) NOT NULL,
	[Width_Measured_Indicator] [nvarchar](50) NOT NULL,
	[Full_Units_Counted_Indicator] [nvarchar](50) NOT NULL,
	[Material_Scrapped_Indicator] [nvarchar](50) NOT NULL,
	[Unit_Price_Available_Indicator] [nvarchar](50) NOT NULL,
	[VAT_Percentage] [nvarchar](20) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Stock_Take_Indicators] PRIMARY KEY CLUSTERED 
(
	[Stock_Take_Indicators_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stock_Take_Indicators]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Take_Indicators_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

CREATE TABLE [dbo].[Stock_Take_Fact](
	[Stock_Take_Date_Key] [int] NOT NULL,
	[Material_Item_Key] [int] NOT NULL,
	[Stock_Take_Indicators_Key] [int] NOT NULL,
	[Stock_Take_Transaction_ID] [nvarchar](20) NOT NULL,
	[Material_Length_Measured_m] [numeric](10, 3) NULL,
	[Material_Width_Measured_m] [numeric](10, 3) NULL,
	[Material_Full_Units_Counted] [smallint] NULL,
	[Material_Quantity_Scrapped] [float] NULL,
	[Material_Unit_Price_incl_VAT] [numeric](10, 2) NULL,
	[VAT_Decimal] [numeric](10, 2) NOT NULL,
	[Material_Source_Quantity_on_Hand_Value_excl_VAT] [float] NOT NULL,
	[Material_Unit_Price_excl_VAT] [float] NULL,
	[Material_Quantity_Counted] [float] NOT NULL,
	[Material_Quantity_on_Hand] [float] NOT NULL,
	[Material_Value_on_Hand_excl_VAT] [float] NOT NULL,
	[Material_Value_Scrapped_excl_VAT] [float] NOT NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Stock_Take_Fact] PRIMARY KEY CLUSTERED 
(
	[Stock_Take_Transaction_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stock_Take_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Take_Fact_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO
ALTER TABLE [dbo].[Stock_Take_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Take_Fact_Material] FOREIGN KEY([Material_Item_Key])
REFERENCES [dbo].[Material] ([Material_Item_Key])
GO
ALTER TABLE [dbo].[Stock_Take_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Take_Fact_Stock_Take_Date] FOREIGN KEY([Stock_Take_Date_Key])
REFERENCES [dbo].[Date] ([Date_Key])
GO
ALTER TABLE [dbo].[Stock_Take_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Stock_Take_Fact_Stock_Take_Indicators] FOREIGN KEY([Stock_Take_Indicators_Key])
REFERENCES [dbo].[Stock_Take_Indicators] ([Stock_Take_Indicators_Key])
GO

CREATE TABLE [dbo].[Customer](
	[Customer_Key] [int] IDENTITY(1,1) NOT NULL,
	[Customer_ID] [nvarchar](20) NULL,
	[Customer_Name] [nvarchar](100) NULL,
	[Current_Customer_Name] [nvarchar](100) NULL,
	[Customer_Contact_Person] [nvarchar](50) NULL,
	[Address_Line_1] [nvarchar](100) NULL,
	[Address_Line_2] [nvarchar](100) NULL,
	[City_Town] [nvarchar](50) NULL,
	[Postal_Code] [nvarchar](4) NULL,
	[Current_Department_Name] [nvarchar](60) NULL,
	[Department_Name] [nvarchar](60) NOT NULL,
	[Current_Department_Group_Name] [nvarchar](50) NULL,
	[Department_Group_Name] [nvarchar](50) NULL,
	[External_Or_Internal] [nvarchar](10) NULL,
	[Effective_Date] [date] NULL,
	[Expiration_Date] [date] NULL,
	[IsCurrent] [bit] NULL,
	[Import_Action] [nvarchar](10) NULL,
	[IBPT_ID] [int] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[Customer_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_Customer] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_Customer]
GO

/****** Object:  Table [dbo].[Employee]    Script Date: 2022/08/10 11:32:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employee](
	[Employee_Key] [int] IDENTITY(1,1) NOT NULL,
	[Employee_ID] [nvarchar](20) NOT NULL,
	[Employee_First_Name] [nvarchar](50) NULL,
	[Employee_Surname] [nvarchar](50) NULL,
	[Employee_Fullname] [nvarchar](100) NULL,
	[Effective_Date] [date] NULL,
	[Expiration_Date] [date] NULL,
	[IsCurrent] [bit] NULL,
	[Import_Action] [nvarchar](10) NULL,
	[IBPT_ID] [int] NULL,
 CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED 
(
	[Employee_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Employee]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Import_Batch_Process_Task]
GO

/****** Object:  Table [dbo].[Project]    Script Date: 2022/08/09 19:07:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Project](
	[Project_Key] [int] IDENTITY(1,1) NOT NULL,
	[Project_ID] [nvarchar](20) NOT NULL,
	[Project_Category] [nvarchar](50) NOT NULL,
	[Project_Description] [nvarchar](200) NOT NULL,
	[Project_Request_Date] [date] NOT NULL,
	[Current_Project_Status] [nvarchar](50) NOT NULL,
	[Effective_Date] [date] NOT NULL,
	[Expiration_Date] [date] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[Project_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Project] CHECK CONSTRAINT [FK_Project_Import_Batch_Process_Task]
GO

/****** Object:  Table [dbo].[Project_Status]    Script Date: 2022/08/09 19:14:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Project_Status](
	[Project_Status_Key] [int] IDENTITY(1,1) NOT NULL,
	[Project_Status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Project_Status] PRIMARY KEY CLUSTERED 
(
	[Project_Status_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Employee_Timesheet_Fact]    Script Date: 2022/08/08 16:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Employee_Timesheet_Fact](
	[Employee_Key] [int] NOT NULL,
	[Week_End_Date_Key] [int] NOT NULL,
	[Project_Key] [int] NOT NULL,
	[Hours_Worked] [decimal](38,4) NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
	CONSTRAINT PK_Employee_Timesheet_Fact PRIMARY KEY (Employee_Key, Week_End_Date_Key, Project_Key)
);
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Timesheet_Fact_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact] CHECK CONSTRAINT [FK_Employee_Timesheet_Fact_Import_Batch_Process_Task]
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Timesheet_Fact_Date] FOREIGN KEY ([Week_End_Date_Key])
REFERENCES [dbo].[Date] ([Date_Key])
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact] CHECK CONSTRAINT [FK_Employee_Timesheet_Fact_Date]
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Timesheet_Fact_Employee] FOREIGN KEY([Employee_Key])
REFERENCES [dbo].[Employee] ([Employee_Key])
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact] CHECK CONSTRAINT [FK_Employee_Timesheet_Fact_Employee]
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact]  WITH CHECK ADD  CONSTRAINT [FK_Employee_Timesheet_Fact_Project] FOREIGN KEY([Project_Key])
REFERENCES [dbo].[Project] ([Project_Key])
GO

ALTER TABLE [dbo].[Employee_Timesheet_Fact] CHECK CONSTRAINT [FK_Employee_Timesheet_Fact_Project]
GO

/****** Object:  Table [dbo].[Annual_Project_Costs_Analysis]    Script Date: 2022/08/08 16:38:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Annual_Project_Costs_Analysis](
	[Project_Request_Date_Key] [int] NOT NULL,
	[Project_Key] [int] NOT NULL,
	[Customer_Key] [int] NOT NULL,
	[Project_Status_Key] [int] NOT NULL,
	[Service_Billing_Number] [nvarchar](50) NOT NULL,
	[Project_Labour_Cost] [decimal](38, 4) NULL,
	[Project_Material_Cost] [decimal](38, 4) NULL,
	[Project_Handling_Fee] [decimal](38, 4) NULL,
	[Project_Total_Costs] [decimal](38, 4) NULL,
	[Import_Action] [nvarchar](10) NOT NULL,
	[IBPT_ID] [int] NOT NULL,
 CONSTRAINT [PK_Annual_Project_Costs_Analysis] PRIMARY KEY CLUSTERED 
(
	[Project_Request_Date_Key] ASC,
	[Project_Key] ASC,
	[Customer_Key] ASC,
	[Project_Status_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis]  WITH CHECK ADD  CONSTRAINT [FK_Annual_Project_Costs_Analysis_Customer] FOREIGN KEY([Customer_Key])
REFERENCES [dbo].[Customer] ([Customer_Key])
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis] CHECK CONSTRAINT [FK_Annual_Project_Costs_Analysis_Customer]
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis]  WITH CHECK ADD  CONSTRAINT [FK_Annual_Project_Costs_Analysis_Import_Batch_Process_Task] FOREIGN KEY([IBPT_ID])
REFERENCES [dbo].[Import_Batch_Process_Task] ([IBPT_ID])
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis] CHECK CONSTRAINT [FK_Annual_Project_Costs_Analysis_Import_Batch_Process_Task]
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis]  WITH CHECK ADD  CONSTRAINT [FK_Annual_Project_Costs_Analysis_Project] FOREIGN KEY([Project_Key])
REFERENCES [dbo].[Project] ([Project_Key])
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis] CHECK CONSTRAINT [FK_Annual_Project_Costs_Analysis_Project]
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis]  WITH CHECK ADD  CONSTRAINT [FK_Annual_Project_Costs_Analysis_Project_Status] FOREIGN KEY([Project_Status_Key])
REFERENCES [dbo].[Project_Status] ([Project_Status_Key])
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis] CHECK CONSTRAINT [FK_Annual_Project_Costs_Analysis_Project_Status]
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis]  WITH CHECK ADD  CONSTRAINT [FK_Annual_Project_Costs_Analysis_Stock_Take_Date_Request] FOREIGN KEY([Project_Request_Date_Key])
REFERENCES [dbo].[Date] ([Date_Key])
GO

ALTER TABLE [dbo].[Annual_Project_Costs_Analysis] CHECK CONSTRAINT [FK_Annual_Project_Costs_Analysis_Stock_Take_Date_Request]
GO