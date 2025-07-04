import json
from collections import OrderedDict
from app.mapper.punto_interes_accidentes_transito_mapper import *
import numpy as np
import pandas as pd

def select_accidentes_transito():
    consulta = obtener_datos()  # DataFrame con la consulta ya hecha
    
    # Asegurar que las coordenadas sean float
    consulta["latitud_centroide"] = consulta["latitud_centroide"].astype(float)
    consulta["longitud_centroide"] = consulta["longitud_centroide"].astype(float)
    
    # Modificamos las coordenadas del mismo municipio para que rooden al municipio y se visualizen mejor lo puntos
    consulta = distribuir_puntos_en_triangulo(consulta, radio=0.15)

    geojson = OrderedDict({
        "type": "FeatureCollection",
        "features": []
    })
    
    for _, row in consulta.iterrows():
        feature = OrderedDict({
            "type": "Feature",
            "geometry": OrderedDict({
                "type": "Point",
                "coordinates": [row["longitud_centroide"], row["latitud_centroide"]]
            }),
            "properties": OrderedDict({
                "Entidad": row["entidad"],
                "Tipo": row["tipo"],

                # Periodos de años (aunque son constantes, las dejo para mostrar)
                "Periodo de años ": row["anio_2018_2020"],
                "Total ": int(row["total_2018_2020"]),
                "Libre ": int(row["libre_2018_2020"]),
                "Cuota ": int(row["cuota_2018_2020"]),
                
                "Periodo de años  ": row["anio_2021_2023"],
                "Total  ": int(row["total_2021_2023"]),
                "Libre  ": int(row["libre_2021_2023"]),
                "Cuota  ": int(row["cuota_2021_2023"]),
                
            })
        })
        geojson["features"].append(feature)
    
    geojson_str = json.dumps(geojson, indent=2, ensure_ascii=False)
    
    return geojson_str

def distribuir_puntos_en_triangulo(df, radio=0.02):
    """
    Para cada grupo (entidad), asigna 3 coordenadas en forma de triángulo equilátero alrededor del punto central.
    radio: en grados, aprox (0.01 es aprox 1km)
    """
    resultados = []
    
    # Ángulos para un triángulo equilátero (3 vértices separados 120°)
    angulos = np.array([0, 2*np.pi/3, 4*np.pi/3])
    
    for entidad, grupo in df.groupby('entidad'):
        lat_centro = grupo['latitud_centroide'].iloc[0]
        lon_centro = grupo['longitud_centroide'].iloc[0]

        n_registros = len(grupo)
        
        # Usar solo el número real de registros si es menor que 3
        n_asignar = min(3, n_registros)

        # Calcular nuevas coordenadas para los n_asignar puntos
        latitudes = lat_centro + radio * np.sin(angulos[:n_asignar])
        longitudes = lon_centro + radio * np.cos(angulos[:n_asignar])

        # Si hay más registros que 3, repetir las coordenadas para cubrirlos
        if n_registros > 3:
            latitudes = np.resize(latitudes, n_registros)
            longitudes = np.resize(longitudes, n_registros)

        grupo = grupo.copy()
        grupo['latitud_centroide'] = latitudes
        grupo['longitud_centroide'] = longitudes

        resultados.append(grupo)

    df_result = pd.concat(resultados).reset_index(drop=True)

    return df_result