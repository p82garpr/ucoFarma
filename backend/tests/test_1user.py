import requests

ENDPOINT = 'http://127.0.0.1:8000'


def test_create_user():
    user_data = {
  "email": "test@example.com",
  "fullname": "test",
  "password": "test",
  "birthdate": "10/10/10"
}

    response = requests.post(ENDPOINT + "/users", json=user_data)
    assert response.status_code == 200

    data = response.json()
    print(data)

def test_read_users_me():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Solicitar datos del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    
    # Validar respuesta
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    

    user_data = me_response.json()
    user_id = user_data.get("user_id")
    print("Datos del usuario autenticado:", user_data)



