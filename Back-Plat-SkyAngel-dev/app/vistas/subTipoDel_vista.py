import json
from flask import Blueprint, request, jsonify
from app.controladores.subTipoDel_controlador import Subtipo_delito_service

listaSubtipoDelito_bp = Blueprint('/popular-crimes/cat-subtipo', __name__)

@listaSubtipoDelito_bp.route("/popular-crimes/cat-subtipo", methods=["GET"])
def get_subdelitos():
    if request.method == 'GET':
        service = Subtipo_delito_service()
        response, status_code = service.get_todos_subtipo() 
        return response, status_code