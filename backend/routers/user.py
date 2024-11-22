# app/routers/user.py

from bson import ObjectId
from fastapi import APIRouter, HTTPException, Depends
from schemas.user import UserCreate, UserOut, UserOutID
from database import db
from auth.jwt_handler import verify_token
from models.user import User
from routers.auth import oauth2_scheme
import bcrypt

router = APIRouter()

@router.post("/", response_model=UserOut)
async def create_user(user: UserCreate):
    """
    Crear un nuevo usuario en el sistema.

    - **user**: Objeto que contiene la información del usuario (nombre, email, contraseña, etc.).
    
    La contraseña del usuario debe almacenarse de forma segura, utilizando hashing (ej. bcrypt) antes de guardarla en la base de datos.
    
    Devuelve el nuevo usuario creado, incluyendo solo los datos públicos definidos en el esquema `UserOut`.
    
    """
    
    #comprobar si el email ya existe
    if await db["users"].find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="El email ya está registrado")
    
    # Hashea la contraseña antes de almacenarla
    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
    user.password = hashed_password.decode('utf-8')
    new_user = await db["users"].insert_one(user.dict())
    
    # Devuelve el usuario creado utilizando el ID de inserción en la base de datos
    return await db["users"].find_one({"_id": new_user.inserted_id})


@router.get("/me", response_model=UserOutID)
async def read_users_me(token: str = Depends(oauth2_scheme)):
    """
    Obtener la información del usuario autenticado.

    - **token**: Token de autenticación JWT.
    
    Utiliza el token JWT para recuperar y devolver la información del usuario autenticado.
    
    Devuelve la información del usuario en formato `UserOut`.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido o ha expirado.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos, lo que podría indicar un usuario eliminado o un email inválido en el token.
    """
    # Verificar el token JWT y extraer la carga útil
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")
    
    # Buscar al usuario en la base de datos mediante el email extraído del token
    user = await db["users"].find_one({"email": payload["sub"]})
    if user is None:
        raise HTTPException(status_code=402, detail="Usuario no encontrado")
    
    #añadir el object id de mongo a la respuesta
    user["user_id"] = str(user["_id"])
    
    return user

@router.put("/{user_id}", response_model=UserOut)
async def update_user(user_id: str, user: UserCreate, token: str = Depends(oauth2_scheme)):
    """
    Actualizar la información del usuario autenticado.

    - **user_id**: ID del usuario a actualizar.
    - **user**: Objeto que contiene los datos actualizados del usuario.
    - **token**: Token de autenticación JWT.

    Esta función permite a un usuario autenticado actualizar su información almacenada en la base de datos.

    Control de errores:
    - Lanza un error 401 si el token es inválido o ha expirado.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.

    Devuelve:
    - El usuario actualizado con la nueva información.
    """
    # Verificar token de autenticación
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")
    
    # Buscar el usuario a actualizar en la base de datos
    user_to_update = await db["users"].find_one({"_id": ObjectId(user_id)})
    if user_to_update is None:
        raise HTTPException(status_code=402, detail="Usuario no encontrado")
    
    # Actualizar la información del usuario en la base de datos
    await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user.dict()})
    
    # Devolver el usuario actualizado
    return await db["users"].find_one({"_id": ObjectId(user_id)})


