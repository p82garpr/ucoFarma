# app/schemas/user.py

from pydantic import BaseModel, EmailStr
from typing import List, Optional
from models.user import Medicine, Dose

class UserBase(BaseModel):
    email: EmailStr
    fullname: str

class UserCreate(UserBase):
    password: str
    birthdate: str

class UserOut(UserBase):
    medicines: List[Medicine] = []

class Token(BaseModel):
    access_token: str
    token_type: str
