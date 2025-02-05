# app/routers/auth.py

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from schemas.user import Token
from auth.jwt_handler import create_access_token, verify_token
from database import db
from pydantic import BaseModel
import bcrypt

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

router = APIRouter()

class PasswordChange(BaseModel):
    new_password: str

@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Iniciar sesión y obtener un token de acceso JWT.

    - **form_data**: Objeto que contiene el nombre de usuario (correo electrónico) y la contraseña ingresada por el usuario.
    
    Esta función verifica las credenciales proporcionadas contra la base de datos:
    1. Busca el usuario por el correo electrónico.
    2. Verifica que la contraseña ingresada coincida con la almacenada en la base de datos.
    3. Si las credenciales son válidas, genera un token JWT (`access_token`) que el usuario puede usar para autenticarse en otros endpoints.

    Control de errores:
    - Lanza un error 400 si las credenciales son incorrectas, ya sea porque el usuario no existe o porque la contraseña es incorrecta.

    Devuelve:
    - **access_token**: Token JWT de acceso para el usuario autenticado.
    - **token_type**: Tipo de token, especificado como "bearer" para este caso.
    """
    # Buscar usuario en la base de datos usando el correo electrónico
    user = await db["users"].find_one({"email": form_data.username})
    # Verificar si el usuario existe y que la contraseña coincida (se recomienda hashear la contraseña)
    if user and bcrypt.checkpw(form_data.password.encode('utf-8'), user["password"].encode('utf-8')):  
        # Generar token de acceso JWT con el email del usuario como sujeto
        access_token = create_access_token(data={"sub": user["email"]})
        
        
        
        # Devolver el token de acceso y el tipo de token
        return {"access_token": access_token, "token_type": "bearer", "user_id": str(user["_id"])}
    
    # Si las credenciales no son válidas, lanzar error 400
    raise HTTPException(status_code=400, detail="Credenciales inválidas")
@router.put("/change-password")
async def change_password(
    password_data: PasswordChange,
    current_user: str = Depends(oauth2_scheme)
):
    payload = verify_token(current_user)
    if payload is None:
        raise HTTPException(status_code=401, detail="Token inválido")
    
    hashed_new_password = bcrypt.hashpw(password_data.new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    result = await db["users"].update_one(
        {"email": payload["sub"]},
        {"$set": {"password": hashed_new_password}}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=400, detail="No se pudo actualizar la contraseña")
    
    return {"message": "Contraseña actualizada exitosamente"}