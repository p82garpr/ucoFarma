from fastapi import APIRouter, Depends, HTTPException
from typing import List
from datetime import datetime
from bson import ObjectId

from models.user import Dose, Medicine
from database import db
from auth.jwt_handler import verify_token
from routers.auth import oauth2_scheme

router = APIRouter(
    prefix="/doses",
    tags=["doses"]
)

# Get Dose -> Obtener una dosis para un usuario
@router.get("/{user_id}/{medicine_cn}", response_model=List[Dose])
async def get_medicine_doses(
    user_id: str,
    medicine_cn: str,
    token: str = Depends(oauth2_scheme)
):
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    medicine = next((med for med in user["medicines"] if med["cn"] == medicine_cn), None)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicina no encontrada")
    
    return medicine.get("doses", [])

# Put Dose -> Recibe user id, medicine cn, frecuency and quantity
@router.put("/{user_id}/{medicine_cn}", response_model=Dose)
async def update_dose(
    user_id: str,
    medicine_cn: str,
    frequency: int,
    quantity: float,
    token: str = Depends(oauth2_scheme)
):
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    medicine = next((med for med in user["medicines"] if med["cn"] == medicine_cn), None)
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicina no encontrada")
    
    if not medicine.get("doses"):
        raise HTTPException(status_code=404, detail="No existe una dosis para este medicamento")
    
    # Crear la dosis actualizada
    updated_dose = Dose(frequency=frequency, quantity=quantity)
    
    # Actualizar la dosis (siempre será la primera ya que solo permitimos una)
    medicine["doses"] = [updated_dose.dict()]
    
    await db["users"].update_one(
        {"_id": ObjectId(user_id), "medicines.cn": medicine_cn},
        {"$set": {"medicines.$.doses": medicine["doses"]}}
    )
    
    return updated_dose

