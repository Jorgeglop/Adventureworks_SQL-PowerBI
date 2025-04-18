# AdventureWorks SQL & PowerBI

## Modelo Dimensional y Dashboard Analítico 

Este repositorio contiene la implementación completa de un proyecto de Business Intelligence utilizando la base de datos AdventureWorks, desde la transformación ETL hasta la visualización en Power BI, siguiendo las mejores prácticas de modelado dimensional según la metodología Kimball.

![AdventureWorks-Esquema](https://github.com/user-attachments/assets/b8b40ae8-f252-43c0-a606-4f138d465b22)


## Características del Proyecto

- **ETL en SQL Server:** transformación de un modelo OLTP a un modelo dimensional optimizado para análisis.
- **Metodología Kimball:** implementación rigurosa de un esquema en estrella (star schema).
- **Dashboard Interactivo:** visualizaciones avanzadas con KPIs de ventas, rentabilidad y comportamiento del cliente.
- **Análisis Multidimensional:** segmentación por productos, territorios y clientes.

## Estructura del Modelo Dimensional

### Tablas de Dimensiones
El proyecto implementa las siguientes dimensiones, cada una diseñada para facilitar análisis específicos:

- **DimFecha:** jerarquía temporal completa (día, mes, trimestre, año, año fiscal).
- **DimProducto:** categorización de productos.
- **DimCliente:** información demográfica y comportamiento de compra agregado.
- **DimTerritorio:** segmentación geográfica para análisis regional.
- **DimPromocion:** detalles de ofertas y descuentos para medir efectividad.

### Tabla de Hechos
- **FactSalesOrderDetail:** núcleo analítico que integra todas las dimensiones con métricas calculadas clave:
  - Cantidades y precios unitarios.
  - Métricas financieras (costos, ingresos, márgenes).
  - Descuentos aplicados.
  - Medidas de tiempo de envío.

## Implementación Técnica

### Proceso ETL
El proceso ETL sigue un enfoque metódico para transformar datos operacionales en un modelo analítico:

1. **Extracción:** identificación y selección de tablas fuente relevantes del esquema OLTP AdventureWorks.

2. **Transformación:**  cálculo de indicadores clave como el margen de beneficio y los días de envío, a partir de operaciones aritméticas y funciones de fechas, además de otros procesos de transformación aplicados en los datos.

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
  
4. **Carga:** población de las tablas dimensionales y de hechos mediante operaciones INSERT/SELECT, con gestión de valores nulos y claves foráneas

### Dashboard en Power BI
El dashboard desarrollado aprovecha este modelo dimensional para proporcionar:

- **Análisis Temporal:** tendencias de ventas y rentabilidad (2011-2014).
- **Segmentación por Producto:** análisis de categorías y subcategorías con mayor margen.
- **Comportamiento del Cliente:** patrones de compra y segmentación.
- **Distribución Geográfica:** rendimiento por territorios y países.
  
![image](https://github.com/user-attachments/assets/10d5ae3b-81bc-4c40-bf11-1e8b4a3f8c68)

![image](https://github.com/user-attachments/assets/988b3f9d-0f2d-400c-8be2-625820b0341a)


## Tecnologías Utilizadas

- **SQL Server:** para el modelado dimensional y proceso ETL.
- **Power BI:** para las visualizaciones y dashboard interactivo.
- **AdventureWorks:** base de datos SQL de origen.

## Resultados Clave

El dashboard proporciona insights críticos para el negocio:
- Margen de beneficio promedio de 29.05%.
- Identificación de subcategorías de alto margen (Bike Stands: 62.6%).
- Visualización de tendencias de crecimiento de ingresos y márgenes.
- Análisis detallado del comportamiento de compra por cliente.


## Licencia

Este proyecto está bajo la licencia MIT. Consulte el archivo `LICENSE` para más detalles.


