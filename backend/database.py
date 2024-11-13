# app/database.py

import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv() # Cargar las variables de entorno
settings = os.getenv("MONGODB_URL") # URL de la base de datos
client = AsyncIOMotorClient(settings) # Conexión a la base de datos
db = client['medicines_db']  # Nombre de la base de datos


# Testing the connection on a main
if __name__ == "__main__":
    print(client)
    print ("Conexión exitosa")
    print(db)