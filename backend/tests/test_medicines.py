import requests

ENDPOINT = 'http://127.0.0.1:8000'



def test_add_medicine():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Obtener el user_id del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    
    user_data = me_response.json()
    user_id = user_data.get("user_id")
    assert user_id, "No se encontró el user_id en la respuesta"
    
    # Paso 3: Agregar un medicamento al usuario
    medicine_data = {
        "cn": "string",
        "name": "string",
        "quantity": 10,
        "type": "solid",
            "doses": [
            {
                "frequency": 0,
                "quantity": 10,
                "startDate":"2025-01-04T00:00:00.000",
                "endDate":"2025-01-18T00:00:00.000"
            }
        ],
        "wished": False
        }
    add_medicine_response = requests.post(
        ENDPOINT + f"/medicines/{user_id}/add-medicine",
        json=medicine_data,
        headers=headers
    )
    assert add_medicine_response.status_code == 200, f"Error al agregar medicamento: {add_medicine_response.text}"
    
    updated_user = add_medicine_response.json()
    print("Usuario actualizado con medicamento agregado:", updated_user)
    
    # Validar que el medicamento se agregó correctamente
    medicines = updated_user.get("medicines", [])
    assert any(med["cn"] == medicine_data["cn"] for med in medicines), "El medicamento no se agregó correctamente"



def test_take_medicine():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Obtener el user_id del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    
    user_data = me_response.json()
    user_id = user_data.get("user_id")
    assert user_id, "No se encontró el user_id en la respuesta"
    
    
    # Paso 3: Consumir una cantidad del medicamento
    take_medicine_data = {
        "user_id": user_id,
        "cn": "string",
        "quantity": 3
    }
    take_medicine_response = requests.put(
        ENDPOINT + f"/medicines/{user_id}/take-medicine",
        params=take_medicine_data,
        headers=headers
    )
    assert take_medicine_response.status_code == 200, f"Error al consumir medicamento: {take_medicine_response.text}"
    print("Medicamento consumido:", take_medicine_response.json())


def test_delete_medicine():
    # Paso 1: Autenticarse y obtener el token
    login_data = {
        "username": "test@example.com",
        "password": "test"
    }
    login_response = requests.post(ENDPOINT + "/auth/login", data=login_data)
    assert login_response.status_code == 200, f"Error en login: {login_response.text}"
    
    token = login_response.json().get("access_token")
    assert token, "No se obtuvo el token de acceso"
    
    # Paso 2: Obtener el user_id del usuario autenticado
    headers = {
        "Authorization": f"Bearer {token}"
    }
    me_response = requests.get(ENDPOINT + "/users/me", headers=headers)
    assert me_response.status_code == 200, f"Error al obtener datos del usuario: {me_response.text}"
    
    user_data = me_response.json()
    user_id = user_data.get("user_id")
    first_medicine_cn = user_data.get("medicines", [])[0].get("cn") if user_data.get("medicines") else None
    assert user_id, "No se encontró el user_id en la respuesta"
    assert first_medicine_cn, "No se encontró el CN del primer medicamento en la respuesta"
    print ("User ID:", user_id)
    print ("First medicine CN:", first_medicine_cn)
   
    

    # Paso 3: Eliminar el medicamento del inventario
    delete_medicine_response = requests.delete(
        ENDPOINT + f"/medicines/{user_id}/delete-medicine/{first_medicine_cn}",
        headers=headers
    )
    assert delete_medicine_response.status_code == 200, f"Error al eliminar medicamento: {delete_medicine_response.text}"
    print("Medicamento eliminado:", delete_medicine_response.json())

  