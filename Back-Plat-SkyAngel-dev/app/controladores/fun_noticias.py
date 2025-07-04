import requests, time
from app.mapper.noticias_mapper import leer_tweets, guardar_tweets

#BEARER_TOKEN = "Token de acceso de Twitter"

# Función para obtener tweets guardados en archivo JSON
def obtener_tweets_guardados():
    return leer_tweets()

# Función para obtener nuevos tweets y guardarlos en archivo JSON
# def fetch_and_store_tweets(socketio):
#     while True:
#         headers = {"Authorization": f"Bearer {BEARER_TOKEN}"}
        
#         # Query que excluye retweets yrespuestas 
#         query = '''
#         from:SS_Edomex ("transportista" OR "robo a transportistas" OR "robo con violencia") 
#         -is:retweet -is:reply 
#         lang:es
#         '''
        
#         # Parámetros para obtener metadata de usuario
#         params = {
#             "query": query,
#             "max_results": 10,
#             "tweet.fields": "created_at,author_id",
#             "expansions": "author_id", 
#             "user.fields": "name,username,profile_image_url" 
#         }
        
#         url = "https://api.twitter.com/2/tweets/search/recent"
        
#         response = requests.get(url, headers=headers, params=params)
        
#         if response.status_code == 200:
#             data = response.json()
            
#             # Procesar tweets e información del usuario
#             tweets = []
#             if 'data' in data and 'includes' in data and 'users' in data['includes']:
#                 users = {user['id']: user for user in data['includes']['users']}
                
#                 for tweet in data['data']:
#                     author = users.get(tweet['author_id'])
#                     if author:  # Solo si existe el usuario
#                         tweets.append({
#                             "id": tweet['id'],
#                             "text": tweet['text'],
#                             "created_at": tweet['created_at'],
#                             "url": f"https://twitter.com/{author['username']}/status/{tweet['id']}",
#                             "user": {
#                                 "name": author['name'],
#                                 "username": author['username'],
#                                 "avatar": author['profile_image_url']
#                             }
#                         })
            
#             # Filtrar nuevos tweets
#             prev_data = leer_tweets()
#             ids_guardados = {tweet['id'] for tweet in prev_data}
#             nuevos = [tweet for tweet in tweets if tweet['id'] not in ids_guardados]
            
#             if nuevos:
#                 prev_data.extend(nuevos)
#                 guardar_tweets(prev_data)
#                 socketio.emit("nuevos_tweets", nuevos)
        
#         time.sleep(3600)  
