# app/main.py
#comentario de prueba para ver si se actualiza
from fastapi import FastAPI
from routers import auth, user, medicine
from database import db

app = FastAPI()

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(user.router, prefix="/users", tags=["users"])
app.include_router(medicine.router, prefix="/medicines", tags=["medicines"])

@app.on_event("startup")
async def startup_db_client():
    db.client

@app.on_event("shutdown")
async def shutdown_db_client():
    db.client.close()
