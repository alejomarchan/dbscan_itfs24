from flask import Flask, request, render_template, jsonify
import joblib
import os
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.cluster import DBSCAN
from shapely import wkt
from shapely.geometry import Polygon

app = Flask(__name__)

# Obtener la ruta base del archivo actual
base_path = os.path.dirname(os.path.abspath(__file__))

# Construir la ruta completa
dbscan_path = os.path.join(base_path, 'data', 'dbscan_proyecto.pkl')
label_path = os.path.join(base_path, 'data', 'label_encoder.pkl')

# Cargar el modelo DBSCAN entrenado (aunque recalcularemos dinámicamente)
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
        # Obtener los rubros únicos del DataFrame
        rubros_encoded = df['RUBRO_ENCODED'].unique()
        rubros = label_encoder.inverse_transform(rubros_encoded).tolist()
        
        # Eliminar duplicados (por si hay repetidos)
        rubros = list(set(rubros))

        # Ordenar los rubros alfabéticamente
        rubros.sort()

        return render_template('index.html', rubros=rubros)
    except Exception as e:
        return f"Error al obtener los rubros: {e}"


@app.route('/get_rubros')
def get_rubros():
    try:
        # Obtener los rubros únicos del DataFrame
        rubros = label_encoder.inverse_transform(df['RUBRO_ENCODED'].unique()).tolist()
        rubros = list(set(rubros))
        rubros.sort()  # Ordenar los rubros alfabéticamente
        print(rubros)
        return jsonify({'rubros': rubros})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/get_zonas')
def get_zonas():    
    rubro_seleccionado = request.args.get('rubro')

    # Convertir el rubro seleccionado a su valor codificado
    if rubro_seleccionado in label_encoder.classes_:
        rubro_codificado = label_encoder.transform([rubro_seleccionado])[0]
    else:
        return jsonify({'error': 'Rubro no válido'}), 400

    # Filtrar el DataFrame por el rubro codificado, y hacer una copia para evitar el SettingWithCopyWarning
    df_filtered = df[df['RUBRO_ENCODED'] == rubro_codificado].copy()

    # Usamos los centroides de los polígonos para aplicar DBSCAN
    X = df_filtered[['centroid_latitude', 'centroid_longitude']].values
    clustering = dbscan.fit(X)

    # Añadir la columna de los clústeres al DataFrame filtrado
    df_filtered['cluster'] = clustering.labels_

    # Cálculo de percentiles para la puntuación de éxito
    q50 = df_filtered['probabilidad_exito'].quantile(0.5)
    q75 = df_filtered['probabilidad_exito'].quantile(0.75)

    zonas = []
    for _, row in df_filtered.iterrows():
        if row['cluster'] == -1:
            color = 'gray'
        elif row['probabilidad_exito'] < q50:
            color = 'red'
        elif q50 <= row['probabilidad_exito'] < q75:
            color = 'blue'
        else:
            color = 'green'

        # Extraer las coordenadas del polígono para Leaflet
        polygon = row['geometry']
        if isinstance(polygon, Polygon):
            polygon_coordinates = [[lat, lng] for lng, lat in polygon.exterior.coords]
        else:
            polygon_coordinates = []

        zona = {
            'polygon': polygon_coordinates,
            'color': color
        }
        zonas.append(zona)

    print("Zonas JSON:", zonas)  # Agregar para depuración
    return jsonify({'zonas': zonas})

if __name__ == '__main__':
    app.run(debug=True)