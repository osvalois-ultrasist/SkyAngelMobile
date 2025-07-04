import boto3
import json

class Conexion_S3():
    
    def __init__(self):
        self.s3 = boto3.client('s3', region_name='us-east-1')
    
    # Metodo para verificar el acceso al bucket
    def CheckBucket(self,BucketName):
        try:
            response = self.s3.list_objects_v2(Bucket=BucketName)
            return True,'Acceso exitoso al bucket '+ BucketName
        except:
            return False,'Acceso fallido al bucket '+ BucketName
            
    # Metodo para cargar un archivo desde S3
    def CargarArchivo(self,BucketName,Ruta):
        response = self.s3.get_object(Bucket=BucketName, Key=Ruta)
        return response