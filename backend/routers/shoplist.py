# app/routers/shoplist.py

from bson import ObjectId
from fastapi import APIRouter, HTTPException, Depends
from schemas.user import UserCreate, UserOut
from database import db
from auth.jwt_handler import verify_token
from routers.auth import oauth2_scheme
from models.user import Shoplist

router = APIRouter()

@router.post("/{user_id}/add-shoplist", response_model=UserOut)
async def add_shoplist(user_id: str, shoplist: Shoplist, token: str = Depends(oauth2_scheme)):
    """
    Agregar un medicamento a la lista de compras de un usuario.

    - **user_id**: ID del usuario.
    - **shoplist**: Objeto del medicamento que se agregará a la lista de compras.
    - **token**: Token de autenticación JWT.
    
    Si el medicamento ya existe en la lista de compras del usuario, su cantidad se actualiza sumando la cantidad proporcionada.
    
    Devuelve el usuario con la lista de compras actualizada.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if user:
        if "shoplist" not in user:
            user["shoplist"] = []
            
        # Verificar si el medicamento ya existe en la lista de compras
        for item in user["shoplist"]:
            if item["cn"] == shoplist.cn:
                # Si ya existe, actualizar cantidad
                item["quantity"] += shoplist.quantity
                break
        else:
            # Si no existe, agregar a la lista
            user["shoplist"].append(shoplist.model_dump())
            
        await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user})
        return user
        
    raise HTTPException(status_code=402, detail="Usuario no encontrado")


@router.delete("/{user_id}/delete-shoplist/{cn}", response_model=UserOut)
async def delete_shoplist(user_id: str, cn: str, token: str = Depends(oauth2_scheme)):
    """
    Eliminar un medicamento específico de la lista de compras de un usuario.

    - **user_id**: ID del usuario.
    - **cn**: Código Nacional (CN) del medicamento que se eliminará.
    - **token**: Token de autenticación JWT.
    
    Verifica si el usuario y el medicamento existen en la base de datos. Si el medicamento existe, lo elimina de la lista de compras del usuario.
    
    Devuelve el usuario con la lista de compras actualizada.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    - Lanza un error 403 si el medicamento no se encuentra en la lista de compras del usuario.
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=402, detail="Usuario no encontrado")
    
    if "shoplist" not in user:
        raise HTTPException(status_code=403, detail="Lista de compras vacía")
    
    medicine_found = False
    for med in user["shoplist"]:
        if med["cn"] == cn:
            user["shoplist"].remove(med)
            medicine_found = True
            break

    if not medicine_found:
        raise HTTPException(status_code=403, detail="Medicina no encontrada en la lista de compras")
    
    await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user})
    return user