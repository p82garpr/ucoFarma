# app/routers/shoplist.py

from bson import ObjectId
from fastapi import APIRouter, HTTPException, Depends
from schemas.user import UserCreate, UserOut
from database import db
from auth.jwt_handler import verify_token
from routers.auth import oauth2_scheme

router = APIRouter()

@router.put("/{user_id}/add-shoplist", response_model=UserOut)
async def add_shoplist(user_id: str, cn: str, token: str = Depends(oauth2_scheme)):
    """
    Agregar un medicamento a la lista de compras de un usuario.

    - **user_id**: ID del usuario.
    - **cn**: código nacional (CN) del medicamento que se agregará a la lista de compras.
    - **token**: Token de autenticación JWT.
    
    Si el medicamento ya existe en la lista de medicinas del usuario y no estaba en la lista de compras, se agrega a esta.
    
    Devuelve el usuario con la lista de compras actualizada.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    - Lanza un error 403 si el medicamento no se encuentra en la lista de medicinas del usuario.
    - Lanza un error 403 si el medicamento ya está en la lista de compras del usuario.
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user: 
        raise HTTPException(status_code=402, detail="Usuario no encontrado")

    medicine_found = False
    for med in user["medicines"]:
        if med["cn"] == cn:
            if med["wished"] == False:
                med["wished"] = True
                medicine_found = True
                break
            elif med["wished"] == True:
                raise HTTPException(status_code=403, detail="Medicamento ya agregado a la lista de compras")
    
    if not medicine_found:
        raise HTTPException(status_code=403, detail="Medicamento no encontrado")
    
    await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user})
    return user
        
    

@router.delete("/{user_id}/delete-shoplist", response_model=UserOut)
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
    
    medicine_found = False
    for med in user["medicines"]:
        if med["cn"] == cn:
            if med["wished"] == True:
                med["wished"] = False
                medicine_found = True
                break
            elif med["wished"] == False:
                raise HTTPException(status_code=403, detail="Medicamento no agregado a la lista de compras")

    if not medicine_found:
        raise HTTPException(status_code=403, detail="Medicina no encontrada en la lista de compras")
    
    await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user})
    return user