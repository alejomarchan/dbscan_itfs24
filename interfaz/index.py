
from flask import Flask, request, render_template, jsonify
from flask_cors import CORS
import joblib
import numpy as np
import os
import pandas as pd
import pickle
import random
from sklearn.cluster import DBSCAN
from shapely import wkt
from shapely.geometry import Polygon, Point

app = Flask(__name__)
# Habilitar CORS para todas las rutas
CORS(app)

# Obtener la ruta base del archivo actual
base_path = os.path.dirname(os.path.abspath(__file__))

# Construir la ruta completa
dbscan_path = os.path.join(base_path, 'data', 'dbscan_proyecto.pkl')
label_path = os.path.join(base_path, 'data', 'label_encoder.pkl')

# Cargar el modelo DBSCAN entrenado
dbscan = joblib.load(dbscan_path)

# Cargar el label_encoder
label_encoder = joblib.load(label_path)

# Cargar el DataFrame con los datos originales y convertir geometry de WKT a Polygon
dataset_path = os.path.join(base_path, 'data', 'dataset_con_clusters.csv')
df = pd.read_csv(dataset_path)
df['geometry'] = df['geometry'].apply(wkt.loads)  # Convertir WKT a objetos Polygon de shapely


@app.route('/')
def index():
    try:
        # Obtener los rubros únicos
        rubros_encoded = df['RUBRO_ENCODED'].unique()
        rubros = label_encoder.inverse_transform(rubros_encoded).tolist()
        rubros = list(set(rubros))  # Eliminar duplicados
        rubros.sort()  # Ordenar alfabéticamente

        # Obtener los IDs únicos de las zonas (clusters)
        zonas_ids = df['MOC_ZONAS_ID'].dropna().unique().tolist()
        zonas_ids.sort()  # Ordenar los IDs de las zonas

        return render_template('index.html', rubros=rubros, zonas_ids=zonas_ids)
    except Exception as e:
        return f"Error al obtener los datos: {e}"



@app.route('/get_rubros')
def get_rubros():
    try:
        # Obtener los rubros únicos del DataFrame
        rubros_encoded = df['RUBRO_ENCODED'].unique()
        rubros = label_encoder.inverse_transform(rubros_encoded).tolist()
        rubros = list(set(rubros))  # Eliminar duplicados
        rubros.sort()  # Ordenar alfabéticamente
        return jsonify({'rubros': rubros})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_zonas')
def get_zonas():
    try:
        rubro_seleccionado = request.args.get('rubro')

        # Convertir el rubro seleccionado a su valor codificado
        if rubro_seleccionado in label_encoder.classes_:
            rubro_codificado = label_encoder.transform([rubro_seleccionado])[0]
        else:
            return jsonify({'error': 'Rubro no válido'}), 400

        # Filtrar el DataFrame por el rubro codificado
        df_filtered = df[df['RUBRO_ENCODED'] == rubro_codificado].copy()

        # Usar los centroides de los polígonos para aplicar DBSCAN
        X = df_filtered[['centroid_latitude', 'centroid_longitude']].values
        clustering = dbscan.fit(X)

        df_filtered['cluster'] = clustering.labels_

        # Calcular percentiles para determinar colores
        q25 = df_filtered['probabilidad_exito'].quantile(0.25)  # Percentil 25%
        q50 = df_filtered['probabilidad_exito'].quantile(0.5)
        q75 = df_filtered['probabilidad_exito'].quantile(0.75)
        iqr = q75 - q25  # Rango intercuartílico

        # Definir límites para las zonas
        low_limit = q25 - (1.5 * iqr)  # Valores muy bajos
        high_limit = q75 + (1.5 * iqr)  # Valores muy altos

        zonas = []
        for _, row in df_filtered.iterrows():
            if row['probabilidad_exito'] < q25:
                color = 'red'
            elif q25 <= row['probabilidad_exito'] < q50:
                color = 'orange'
            elif q50 <= row['probabilidad_exito'] < q75:
                color = 'blue'
            else:
                color = 'DarkGreen'

            # Extraer las coordenadas del polígono
            polygon = row['geometry']
            if isinstance(polygon, Polygon):
                polygon_coordinates = [[lat, lng] for lng, lat in polygon.exterior.coords]
            else:
                polygon_coordinates = []

            zona = {
                'polygon': polygon_coordinates,
                'color': color,
                'probabilidad_exito': round(row.get('probabilidad_exito', 0), 2),
                'id': row['MOC_ZONAS_ID']
            }
            zonas.append(zona)

        return jsonify({'zonas': zonas})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_rubros_por_zona')
