# app/main.py
#comentario de prueba para ver si se actualiza
from fastapi import FastAPI
from routers import auth, user, medicine, dose, shoplist
from database import db


app = FastAPI(
    title="ucoFarma",
    description="API para la aplicación ucoFarma",
    version="0.1.0"
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(user.router, prefix="/users", tags=["users"])
app.include_router(medicine.router, prefix="/medicines", tags=["medicines"])
app.include_router(dose.router, prefix="/doses", tags=["doses"])
app.include_router(shoplist.router, prefix="/shoplist", tags=["shoplist"])

@app.on_event("startup")
async def startup_db_client():
    db.client

@app.on_event("shutdown")
async def shutdown_db_client():
    db.client.close()
