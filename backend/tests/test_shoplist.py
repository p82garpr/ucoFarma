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
def test_add_shoplist():
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
    print("User ID:", user_id)
    print("First medicine CN:", first_medicine_cn)
    
    # Paso 3: Agregar el medicamento a la lista de compras
    add_shoplist_response = requests.put(
        ENDPOINT + f"/shoplist/{user_id}/add-shoplist",
        headers=headers,
        params={"cn": first_medicine_cn}
    )
    assert add_shoplist_response.status_code == 200, f"Error al agregar a la lista de compras: {add_shoplist_response.text}"
    
    updated_user = add_shoplist_response.json()
    print("Usuario actualizado:", updated_user)
    


def test_delete_shoplist():
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
    first_medicine = next(
        (med for med in user_data.get("medicines", []) if med.get("wished") is True),
        None
    )
    assert user_id, "No se encontró el user_id en la respuesta"
    assert first_medicine, "No se encontró un medicamento en la lista de compras"
    medicine_cn = first_medicine["cn"]
    print("User ID:", user_id)
    print("Medicine CN in Shoplist:", medicine_cn)
    
    # Paso 3: Eliminar el medicamento de la lista de compras
    delete_shoplist_response = requests.delete(
        ENDPOINT + f"/shoplist/{user_id}/delete-shoplist",
        headers=headers,
        params={"cn": medicine_cn}
    )
    assert delete_shoplist_response.status_code == 200, f"Error al eliminar de la lista de compras: {delete_shoplist_response.text}"
    
    updated_user = delete_shoplist_response.json()
    print("Usuario actualizado:", updated_user)
