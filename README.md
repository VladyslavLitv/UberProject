# Uber Ride Management – Software Modeling and Analysis Project

## Model Diagrams

- **Conceptual Model** – Chen's Database Notation  
- **Logical Model** – Crow's Foot Database Notation  
- **Physical Model** – UML Database Notation  
- **Data Warehouse Model** – UML Database Notation, Star Schema  

---

## Database

- **MS SQL Server**
- **Microsoft SQL Server Management Studio (SSMS)**

### Main OLTP Tables
- User  
- Passenger  
- Driver  
- Vehicle  
- Location  
- Ride  
- Payment  
- Promotion  
- RidePromotion  

### Additional Features
- SQL Functions  
- Stored Procedures  
- Triggers  

---

## Data Warehouse (DWH)

Designed using a **Star Schema** containing:

### Dimensions
- DimDate  
- DimDriver  
- DimPassenger  
- DimVehicle  
- DimLocation  
- DimPromotion  

### Fact Tables
- FactRides  
- FactPayments  
- FactRidePromotions  

---

## Power BI

Business Intelligence report based on the Data Warehouse, including:

- Number of rides by date  
- Revenue per driver  
- Total discounts per promo code  

---

## Summary

This project demonstrates full-stack data modeling and analytics workflow:
1. Conceptual → Logical → Physical modeling  
2. OLTP database implementation with constraints, procedures, functions & triggers  
3. Data Warehouse construction and ETL integration  
4. Power BI visualization  

The system models an Uber-like ride management platform with support for drivers, passengers, vehicles, payments, locations, and promotions.

---
