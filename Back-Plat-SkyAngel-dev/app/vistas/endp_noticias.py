from flask import Blueprint, jsonify
from app.controladores.fun_noticias import obtener_tweets_guardados

Noticias = Blueprint("Noticias", __name__)

@Noticias.route("/tweets", methods=["GET"])
def get_tweets():
    try:
        tweets = obtener_tweets_guardados()

        if tweets:
            response = jsonify(tweets)
            response.status_code = 200
            return response
        else:
            response = jsonify({"respuesta": "No se encontraron tweets."})
            response.status_code = 204
            return response

    except Exception as e:
        response = jsonify({"respuesta": f"Error al obtener los tweets: {str(e)}"})
        response.status_code = 500
        return response
