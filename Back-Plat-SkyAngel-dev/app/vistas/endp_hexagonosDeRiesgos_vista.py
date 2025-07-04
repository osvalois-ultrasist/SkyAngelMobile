import json
import boto3
import os
from flask import Blueprint, request, jsonify
from app.configuraciones.config import Config
from botocore.exceptions import NoCredentialsError, ClientError
from app.configuraciones.rutas_archivos import BUCKET_NAME, KEY_DATOS_HEXAGONOS 

# Se crea la coleccion de endpoints                           
hexagonosDeRiesgo = Blueprint('hexagonosDeRiesgo', __name__)
      
@hexagonosDeRiesgo.route("/mallado/riesgos", methods=["GET"])
def hexagonosDeRiesgo_get():
    try:
        
        # Crear un cliente de S3
        # s3 = boto3.client('s3',aws_access_key_id=Config.ACCESS, aws_secret_access_key=Config.SECRET)
        s3 = boto3.client('s3', region_name='us-east-1')
        
        # Descargar el archivo JSON desde el bucket S3 usando las variables de rutas_archivos.py
        s3_response = s3.get_object(Bucket=BUCKET_NAME, Key=KEY_DATOS_HEXAGONOS)
        
        # Leer el contenido del archivo JSON
        data = json.loads(s3_response['Body'].read().decode('utf-8'))

       # Devolver el contenido del JSON
        return jsonify(data), 200
    except NoCredentialsError:
        return jsonify({"Error": "Credenciales no encontradas para acceder a S3"}), 403
    except ClientError as e:
        return jsonify({"Error": "Error en la solicitud a S3", "Detalles": str(e)}), 500
    except Exception as e:
        return jsonify({"Error": "No se pudo leer el archivo JSON", "Detalles": str(e)}), 500