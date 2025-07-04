"""
    Clase que maneja objetos Usuarios 
    extaídos de la tabla usuarios
    de la base de datos
"""
class Usuarios():
    def __init__(self,usuario,correo,password):
        self.usuario = usuario
        self.correo = correo
        self.password = password

    def __str__(self):
        return(
            "usuario: "+str(self.usuario)+" , "+
            "correo: "+str(self.correo)+" , "+
            "password: "+str(self.password)  
        )

    def to_json(self):
        return{
            "usuario" : self.usuario,
            "correo" : self.correo,
            "password" : self.password
        }
    
    def create_from_tuple(tuple):
        return Usuarios(tuple[0],tuple[1],tuple[2])
