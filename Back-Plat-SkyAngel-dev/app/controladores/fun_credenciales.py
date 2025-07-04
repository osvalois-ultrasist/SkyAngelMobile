
from app.modelos.conection_bd import Conection_BD
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token


# Esta funcion revisa la informacion recibida 
def Rev_info_Registro(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: usuario, correo, contraseña = Info['usuario'],Info['correo'],Info['contraseña']
    except: return False
    
    # Si se tiene toda la informacion
    return True

# Esta funcion revisa si el correo fue registrado ya existe en la bd
def Rev_UserName(Info):
    
    # Obtenemos los parametros y verifico si el correo existe en la bd
    correo, contraseña = Info['correo'],Info['contraseña'] 
    Con_BD = Conection_BD()
    Res = Con_BD.Run_query("SELECT EXISTS (SELECT 1 FROM usuarios WHERE correo = '"+correo+"')")

    return Res.iloc[0]['exists']

# Esta funcion inserta el usuario en la bd de usuarios
def Insertar_Usuario(Info):
    
    usuario, correo, contraseña = Info['usuario'],Info['correo'],Info['contraseña'] 
    hashed_password = generate_password_hash(contraseña)
    Con_BD = Conection_BD()
    Con_BD.Run_InsertUser(usuario, correo, hashed_password)

# Esta funcion revisa la informacion recibida 
def Rev_info_Login(Info):
    
    # Reviso que el request tenga todos los datos completos y en el formato adecuado
    try: correo, contraseña = Info['correo'],Info['contraseña']
    except: return False
    
    # Si se tiene toda la informacion
    return True

# Esta funcion comprueba el usuario y la contraseña
def Check_Credenciales(Info):
    
    correo, contraseña = Info['correo'],Info['contraseña']
    Con_BD = Conection_BD()
    Res = Con_BD.Run_query("SELECT usuario, correo, password FROM usuarios WHERE correo = '" + correo+"'")
    if check_password_hash(Res.iloc[0]['password'],contraseña):
        access_token = create_access_token(identity=Res.iloc[0]['usuario'])
        respuesta = {
            'Mensaje': 'Credenciales Correctas',
            'Token': access_token
        }
        return respuesta,200
    else:
        return 'Usuario o contraseña incorrectos', 401