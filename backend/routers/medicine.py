# app/routers/medicine.py

from fastapi import APIRouter, Depends, HTTPException
from database import db
from auth.jwt_handler import verify_token
from models.user import Medicine
from schemas.user import UserOut
from routers.auth import oauth2_scheme
from bson import ObjectId

router = APIRouter()

@router.post("/{user_id}/add-medicine", response_model=UserOut)
async def add_medicine(user_id: str, medicine: Medicine, token: str = Depends(oauth2_scheme)):
    """
    Agregar un medicamento al inventario de un usuario.

    - **user_id**: ID del usuario.
    - **medicine**: Objeto del medicamento que se agregará.
    - **token**: Token de autenticación JWT.
    
    Si el medicamento ya existe en el inventario del usuario, su cantidad se actualiza sumando la cantidad proporcionada.
    
    Devuelve el usuario con el inventario de medicamentos actualizado.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if user:
        if "medicines" not in user:
            user["medicines"] = []
        # Verificar si el medicamento ya existe
        for med in user["medicines"]:
            if med["cn"] == medicine.cn:
                # Si ya existe, actualizar cantidad
                med["quantity"] += medicine.quantity
                break
        else:
            user["medicines"].append(medicine.model_dump())
        await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user}) # Actualizar usuario con el nuevo medicamento 
        return user
    raise HTTPException(status_code=402, detail="Usuario no encontrado")



@router.delete("/{user_id}/delete-medicine/{cn}", response_model=UserOut)
async def delete_medicine(user_id: str, cn: str, token: str = Depends(oauth2_scheme)):
    """
    Eliminar un medicamento específico del inventario de un usuario.

    - **user_id**: ID del usuario.
    - **cn**: Código Nacional (CN) del medicamento que se eliminará.
    - **token**: Token de autenticación JWT.
    
    Verifica si el usuario y el medicamento existen en la base de datos. Si el medicamento existe, lo elimina del inventario del usuario.
    
    Devuelve el usuario con el inventario actualizado.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    - Lanza un error 404 si el medicamento no se encuentra en el inventario del usuario.
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
            user["medicines"].remove(med)
            medicine_found = True
            break

    if not medicine_found:
        raise HTTPException(status_code=403, detail="Medicina no encontrada")
    
    await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user})
    return user
