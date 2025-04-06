# AdventureWorks SQL & PowerBI

## Modelo Dimensional y Dashboard Analítico 

Este repositorio contiene la implementación completa de un proyecto de Business Intelligence utilizando la base de datos AdventureWorks, desde la transformación ETL hasta la visualización en Power BI, siguiendo las mejores prácticas de modelado dimensional según la metodología Kimball.

![image](https://github.com/user-attachments/assets/eff4aa39-5740-43f2-996b-be3921a2c88b)


## Características del Proyecto

- **ETL en SQL Server:** Transformación de un modelo OLTP a un modelo dimensional optimizado para análisis
- **Metodología Kimball:** Implementación rigurosa de un esquema en estrella (star schema)
- **Dashboard Interactivo:** Visualizaciones avanzadas con KPIs de ventas, rentabilidad y comportamiento del cliente
- **Análisis Multidimensional:** Segmentación por productos, territorios y clientes

## Estructura del Modelo Dimensional

### Tablas de Dimensiones
El proyecto implementa las siguientes dimensiones, cada una diseñada para facilitar análisis específicos:

- **DimFecha:** Jerarquía temporal completa (día, mes, trimestre, año, año fiscal)
- **DimProducto:** Categorización de productos  
- **DimCliente:** Información demográfica y comportamiento de compra agregado
- **DimTerritorio:** Segmentación geográfica para análisis regional
- **DimPromocion:** Detalles de ofertas y descuentos para medir efectividad

### Tabla de Hechos
- **FactSalesOrderDetail:** Núcleo analítico que integra todas las dimensiones con métricas calculadas clave:
  - Cantidades y precios unitarios
  - Métricas financieras (costos, ingresos, márgenes)
  - Descuentos aplicados
  - Medidas de tiempo de envío

## Implementación Técnica

### Proceso ETL
El proceso ETL sigue un enfoque metódico para transformar datos operacionales en un modelo analítico:

1. **Extracción:** Identificación y selección de tablas fuente relevantes del esquema OLTP AdventureWorks.

2. **Transformación:**  Cálculo de indicadores clave como el margen de beneficio y los días de envío, a partir de operaciones aritméticas y funciones de fechas, además de otros procesos de transformación aplicados en los datos.

    ```sql
   -- Transformación para cálculo de márgenes de beneficio
   CASE 
       WHEN sod.UnitPrice > 0 
       THEN ROUND(((sod.UnitPrice - p.StandardCost) / sod.UnitPrice) * 100, 2)
       ELSE NULL 
   END AS ProfitMargin,
   
   -- Cálculo de métricas de envío
   DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) AS ShippingDays
   ```
  
4. **Carga:** Población de las tablas dimensionales y de hechos mediante operaciones INSERT/SELECT, con gestión de valores nulos y claves foráneas

### Dashboard en Power BI
El dashboard desarrollado aprovecha este modelo dimensional para proporcionar:

- **Análisis Temporal:** Tendencias de ventas y rentabilidad (2011-2014)
- **Segmentación por Producto:** Análisis de categorías y subcategorías con mayor margen
- **Comportamiento del Cliente:** Patrones de compra y segmentación
- **Distribución Geográfica:** Rendimiento por territorios y países
  
![image](https://github.com/user-attachments/assets/10d5ae3b-81bc-4c40-bf11-1e8b4a3f8c68)

![image](https://github.com/user-attachments/assets/988b3f9d-0f2d-400c-8be2-625820b0341a)


## Tecnologías Utilizadas

- **SQL Server:** Para el modelado dimensional y proceso ETL
- **Power BI:** Para las visualizaciones y dashboard interactivo
- **AdventureWorks:** Base de datos SQL de origen

## Resultados Clave

El dashboard proporciona insights críticos para el negocio:
- Margen de beneficio promedio de 29.05%
- Identificación de subcategorías de alto margen (Bike Stands: 62.6%)
- Visualización de tendencias de crecimiento de ingresos y márgenes
- Análisis detallado del comportamiento de compra por cliente


## Licencia

Este proyecto está bajo la licencia MIT. Consulte el archivo `LICENSE` para más detalles


