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
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    user = await db["users"].find_one({"_id": ObjectId(user_id)})
    #print(user)
    if user:
        if "medicines" not in user:
            user["medicines"] = []
        #check if medicine already exists
        for med in user["medicines"]:
            if med["cn"] == medicine.cn:
                # medicine already exists, update quantity
                med["quantity"] += medicine.quantity
            else:
                user["medicines"].append(medicine.model_dump())
        await db["users"].update_one({"_id": ObjectId(user_id)}, {"$set": user}) # update user with new medicine 
        return user
    raise HTTPException(status_code=404, detail="Usuario no encontrado")
