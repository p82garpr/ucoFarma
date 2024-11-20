# app/models/user.py

from pydantic import BaseModel, Field, EmailStr
from typing import List, Optional
from enum import Enum

class MedicineType(str, Enum):
    solid = "solid"
    liquid = "liquid"

class Dose(BaseModel):
    frequency: int
    quantity: float

class Medicine(BaseModel):
    cn: str
    name: str
    quantity: int
    type: MedicineType
    doses: Optional[List[Dose]] = None
    wished: bool = False

class User(BaseModel):
    email: EmailStr
    password: str
    fullname: str
    birthdate: str
    medicines: Optional[List[Medicine]] = []
