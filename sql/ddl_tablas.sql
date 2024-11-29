DROP DATABASE geoprediccion;
CREATE DATABASE IF NOT EXISTS geoprediccion;

CREATE TABLE `apertura` (
  `RUBRO` text,
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `ANIO` int DEFAULT NULL,
  `CUATRIMESTRE` int DEFAULT NULL,
  `NIVEL` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `cierre` (
  `RUBRO` text,
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `ANIO` int DEFAULT NULL,
  `CUATRIMESTRE` int DEFAULT NULL,
  `NIVEL` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `demografia` (
  `MOC_DEMOGRAFIA_ID` int DEFAULT NULL,
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `PK_RANGO_ETARIO_ID` int DEFAULT NULL,
  `PK_GENERO_ID` int DEFAULT NULL,
  `POBLACION_VIVIENTE` int DEFAULT NULL,
  `POBLACION_TRABAJADORA` int DEFAULT NULL,
  `RANGO_ETARIO` text,
  `GENERO` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `rubros` (
  `MOC_RUBROS_ID` int DEFAULT NULL,
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `RUBRO` text,
  `NIVEL_RIESGO` bigint DEFAULT NULL,
  `FACTURACION_PROM_ACTUAL` double DEFAULT NULL,
  `INDICE_CRECIMIENTO` double DEFAULT NULL,
  `INDICE_ESTABILIDAD` double DEFAULT NULL,
  `INDICE_APERTURA` double DEFAULT NULL,
  `INDICE_CIERRE` double DEFAULT NULL,
  `INDICE_SUPERVIVENCIA` double DEFAULT NULL,
  `IND_AP_ACT_VS_IND_AP_ANIO_ANT` double DEFAULT NULL,
  `IND_CL_ACT_VS_IND_CL_ANIO_ANT` double DEFAULT NULL,
  `SUP_MENOS_1` double DEFAULT NULL,
  `SUP_ENTRE_1_Y_2` double DEFAULT NULL,
  `SUP_ENTRE_2_Y_3` double DEFAULT NULL,
  `SUP_ENTRE_3_Y_4` double DEFAULT NULL,
  `SUP_ENTRE_4_Y_5` double DEFAULT NULL,
  `SUP_MAS_5` double DEFAULT NULL,
  `FACTURACION_PROM_ANIO_ANT` double DEFAULT NULL,
  `NIVEL_LOCALES` text,
  `INDICE_CIERRE_ANIO_ANT` double DEFAULT NULL,
  `INDICE_APERTURA_ANIO_ANT` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `zonas` (
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `PK_TIEMPO_ID` int DEFAULT NULL,
  `POBLACION_FLOTANTE` int DEFAULT NULL,
  `POBLACION_VIVIENTE` int DEFAULT NULL,
  `POBLACION_TRABAJADORA` int DEFAULT NULL,
  `CANTIDAD_HOGARES` int DEFAULT NULL,
  `PRECIO_PROMEDIO_ALQUILER_LOCAL` double DEFAULT NULL,
  `PRECIO_MAX_ALQUILER_LOCAL` double DEFAULT NULL,
  `PRECIO_MIN_ALQUILER_LOCAL` double DEFAULT NULL,
  `SUPERFICIE_M2_PROMEDIO_ALQUILER` double DEFAULT NULL,
  `SUPERFICIE_M2_MAX_ALQUILER` double DEFAULT NULL,
  `SUPERFICIE_M2_MIN_ALQUILER` double DEFAULT NULL,
  `RUBRO_PREDOMINANTE` text,
  `FACTURACION_PROM_RUBRO_PREDOMINANTE` int DEFAULT NULL,
  `FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE` int DEFAULT NULL,
  `RUBRO_MENOS_PREDOMINANTE` text,
  `PRECIO_PROMEDIO_VENTA_LOCAL` double DEFAULT NULL,
  `PRECIO_MAX_VENTA_LOCAL` double DEFAULT NULL,
  `PRECIO_MIN_VENTA_LOCAL` double DEFAULT NULL,
  `SUPERFICIE_M2_PROMEDIO_VENTA` double DEFAULT NULL,
  `SUPERFICIE_M2_MAX_VENTA` double DEFAULT NULL,
  `SUPERFICIE_M2_MIN_VENTA` double DEFAULT NULL,
  `NIVEL_LOCALES_RUBRO_PREDOMINANTE` int DEFAULT NULL,
  `NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE` int DEFAULT NULL,
  `FECHA` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


create index idx_apertura_moc_id on apertura(moc_zonas_id);
create index idx_cierre_moc_id on cierre(moc_zonas_id);
create index idx_demografia_moc_id on demografia(moc_zonas_id);
create index idx_rubros_moc_id on rubros(moc_zonas_id);
create index idx_zonas_moc_id on zonas(moc_zonas_id);

create table zona_rubro as
select z.MOC_ZONAS_ID, z.POBLACION_FLOTANTE, z.POBLACION_VIVIENTE, z.POBLACION_TRABAJADORA, z.CANTIDAD_HOGARES, z.PRECIO_PROMEDIO_ALQUILER_LOCAL, z.PRECIO_MAX_ALQUILER_LOCAL, z.PRECIO_MIN_ALQUILER_LOCAL, z.SUPERFICIE_M2_PROMEDIO_ALQUILER, z.SUPERFICIE_M2_MAX_ALQUILER, z.SUPERFICIE_M2_MIN_ALQUILER, z.RUBRO_PREDOMINANTE, z.FACTURACION_PROM_RUBRO_PREDOMINANTE, z.FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE, z.RUBRO_MENOS_PREDOMINANTE, z.PRECIO_PROMEDIO_VENTA_LOCAL, z.PRECIO_MAX_VENTA_LOCAL, z.PRECIO_MIN_VENTA_LOCAL, z.SUPERFICIE_M2_PROMEDIO_VENTA, z.SUPERFICIE_M2_MAX_VENTA, z.SUPERFICIE_M2_MIN_VENTA, z.NIVEL_LOCALES_RUBRO_PREDOMINANTE, z.NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE, r.MOC_RUBROS_ID, r.RUBRO, r.NIVEL_RIESGO, r.FACTURACION_PROM_ACTUAL, r.INDICE_CRECIMIENTO, r.INDICE_ESTABILIDAD, r.INDICE_APERTURA, r.INDICE_CIERRE, r.INDICE_SUPERVIVENCIA, r.IND_AP_ACT_VS_IND_AP_ANIO_ANT, r.IND_CL_ACT_VS_IND_CL_ANIO_ANT, r.SUP_MENOS_1, r.SUP_ENTRE_1_Y_2, r.SUP_ENTRE_2_Y_3, r.SUP_ENTRE_3_Y_4, r.SUP_ENTRE_4_Y_5, r.SUP_MAS_5, r.FACTURACION_PROM_ANIO_ANT, r.NIVEL_LOCALES, r.INDICE_CIERRE_ANIO_ANT, r.INDICE_APERTURA_ANIO_ANT
From zonas z join rubros r on (r.MOC_ZONAS_ID=z.MOC_ZONAS_ID)
order by z.MOC_ZONAS_ID, r.MOC_RUBROS_ID;

create index idx_zonas_moc_rubro on zona_rubro(moc_zonas_id,moc_rubros_id);

create table am_pruebas as
with zona_rubro as (
select z.MOC_ZONAS_ID,
z.PK_TIEMPO_ID,
z.POBLACION_FLOTANTE,
z.POBLACION_VIVIENTE,
z.POBLACION_TRABAJADORA,
z.CANTIDAD_HOGARES,
z.PRECIO_PROMEDIO_ALQUILER_LOCAL,
z.PRECIO_MAX_ALQUILER_LOCAL,
z.PRECIO_MIN_ALQUILER_LOCAL,
z.SUPERFICIE_M2_PROMEDIO_ALQUILER,
z.SUPERFICIE_M2_MAX_ALQUILER,
z.SUPERFICIE_M2_MIN_ALQUILER,
z.RUBRO_PREDOMINANTE,
z.FACTURACION_PROM_RUBRO_PREDOMINANTE,
z.FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE,
z.RUBRO_MENOS_PREDOMINANTE,
z.PRECIO_PROMEDIO_VENTA_LOCAL,
z.PRECIO_MAX_VENTA_LOCAL,
z.PRECIO_MIN_VENTA_LOCAL,
z.SUPERFICIE_M2_PROMEDIO_VENTA,
z.SUPERFICIE_M2_MAX_VENTA,
z.SUPERFICIE_M2_MIN_VENTA,
z.NIVEL_LOCALES_RUBRO_PREDOMINANTE,
z.NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE,
r.MOC_RUBROS_ID,
r.RUBRO,
r.NIVEL_RIESGO,
r.FACTURACION_PROM_ACTUAL,
r.INDICE_CRECIMIENTO,
r.INDICE_ESTABILIDAD,
r.INDICE_APERTURA,
r.INDICE_CIERRE,
r.INDICE_SUPERVIVENCIA,
r.IND_AP_ACT_VS_IND_AP_ANIO_ANT,
r.IND_CL_ACT_VS_IND_CL_ANIO_ANT,
r.SUP_MENOS_1,
r.SUP_ENTRE_1_Y_2,
r.SUP_ENTRE_2_Y_3,
r.SUP_ENTRE_3_Y_4,
r.SUP_ENTRE_4_Y_5,
r.SUP_MAS_5,
r.FACTURACION_PROM_ANIO_ANT,
r.NIVEL_LOCALES,
r.INDICE_CIERRE_ANIO_ANT,
r.INDICE_APERTURA_ANIO_ANT
 from zonas z join rubros r on (z.moc_zonas_id=r.moc_zonas_id))
 select zr.MOC_ZONAS_ID,
zr.PK_TIEMPO_ID,
zr.POBLACION_FLOTANTE,
zr.CANTIDAD_HOGARES,
zr.PRECIO_PROMEDIO_ALQUILER_LOCAL,
zr.PRECIO_MAX_ALQUILER_LOCAL,
zr.PRECIO_MIN_ALQUILER_LOCAL,
zr.SUPERFICIE_M2_PROMEDIO_ALQUILER,
zr.SUPERFICIE_M2_MAX_ALQUILER,
zr.SUPERFICIE_M2_MIN_ALQUILER,
zr.RUBRO_PREDOMINANTE,
zr.FACTURACION_PROM_RUBRO_PREDOMINANTE,
zr.FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE,
zr.RUBRO_MENOS_PREDOMINANTE,
zr.PRECIO_PROMEDIO_VENTA_LOCAL,
zr.PRECIO_MAX_VENTA_LOCAL,
zr.PRECIO_MIN_VENTA_LOCAL,
zr.SUPERFICIE_M2_PROMEDIO_VENTA,
zr.SUPERFICIE_M2_MAX_VENTA,
zr.SUPERFICIE_M2_MIN_VENTA,
zr.NIVEL_LOCALES_RUBRO_PREDOMINANTE,
zr.NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE,
zr.MOC_RUBROS_ID,
zr.RUBRO,
zr.NIVEL_RIESGO,
zr.FACTURACION_PROM_ACTUAL,
zr.INDICE_CRECIMIENTO,
zr.INDICE_ESTABILIDAD,
zr.INDICE_APERTURA,
zr.INDICE_CIERRE,
zr.INDICE_SUPERVIVENCIA,
zr.IND_AP_ACT_VS_IND_AP_ANIO_ANT,
zr.IND_CL_ACT_VS_IND_CL_ANIO_ANT,
zr.SUP_MENOS_1,
zr.SUP_ENTRE_1_Y_2,
zr.SUP_ENTRE_2_Y_3,
zr.SUP_ENTRE_3_Y_4,
zr.SUP_ENTRE_4_Y_5,
zr.SUP_MAS_5,
zr.FACTURACION_PROM_ANIO_ANT,
zr.NIVEL_LOCALES,
zr.INDICE_CIERRE_ANIO_ANT,
zr.INDICE_APERTURA_ANIO_ANT,
d.MOC_DEMOGRAFIA_ID,
d.PK_RANGO_ETARIO_ID,
d.PK_GENERO_ID,
d.POBLACION_VIVIENTE,
d.POBLACION_TRABAJADORA,
d.RANGO_ETARIO,
d.GENERO
 from demografia d join zona_rubro zr on (d.moc_zonas_id=zr.moc_zonas_id);
 
select  ap.MOC_ZONAS_ID,
ap.POBLACION_FLOTANTE,
ap.CANTIDAD_HOGARES,
ap.PRECIO_PROMEDIO_ALQUILER_LOCAL,
ap.PRECIO_MAX_ALQUILER_LOCAL,
ap.PRECIO_MIN_ALQUILER_LOCAL,
ap.SUPERFICIE_M2_PROMEDIO_ALQUILER,
ap.SUPERFICIE_M2_MAX_ALQUILER,
ap.SUPERFICIE_M2_MIN_ALQUILER,
ap.RUBRO_PREDOMINANTE,
ap.FACTURACION_PROM_RUBRO_PREDOMINANTE,
ap.FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE,
ap.RUBRO_MENOS_PREDOMINANTE,
ap.PRECIO_PROMEDIO_VENTA_LOCAL,
ap.PRECIO_MAX_VENTA_LOCAL,
ap.PRECIO_MIN_VENTA_LOCAL,
ap.SUPERFICIE_M2_PROMEDIO_VENTA,
ap.SUPERFICIE_M2_MAX_VENTA,
ap.SUPERFICIE_M2_MIN_VENTA,
ap.NIVEL_LOCALES_RUBRO_PREDOMINANTE,
ap.NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE,
ap.MOC_RUBROS_ID,
ap.RUBRO,
ap.NIVEL_RIESGO,
ap.FACTURACION_PROM_ACTUAL,
ap.INDICE_CRECIMIENTO,
ap.INDICE_ESTABILIDAD,
ap.INDICE_APERTURA,
ap.INDICE_CIERRE,
ap.INDICE_SUPERVIVENCIA,
ap.IND_AP_ACT_VS_IND_AP_ANIO_ANT,
ap.IND_CL_ACT_VS_IND_CL_ANIO_ANT,
ap.SUP_MENOS_1,
ap.SUP_ENTRE_1_Y_2,
ap.SUP_ENTRE_2_Y_3,
ap.SUP_ENTRE_3_Y_4,
ap.SUP_ENTRE_4_Y_5,
ap.SUP_MAS_5,
ap.FACTURACION_PROM_ANIO_ANT,
ap.NIVEL_LOCALES,
ap.INDICE_CIERRE_ANIO_ANT,
ap.INDICE_APERTURA_ANIO_ANT,
ap.POBLACION_VIVIENTE,
ap.POBLACION_TRABAJADORA,
ap.RANGO_ETARIO,
ap.GENERO,
a.ANIO,
a.CUATRIMESTRE,
a.NIVEL,
"APERTURA" as tipo
from am_pruebas ap left join apertura a on (ap.moc_zonas_id=a.moc_zonas_id and ap.rubro=a.rubro)
union all
select  ap.MOC_ZONAS_ID,
ap.POBLACION_FLOTANTE,
ap.CANTIDAD_HOGARES,
ap.PRECIO_PROMEDIO_ALQUILER_LOCAL,
ap.PRECIO_MAX_ALQUILER_LOCAL,
ap.PRECIO_MIN_ALQUILER_LOCAL,
ap.SUPERFICIE_M2_PROMEDIO_ALQUILER,
ap.SUPERFICIE_M2_MAX_ALQUILER,
ap.SUPERFICIE_M2_MIN_ALQUILER,
ap.RUBRO_PREDOMINANTE,
ap.FACTURACION_PROM_RUBRO_PREDOMINANTE,
ap.FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE,
ap.RUBRO_MENOS_PREDOMINANTE,
ap.PRECIO_PROMEDIO_VENTA_LOCAL,
ap.PRECIO_MAX_VENTA_LOCAL,
ap.PRECIO_MIN_VENTA_LOCAL,
ap.SUPERFICIE_M2_PROMEDIO_VENTA,
ap.SUPERFICIE_M2_MAX_VENTA,
ap.SUPERFICIE_M2_MIN_VENTA,
ap.NIVEL_LOCALES_RUBRO_PREDOMINANTE,
ap.NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE,
ap.MOC_RUBROS_ID,
ap.RUBRO,
ap.NIVEL_RIESGO,
ap.FACTURACION_PROM_ACTUAL,
ap.INDICE_CRECIMIENTO,
ap.INDICE_ESTABILIDAD,
ap.INDICE_APERTURA,
ap.INDICE_CIERRE,
ap.INDICE_SUPERVIVENCIA,
ap.IND_AP_ACT_VS_IND_AP_ANIO_ANT,
ap.IND_CL_ACT_VS_IND_CL_ANIO_ANT,
ap.SUP_MENOS_1,
ap.SUP_ENTRE_1_Y_2,
ap.SUP_ENTRE_2_Y_3,
ap.SUP_ENTRE_3_Y_4,
ap.SUP_ENTRE_4_Y_5,
ap.SUP_MAS_5,
ap.FACTURACION_PROM_ANIO_ANT,
ap.NIVEL_LOCALES,
ap.INDICE_CIERRE_ANIO_ANT,
ap.INDICE_APERTURA_ANIO_ANT,
ap.POBLACION_VIVIENTE,
ap.POBLACION_TRABAJADORA,
ap.RANGO_ETARIO,
ap.GENERO,
a.ANIO,
a.CUATRIMESTRE,
a.NIVEL,
"CIERRE" as tipo
from am_pruebas ap left join cierre a on (ap.moc_zonas_id=a.moc_zonas_id and ap.rubro=a.rubro);


CREATE TABLE `dataset_final` (
  `MOC_ZONAS_ID` int DEFAULT NULL,
  `POBLACION_FLOTANTE` int DEFAULT NULL,
  `CANTIDAD_HOGARES` int DEFAULT NULL,
  `PRECIO_PROMEDIO_ALQUILER_LOCAL` double DEFAULT NULL,
  `PRECIO_MAX_ALQUILER_LOCAL` double DEFAULT NULL,
  `PRECIO_MIN_ALQUILER_LOCAL` double DEFAULT NULL,
  `SUPERFICIE_M2_PROMEDIO_ALQUILER` double DEFAULT NULL,
  `SUPERFICIE_M2_MAX_ALQUILER` double DEFAULT NULL,
  `SUPERFICIE_M2_MIN_ALQUILER` double DEFAULT NULL,
  `RUBRO_PREDOMINANTE` mediumtext,
  `FACTURACION_PROM_RUBRO_PREDOMINANTE` int DEFAULT NULL,
  `FACTURACION_PROM_RUBRO_MENOS_PREDOMINANTE` int DEFAULT NULL,
  `RUBRO_MENOS_PREDOMINANTE` mediumtext,
  `PRECIO_PROMEDIO_VENTA_LOCAL` double DEFAULT NULL,
  `PRECIO_MAX_VENTA_LOCAL` double DEFAULT NULL,
  `PRECIO_MIN_VENTA_LOCAL` double DEFAULT NULL,
  `SUPERFICIE_M2_PROMEDIO_VENTA` double DEFAULT NULL,
  `SUPERFICIE_M2_MAX_VENTA` double DEFAULT NULL,
  `SUPERFICIE_M2_MIN_VENTA` double DEFAULT NULL,
  `NIVEL_LOCALES_RUBRO_PREDOMINANTE` int DEFAULT NULL,
  `NIVEL_LOCALES_RUBRO_MENOS_PREDOMINANTE` int DEFAULT NULL,
  `MOC_RUBROS_ID` int DEFAULT NULL,
  `RUBRO` mediumtext,
  `NIVEL_RIESGO` bigint DEFAULT NULL,
  `FACTURACION_PROM_ACTUAL` double DEFAULT NULL,
  `INDICE_CRECIMIENTO` double DEFAULT NULL,
  `INDICE_ESTABILIDAD` double DEFAULT NULL,
  `INDICE_APERTURA` double DEFAULT NULL,
  `INDICE_CIERRE` double DEFAULT NULL,
  `INDICE_SUPERVIVENCIA` double DEFAULT NULL,
  `IND_AP_ACT_VS_IND_AP_ANIO_ANT` double DEFAULT NULL,
  `IND_CL_ACT_VS_IND_CL_ANIO_ANT` double DEFAULT NULL,
  `SUP_MENOS_1` double DEFAULT NULL,
  `SUP_ENTRE_1_Y_2` double DEFAULT NULL,
  `SUP_ENTRE_2_Y_3` double DEFAULT NULL,
  `SUP_ENTRE_3_Y_4` double DEFAULT NULL,
  `SUP_ENTRE_4_Y_5` double DEFAULT NULL,
  `SUP_MAS_5` double DEFAULT NULL,
  `FACTURACION_PROM_ANIO_ANT` double DEFAULT NULL,
  `NIVEL_LOCALES` mediumtext,
  `INDICE_CIERRE_ANIO_ANT` double DEFAULT NULL,
  `INDICE_APERTURA_ANIO_ANT` double DEFAULT NULL,
  `POBLACION_VIVIENTE` int DEFAULT NULL,
  `POBLACION_TRABAJADORA` int DEFAULT NULL,
  `RANGO_ETARIO` mediumtext,
  `GENERO` mediumtext,
  `ANIO` int DEFAULT NULL,
  `CUATRIMESTRE` int DEFAULT NULL,
  `NIVEL` int DEFAULT NULL,
  `tipo` varchar(8) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DROP table if EXISTS zonas_geograficas;
CREATE TABLE zonas_geograficas (
    MOC_ZONAS_ID int PRIMARY key,
    radios VARCHAR(50),
    geometry GEOMETRY NOT NULL
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

create index idx_apertura_moc_id on apertura(moc_zonas_id);

mysql -u admin -p geoprediccion < insert_zonas.sql

create table dataset_final_geo as
select df.*, zg.geometry
from dataset_final df join zonas_geograficas zg on (df.MOC_ZONAS_ID=zg.MOC_ZONAS_ID);
