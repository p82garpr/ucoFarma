import requests

ENDPOINT = 'https://ucofarma.onrender.com'


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




def test_update_user():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test1@example.com",
        "password": "test1"
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
    #Paso 3: Guardar el user_id
    user_id = user_data.get("user_id")
    # Paso 4: Datos del usuario a actualizar
    updated_user_data = {
    "email": "test1@example.com",
    "fullname": "string",
    "password": "test1",
    "birthdate": "10/10/2000"
    } 
    headers = {
        "Authorization": f"Bearer {token}"
    }

    update_user_response = requests.put(ENDPOINT + f"/users/{user_id}", json=updated_user_data, headers=headers)
    assert update_user_response == 400, f"Error al actualizar usuario: {update_user_response.text}"
    response_data = update_user_response.json()
    assert response_data.get("message") == "Usuario actualizado exitosamente"
    print("Usuario actualizado exitosamente:", response_data)
