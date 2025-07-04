from flask import Flask
from flask_cors import CORS
from app.configuraciones.config import Config
from flask_socketio import SocketIO
from flask_jwt_extended import (
    JWTManager, create_access_token, jwt_required, get_jwt_identity
)
from datetime import timedelta

# importamos eventos
from app.vistas.endp_alertas import register_alerta_events

# Credenciales
from app.vistas.endp_credenciales import credenciales

# importamos las colecciones 
from app.vistas.endp_time import Demo_Time
from app.vistas.endp_fargate import Prueba_Fargate
from app.vistas.endp_login import login
from app.vistas.endp_poligonos import Poligonos
from app.vistas.endp_mallado_municipios import Mallado_Mun
from app.vistas.endp_registro import registro
from app.vistas.endp_recup import recuperacion
from app.vistas.endp_cambio import cambio_pass
# SECRETARIADO
from app.vistas.endp_entidad import entidad
from app.vistas.endp_cat_bien_juridicio_afectado_vistas import cat_bien
from app.vistas.endp_cat_tipo_de_delito_vistas import cat_tipo
from app.vistas.endp_cat_subtipo_de_delito_vistas import cat_subtipo
from app.vistas.endp_cat_modalidad_vistas import cat_mod 
from app.vistas.endp_cat_delitos_secretariado_vistas import cat_delitos_sec 
from app.vistas.endp_delitos_secretariado_municipio_vistas import delsecmun 
from app.vistas.endp_sum_delitos_municipio_mes_vistas import sumdelmun  
from app.vistas.endp_catalogo_municipios_vistas import municipios  
from app.vistas.endp_json_delitos_vistas import json_delitos   
from app.vistas.endp_IdDelitosPorSubtipo import idDelitosPorSubtipo   
from app.vistas.endp_datosGeograficosMunicipios_vistas import municipiosDatosGeograficos  
from app.vistas.endp_datosGeograficosEntidad_vistas import entidadDatosGeograficos  
from app.vistas.endp_hexagonosDeRiesgos_vista import hexagonosDeRiesgo  
from app.vistas.endp_cat_anios_vistas import cat_anios
# ANERPV
from app.vistas.endp_cat_modalidad_anerpv_vistas import catModAn
from app.vistas.endp_sum_delitos_entidad_mes_modalidad_anerpv_vistas import modEntMes 
from app.vistas.endp_sum_delitos_municipio_mes_anerpv_vistas import delMunMes
from app.vistas.endp_sum_delitos_entidad_mes_anerpv_vistas import delEntMes
from app.vistas.endp_sum_delitos_nacional_mes_anerpv_vistas import delNacMes
# REACCIONES
from app.vistas.endp_reacciones_vistas import sumreacciones
# GRAFICAS  
from app.vistas.endp_cat_anios_vistas import cat_anios  
from app.vistas.endp_rutas import ruta
from app.vistas.endp_incidencias_por_anio import incidencias
from app.vistas.endpSecretariadoBarras import secBarras_bp
from app.vistas.endpSecretariadoBarrasEstado import secBarrasEstado_bp
from app.vistas.endpSecretariadoBarrasEstado import secBarrasMunicipio_bp
from app.vistas.endpSecretariadoBarrasEstado import secBarrasAcum_bp
from app.vistas.endpSecretariadoPieAnuales import secPieAnuales_bp
from app.vistas.endpSecretariadoPieAnuales import secPieTipoDeDelito_bp
from app.vistas.endpSecretariadoPieAnuales import secPieSubtipoDeDelito_bp
from app.vistas.endpSecretariadoPieAnuales import secPieModalidad_bp
from app.vistas.endpSecretariadoScatterAnioAnterior import secScatterAnioAnterior_bp
from app.vistas.graficasFuentesExternas_vista import GraficasFuentesExternas_bp
from app.vistas.graficas_fuenteExternaBarras_vistas import fuenteExternaBarras_bp
from app.vistas.graficas_fuenteExternaBarrasDias_vistas import fuenteExternaBarrasDias_bp
from app.vistas.graficas_fuenteExternaBarrasHorario_vistas import fuenteExternaBarrasHorario_bp
from app.vistas.graficas_fuenteExternaBarrasVehiculo_vistas import fuenteExternaBarrasVehiculo_bp
from app.vistas.graficas_fuenteExternaPie_vistas import fuenteExternaPie_bp
from app.vistas.graficas_fuenteExternaScatterAA_vistas import fuenteExternaScatter_bp
from app.vistas.graficas_fuenteExternaTabla_vistas import fuenteExternaTabla_bp
from app.vistas.graficas_fuenteExternaVelas_vistas import fuenteExternaVelas_bp
from app.vistas.graficas_secretariadoAAScatter_vistas import graficasSecScatterAnioAnterior_bp
from app.vistas.graficas_secretariadoAcumBarras_vistas import graficasSecBarrasAcum_bp
from app.vistas.graficas_secretariadoEstadoBarras_vistas import graficasSecBarrasEstado_bp
from app.vistas.graficas_secretariadoMunicipioBarras_vistas import graficasSecBarrasMunicipio_bp
from app.vistas.graficas_secretariadoDelitoBarras_vistas import graficasSecBarrasDelito_bp
from app.vistas.graficas_secretariadoModalidadBarras_vistas import graficasSecBarrasModalidad_bp
from app.vistas.graficas_secretariadoNivelesPie_vistas import secPieNiveles_bp
from app.vistas.graficas_reaccionesDelitoBarras_vistas import reaccionesBarrasDelito_bp
from app.vistas.graficas_reaccionesBarras_vistas import reaccionesBarras_bp
from app.vistas.graficas_reaccionesDiasBarras_vistas import reaccionesDiasBarras_bp
from app.vistas.graficas_reaccionesCentralBarras_vistas import reaccionesCentralBarras_bp
from app.vistas.graficas_reaccionesLineaBarras_vistas import reaccionesLineaBarras_bp
from app.vistas.graficas_reaccionesCachimbasBarras_vistas import reaccionesCachimbasBarras_bp
from app.vistas.graficas_reaccionesScatter_vistas import reaccionesScatter_bp
from app.vistas.graficas_reaccionesTabla_vistas import reaccionesTabla_bp
from app.vistas.mapas_vista import mapas_bp
from app.vistas.graficas_AcumuladoEstadoBarras_vistas import graficasAcumuladoBarrasEstado_bp
from app.vistas.graficas_AcumuladoPorBaseBarras_vistas import graficasAcumuladoBarrasPorBase_bp
#Popular-crimes
from app.vistas.subTipoDel_vista import listaSubtipoDelito_bp
from app.vistas.endp_json_getter_all import getterJsonAll_bp
from app.vistas.endp_json_getter_sec import getterJsonSec_bp
from app.vistas.end_json_getter_skyangel import getterJsonSky_bp
from app.vistas.endp_json_getter_fe import getterJsonFe_bp
from app.vistas.endp_json_getter_sky import getterJsonSky_bp
from app.vistas.graficas_popCrimesAll_vistas import graficasAllConsolidado_bp
from app.vistas.graficas_popCrimesSky_vistas import graficasSkyConsolidado_bp
from app.vistas.graficas_popCrimesSec_vistas import graficasSecConsolidado_bp
from app.vistas.graficas_popCrimesFe_vistas import graficasFeConsolidado_bp
# PUNTOS INTERES
from app.vistas.endp_puntos_interes import punto_interes
from app.vistas.endp_accidentes_transito_punto_interes import accidentes_transito_punto_interes
from app.vistas.endp_punto_ferroviarios import punto_ferroviarios
# NOTICIAS
from app.vistas.endp_noticias import Noticias
#ALERTAS
from app.vistas.endp_alertas_vistas import alerta_bp