def get_rubros_por_zona():
    # Obtener el parámetro zona_id desde la solicitud
    zona_id = request.args.get('zona_id')
    print("Zona ID recibido:", zona_id)  # Verificar qué llega al backend

    try:
        # Validar que zona_id no sea None y sea convertible a entero
        if not zona_id or not zona_id.isdigit():
            return jsonify({'error': 'Zona ID no válido. Por favor selecciona una zona válida.'}), 400
        
        zona_id = int(zona_id)  # Convertir a entero
        print("Zona ID convertido a entero:", zona_id)

        # Filtrar el DataFrame para encontrar la zona
        df_filtered = df[df['MOC_ZONAS_ID'] == zona_id]
        if df_filtered.empty:
            return jsonify({'error': 'Zona no encontrada. Verifica la selección.'}), 404

        # Obtener las coordenadas del polígono
        zona_geometry = df_filtered.iloc[0]['geometry']
        if not isinstance(zona_geometry, Polygon):
            return jsonify({'error': 'Datos de geometría no válidos para la zona seleccionada.'}), 500

        polygon_coordinates = [[lat, lng] for lng, lat in zona_geometry.exterior.coords]
        
        # Obtener los rubros de la zona, ordenados por probabilidad
        rubros = df_filtered[['RUBRO', 'probabilidad_exito']].sort_values(
            by='probabilidad_exito', ascending=False
        ).head(5).to_dict(orient='records')

        return jsonify({
            'zona': {'polygon': polygon_coordinates},
            'rubros': [{'nombre': r['RUBRO'], 'probabilidad': round(r['probabilidad_exito'], 2)} for r in rubros]
        })

    except ValueError:
        # Manejar el caso en que zona_id no sea convertible a entero
        return jsonify({'error': 'Zona ID no válido. Por favor selecciona una zona válida.'}), 400

    except Exception as e:
        # Manejar cualquier otro error inesperado
        print("Error inesperado:", str(e))
        return jsonify({'error': f'Error interno: {str(e)}'}), 500



@app.route('/buscar_zona')
def buscar_zona():
    try:
        lat = float(request.args.get('lat'))
        lon = float(request.args.get('lon'))
        point = Point(lon, lat)

        # Buscar en qué zona se encuentra el punto
        for _, row in df.iterrows():
            polygon = row['geometry']
            if polygon.contains(point):
                return jsonify({
                    'zona_id': row['cluster'],  # Asegúrate de usar el identificador correcto
                    'nombre': f"Zona {row['cluster']}"
                })

        return jsonify({'error': 'No se encontró una zona que contenga el punto'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/get_all_cluster_points', methods=['GET'])
def get_all_cluster_points():
    try:
        if df is None:
            return jsonify({'error': 'Data not loaded'}), 500

        num_puntos = 5  # Número de puntos aleatorios por polígono
        puntos_aleatorios = []

        # Iterar sobre cada fila del DataFrame
        for _, row in df.iterrows():
            poligono = row['geometry']  # Obtener el polígono de la fila
            cluster = row['cluster']  # Obtener el ID del cluster
            rubro = row['RUBRO']  # Obtener el rubro asociado a la fila

            # Generar puntos aleatorios dentro del polígono
            puntos = generar_puntos_aleatorios_en_poligono(poligono, num_puntos)

            # Agregar los puntos generados al resultado final
            for punto in puntos:
                puntos_aleatorios.append({
                    'latitude': punto.y,
                    'longitude': punto.x,
                    'cluster': cluster,
                    'rubro': rubro
                })

        # Retornar los puntos generados como JSON
        return jsonify({'points': puntos_aleatorios})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# Función para generar puntos aleatorios dentro de un polígono
def generar_puntos_aleatorios_en_poligono(poligono, num_puntos):
    puntos = []
    minx, miny, maxx, maxy = poligono.bounds  # Limites del polígono
    while len(puntos) < num_puntos:
        # Generar puntos aleatorios dentro de los límites del polígono
        random_point = Point(np.random.uniform(minx, maxx), np.random.uniform(miny, maxy))
        if poligono.contains(random_point):
            puntos.append(random_point)
    return puntos


if __name__ == '__main__':
    app.run(debug=True)
