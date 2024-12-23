import requests

ENDPOINT = 'https://ucofarma.onrender.com'


def test_auth():
    #iniciar sesion
    login_data = {
    "username": "test@example.com",
    "password": "test1"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)  
    assert login_response.status_code == 200
    data = login_response.json()
    print(data)
    pass




def test_change_password():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test1"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Cambiar contraseña
    new_password_data = {
        "new_password": "test"  # Cambiar la contraseña aquí
    }
    headers = {
        "Authorization": f"Bearer {token}"
    }
    change_password_response = requests.put(
        ENDPOINT + "/auth/change-password", 
        json=new_password_data, 
        headers=headers
    )
    assert change_password_response.status_code == 200, f"Error al cambiar contraseña: {change_password_response.text}"
    
    response_data = change_password_response.json()
    assert response_data.get("message") == "Contraseña actualizada exitosamente"
    
    print("Test de cambio de contraseña exitoso:", response_data)