from app.estaticos.cache.files_cache import LoadPoligonos, LoadGeopuntos, Cache_GPDPoligonos1km, Cache_GeopuntosSky

from flask import Blueprint, request, jsonify
def page_not_found(error):            
    response = jsonify({"respuesta": 'No se ha encontrado el endpoint'})
    response.status_code = 404
    return response

import boto3

# Crear cliente SSM
ssm_client = boto3.client('ssm', region_name='us-east-1')

# Obtenengo las ruta del front para el webSocket
Param_SKYFRONT_HOST= ssm_client.get_parameter(Name='SKYFRONT_HOST',WithDecryption=False)  # Cambia a True si algunos son SecureString
SKYFRONT_HOST = Param_SKYFRONT_HOST['Parameter']['Value']

# Inicializar extension socketio
socketio = SocketIO(cors_allowed_origins=SKYFRONT_HOST) 

# Defino una funcion para inicializar y diesplegar la aplicacion 
def create_app():
    
    # Adjunto las configuraciones de la aplicacion 
    app = Flask(__name__)
       
    CORS(app)
    
    
    # Parametros de manejo de tokens
    app.config['JWT_SECRET_KEY'] = Config.BACK_JWT_SECRET_KEY
    app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=24)  
    jwt = JWTManager(app)
    
    # Credenciales
    app.register_blueprint(credenciales, url_prefix="/")
    
    # Se agregan las colecciones de endponints a la app
    app.register_error_handler(404,page_not_found)    
    app.register_blueprint(Demo_Time, url_prefix="/")
    app.register_blueprint(Prueba_Fargate, url_prefix="/")
    app.register_blueprint(login, url_prefix="/")
    app.register_blueprint(Poligonos, url_prefix="/")
    app.register_blueprint(Mallado_Mun,url_prefix="/")
    app.register_blueprint(registro, url_prefix="/")
    app.register_blueprint(recuperacion, url_prefix="/")
    app.register_blueprint(cambio_pass, url_prefix="/")
    # SECRETARIADO
    app.register_blueprint(entidad, url_prefix="/")
    app.register_blueprint(cat_bien, url_prefix="/")
    app.register_blueprint(cat_tipo, url_prefix="/")
    app.register_blueprint(cat_subtipo, url_prefix="/")
    app.register_blueprint(cat_mod, url_prefix="/")
    app.register_blueprint(cat_delitos_sec, url_prefix="/")
    app.register_blueprint(delsecmun, url_prefix="/")
    app.register_blueprint(sumdelmun, url_prefix="/")
    app.register_blueprint(municipios, url_prefix="/")
    app.register_blueprint(json_delitos, url_prefix="/")
    app.register_blueprint(idDelitosPorSubtipo, url_prefix="/")
    app.register_blueprint(municipiosDatosGeograficos, url_prefix="/")
    app.register_blueprint(entidadDatosGeograficos, url_prefix="/")
    app.register_blueprint(hexagonosDeRiesgo, url_prefix="/")
    app.register_blueprint(cat_anios, url_prefix="/")
    # ANERPV
    app.register_blueprint(catModAn, url_prefix="/")
    app.register_blueprint(modEntMes, url_prefix="/")
    app.register_blueprint(delEntMes, url_prefix="/")
    app.register_blueprint(delMunMes, url_prefix="/")
    app.register_blueprint(delNacMes, url_prefix="/")
    # REACCIONES
    app.register_blueprint(sumreacciones, url_prefix="/")
    # GRAFICAS
    app.register_blueprint(incidencias, url_prefix="/")
    app.register_blueprint(secBarras_bp, url_prefix="/")
    app.register_blueprint(secBarrasEstado_bp, url_prefix="/")
    app.register_blueprint(secBarrasMunicipio_bp, url_prefix="/")
    app.register_blueprint(secBarrasAcum_bp, url_prefix="/")
    app.register_blueprint(secPieAnuales_bp, url_prefix="/")
    app.register_blueprint(secPieTipoDeDelito_bp, url_prefix="/")
    app.register_blueprint(secPieSubtipoDeDelito_bp, url_prefix="/")
    app.register_blueprint(secPieModalidad_bp, url_prefix="/")
    app.register_blueprint(secScatterAnioAnterior_bp, url_prefix="/")
    app.register_blueprint(GraficasFuentesExternas_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaBarras_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaBarrasDias_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaBarrasHorario_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaBarrasVehiculo_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaPie_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaScatter_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaTabla_bp, url_prefix="/")
    app.register_blueprint(fuenteExternaVelas_bp, url_prefix="/")
    app.register_blueprint(graficasSecScatterAnioAnterior_bp, url_prefix="/")
    app.register_blueprint(graficasSecBarrasAcum_bp, url_prefix="/")
    app.register_blueprint(graficasSecBarrasEstado_bp, url_prefix="/")
    app.register_blueprint(graficasSecBarrasMunicipio_bp, url_prefix="/")
    app.register_blueprint(graficasSecBarrasDelito_bp, url_prefix="/")
    app.register_blueprint(graficasSecBarrasModalidad_bp, url_prefix="/")
    app.register_blueprint(reaccionesBarrasDelito_bp, url_prefix="/")
    app.register_blueprint(reaccionesBarras_bp, url_prefix="/")
    app.register_blueprint(reaccionesDiasBarras_bp, url_prefix="/")
    app.register_blueprint(reaccionesCentralBarras_bp, url_prefix="/")
    app.register_blueprint(reaccionesLineaBarras_bp, url_prefix="/")
    app.register_blueprint(reaccionesCachimbasBarras_bp, url_prefix="/")
    app.register_blueprint(reaccionesScatter_bp, url_prefix="/")
    app.register_blueprint(reaccionesTabla_bp, url_prefix="/")
    app.register_blueprint(secPieNiveles_bp, url_prefix="/")
    app.register_blueprint(ruta, url_prefix="/")
    app.register_blueprint(mapas_bp, url_prefix="/")
    app.register_blueprint(graficasAcumuladoBarrasEstado_bp, url_prefix="/")
    app.register_blueprint(graficasAcumuladoBarrasPorBase_bp, url_prefix="/")
    
    #Popular-Crimes
    app.register_blueprint(graficasAllConsolidado_bp, url_prefix="/")
    app.register_blueprint(graficasSkyConsolidado_bp, url_prefix="/")
    app.register_blueprint(graficasSecConsolidado_bp, url_prefix="/")
    app.register_blueprint(graficasFeConsolidado_bp, url_prefix="/")
    app.register_blueprint(listaSubtipoDelito_bp, url_prfix="/")
    app.register_blueprint(getterJsonSec_bp, url_prefix="/")
    app.register_blueprint(getterJsonFe_bp, url_prefix="/")
    app.register_blueprint(getterJsonSky_bp, url_prefix="/")
    app.register_blueprint(getterJsonAll_bp, url_prefix="/")

    # PUNTOS INTERES
    app.register_blueprint(punto_interes, url_prefix="/")
    app.register_blueprint(accidentes_transito_punto_interes, url_prefix="/")
    app.register_blueprint(punto_ferroviarios, url_prefix="/")

    # NOTICIAS
    app.register_blueprint(Noticias, url_prefix="/")
    # ALERTAS
    app.register_blueprint(alerta_bp, url_prefix="/")

    # Inicializa Socket.IO con la app
    socketio.init_app(app, cors_allowed_origins=SKYFRONT_HOST)
    register_alerta_events(socketio)
    return app