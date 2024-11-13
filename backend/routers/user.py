# app/routers/user.py

from fastapi import APIRouter, HTTPException, Depends
from schemas.user import UserCreate, UserOut
from database import db
from auth.jwt_handler import verify_token
from models.user import User
from routers.auth import oauth2_scheme

router = APIRouter()

@router.post("/", response_model=UserOut)
async def create_user(user: UserCreate):
    
    # Hashea la contraseña antes de almacenarla (ej: bcrypt.hash)
    new_user = await db["users"].insert_one(user.dict())
    return await db["users"].find_one({"_id": new_user.inserted_id})

@router.get("/me", response_model=UserOut)
async def read_users_me(token: str = Depends(oauth2_scheme)):
    payload = verify_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")
    user = await db["users"].find_one({"email": payload["sub"]})
    if user is None:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user
