# app/schemas/user.py

from pydantic import BaseModel, EmailStr
from typing import List, Optional
from models.user import Medicine, Dose, Shoplist

class UserBase(BaseModel):
    email: EmailStr
    fullname: str

class UserCreate(UserBase):
    password: str
    birthdate: str
    shoplist: List[Shoplist] = []

class UserOut(UserBase):
    medicines: List[Medicine] = []
    shoplist: List[Shoplist] = []

class Token(BaseModel):
    access_token: str
    token_type: str
