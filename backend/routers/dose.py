from fastapi import APIRouter, Depends, HTTPException
from typing import List
from bson import ObjectId

from models.user import Dose
from database import db
from auth.jwt_handler import verify_token
from routers.auth import oauth2_scheme

router = APIRouter(
    tags=["doses"]
)

@router.get("/{user_id}/{medicine_cn}", response_model=List[Dose])
async def get_medicine_doses(
    user_id: str,
    medicine_cn: str,
    token: str = Depends(oauth2_scheme)
):
    """
    Obtener las dosis de un medicamento específico para un usuario.

    - **user_id**: ID del usuario.
    - **medicine_cn**: Código Nacional (CN) del medicamento.
    - **token**: Token de autenticación JWT.
    
    Devuelve una lista de dosis para el medicamento específico del usuario.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    - Lanza un error 403 si el medicamento no se encuentra en el inventario del usuario.
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=402, detail="Usuario no encontrado")
    
    # Verificar si el medicamento existe en el inventario del usuario
    medicine = next((med for med in user["medicines"] if med["cn"] == medicine_cn), None)
    if not medicine:
        raise HTTPException(status_code=403, detail="Medicina no encontrada")
    
    # Devolver la lista de dosis, o una lista vacía si no hay dosis registradas
    return medicine.get("doses", [])


@router.put("/{user_id}/{medicine_cn}", response_model=Dose)
async def update_dose(
    user_id: str,
    medicine_cn: str,
    frequency: int,
    quantity: int,
    startDate: str,
    endDate: str,
    token: str = Depends(oauth2_scheme)
):
    """
    Actualizar la dosis de un medicamento para un usuario específico.

    - **user_id**: ID del usuario.
    - **medicine_cn**: Código Nacional (CN) del medicamento.
    - **frequency**: Frecuencia de la dosis (en horas).
    - **quantity**: Cantidad de la dosis.
    - **startDate**: Fecha de inicio de la dosis.
    - **endDate**: Fecha de fin de la dosis.
    - **token**: Token de autenticación JWT.
    
    Devuelve la dosis actualizada para el medicamento específico del usuario.
    
    Control de errores:
    - Lanza un error 401 si el token es inválido.
    - Lanza un error 402 si el usuario no se encuentra en la base de datos.
    - Lanza un error 403 si el medicamento no se encuentra en el inventario del usuario.
    - Lanza un error 404 si no existe una dosis previa para el medicamento (para evitar crear nuevas dosis).
    """
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=402, detail="Usuario no encontrado")
    
    # Verificar si el medicamento existe en el inventario del usuario
    medicine = next((med for med in user["medicines"] if med["cn"] == medicine_cn), None)
    if not medicine:
        raise HTTPException(status_code=403, detail="Medicina no encontrada")
    
    # Verificar que el medicamento tenga una dosis registrada
    if not medicine.get("doses"):
        raise HTTPException(status_code=404, detail="No existe una dosis para este medicamento")
    
    # Crear la dosis actualizada
    updated_dose = Dose(frequency=frequency, quantity=quantity, startDate=startDate, endDate=endDate)
    
    # Actualizar la dosis (siempre será la primera, ya que solo se permite una dosis)
    medicine["doses"] = [updated_dose.dict()]
    
    # Actualizar el documento del usuario en la base de datos
    await db["users"].update_one(
        {"_id": ObjectId(user_id), "medicines.cn": medicine_cn},
        {"$set": {"medicines.$.doses": medicine["doses"]}}
    )
    
    return updated_dose
